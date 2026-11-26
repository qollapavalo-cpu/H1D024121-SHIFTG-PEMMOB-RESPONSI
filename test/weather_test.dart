import 'dart:async';
import 'dart:convert';
// Tetap kompatibel dengan Flutter sebelum pemisahan package Material UI.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:cuaca_app/main.dart';
import 'package:cuaca_app/models/location_model.dart';
import 'package:cuaca_app/models/weather_model.dart';
import 'package:cuaca_app/services/weather_service.dart';
import 'package:cuaca_app/services/local_storage_service.dart';
import 'package:cuaca_app/viewmodels/weather_viewmodel.dart';

const jakarta = LocationModel(
    id: 1,
    name: 'Jakarta',
    latitude: -6.2,
    longitude: 106.8,
    admin1: 'Jakarta',
    country: 'Indonesia');
const bandung =
    LocationModel(id: 2, name: 'Bandung', latitude: -6.9, longitude: 107.6);

Map<String, dynamic> fixture() => {
      'timezone': 'Asia/Jakarta',
      'current': {
        'time': '2026-11-26T09:00',
        'temperature_2m': 29,
        'relative_humidity_2m': 80,
        'apparent_temperature': 32.2,
        'precipitation': 0.4,
        'weather_code': 61,
        'wind_speed_10m': 10,
        'is_day': 1
      },
      'daily': {
        'time': ['2026-11-26', '2026-11-27'],
        'temperature_2m_max': [32, null],
        'temperature_2m_min': [24, 23],
        'precipitation_probability_max': [85, null],
        'weather_code': [61, 3]
      },
    };

class MemoryStorage implements LocalStorageService {
  List<LocationModel> saved = [];
  LocationModel? last;
  bool fail = false;
  @override
  Future<List<LocationModel>> readFavorites() async => [...saved];
  @override
  Future<void> saveFavorites(List<LocationModel> locations) async {
    if (fail) throw Exception('Disk failure');
    saved = [...locations];
  }

  @override
  Future<LocationModel?> readLastLocation() async => last;
  @override
  Future<void> saveLastLocation(LocationModel location) async {
    last = location;
  }
}

class FakeApi extends WeatherService {
  bool fail = false;
  @override
  Future<List<LocationModel>> searchCities(String query) async =>
      query == 'zzzz' ? [] : [jakarta];
  @override
  Future<WeatherModel> getWeather(LocationModel location) async {
    if (fail) throw const ApiException('Tidak ada internet.');
    return WeatherModel.fromJson(fixture());
  }
}

void main() {
  test('JSON angka integer/double dan nilai null tidak menjadi data nol palsu',
      () {
    final weather = WeatherModel.fromJson(fixture());
    expect(weather.temperature, 29.0);
    expect(weather.days.first.rainProbability, 85);
    expect(weather.days.last.max, isNull);
    expect(weather.days.last.rainProbability, isNull);
    expect(LocationModel.fromJson(jakarta.toJson()).id, jakarta.id);
  });

  test('Search GET memakai query dan hasil kosong aman', () async {
    final service = WeatherService(client: MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.host, 'geocoding-api.open-meteo.com');
      expect(request.url.queryParameters['name'], 'New York');
      return http.Response('{}', 200);
    }));
    expect(await service.searchCities('New York'), isEmpty);
    service.dispose();
  });

  test('Forecast meminta koordinat terpilih, current, daily dan timezone',
      () async {
    final service = WeatherService(client: MockClient((request) async {
      expect(request.url.queryParameters['latitude'], '-6.2');
      expect(request.url.queryParameters['timezone'], 'auto');
      expect(request.url.queryParameters['forecast_days'], '7');
      expect(request.url.queryParameters['daily'],
          contains('precipitation_probability_max'));
      return http.Response(jsonEncode(fixture()), 200);
    }));
    expect((await service.getWeather(jakarta)).humidity, 80);
    service.dispose();
  });

  test('HTTP gagal dan JSON rusak menjadi pesan error', () async {
    for (final response in [
      http.Response('{}', 500),
      http.Response('not json', 200)
    ]) {
      final service = WeatherService(client: MockClient((_) async => response));
      await expectLater(
          service.searchCities('Jakarta'), throwsA(isA<ApiException>()));
      service.dispose();
    }
  });

  test('Favorit dapat dipulihkan; gagal menyimpan tidak mengubah state sukses',
      () async {
    final storage = MemoryStorage();
    final vm =
        WeatherViewModel(weatherService: FakeApi(), storageService: storage);
    await vm.initialize();
    expect(await vm.toggleFavorite(jakarta), isTrue);
    final restored =
        WeatherViewModel(weatherService: FakeApi(), storageService: storage);
    await restored.initialize();
    expect(restored.isFavorite(jakarta), isTrue);
    storage.fail = true;
    expect(await restored.toggleFavorite(jakarta), isFalse);
    expect(restored.isFavorite(jakarta), isTrue);
    expect(restored.storageError, isNotNull);
    storage.fail = false;
    await restored.toggleFavorite(jakarta);
    expect(storage.saved, isEmpty);
    vm.dispose();
    restored.dispose();
  });

  test('Lokasi terakhir dipulihkan; kegagalan API bisa dicoba lagi', () async {
    final storage = MemoryStorage()..last = jakarta;
    final api = FakeApi()..fail = true;
    final vm = WeatherViewModel(weatherService: api, storageService: storage);
    await vm.initialize();
    expect(vm.selectedLocation!.name, 'Jakarta');
    expect(vm.weatherError, isNotNull);
    expect(vm.weatherLoading, isFalse);
    api.fail = false;
    await vm.refresh();
    expect(vm.weatherError, isNull);
    expect(vm.weather, isNotNull);
    vm.dispose();
  });

  test('Respons pencarian lama tidak menimpa pencarian terbaru', () async {
    final old = Completer<http.Response>();
    final api = WeatherService(client: MockClient((request) async {
      if (request.url.queryParameters['name'] == 'Jakarta') return old.future;
      return http.Response(
          jsonEncode({
            'results': [bandung.toJson()]
          }),
          200);
    }));
    final vm =
        WeatherViewModel(weatherService: api, storageService: MemoryStorage());
    await vm.initialize();
    final first = vm.search('Jakarta');
    await vm.search('Bandung');
    old.complete(http.Response(
        jsonEncode({
          'results': [jakarta.toJson()]
        }),
        200));
    await first;
    expect(vm.results.single.name, 'Bandung');
    expect(vm.searchLoading, isFalse);
    vm.dispose();
  });

  test('Ganti kota cepat tidak menampilkan respons kota lama', () async {
    final old = Completer<http.Response>();
    final api = WeatherService(client: MockClient((request) async {
      if (request.url.queryParameters['latitude'] == '-6.2') return old.future;
      final data = fixture();
      (data['current'] as Map<String, dynamic>)['temperature_2m'] = 20;
      return http.Response(jsonEncode(data), 200);
    }));
    final vm =
        WeatherViewModel(weatherService: api, storageService: MemoryStorage());
    await vm.initialize();
    final first = vm.selectLocation(jakarta);
    await vm.selectLocation(bandung);
    old.complete(http.Response(jsonEncode(fixture()), 200));
    await first;
    expect(vm.selectedLocation!.name, 'Bandung');
    expect(vm.weather!.temperature, 20);
    vm.dispose();
  });

  testWidgets('Alur cari, favorit, pilih kota, cuaca pada layar sempit',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final vm = WeatherViewModel(
        weatherService: FakeApi(), storageService: MemoryStorage());
    await vm.initialize();
    await tester.pumpWidget(
        ChangeNotifierProvider.value(value: vm, child: const CuacaApp()));
    await tester.tap(find.text('Pilih kota'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('cityInput')), 'Jakarta');
    await tester.tap(find.text('Cari kota'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Favoritkan Jakarta').first);
    await tester.pumpAndSettle();
    expect(vm.isFavorite(jakarta), isTrue);
    await tester.pump(const Duration(seconds: 3));
    await tester.ensureVisible(find.byType(ListTile).first);
    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();
    expect(find.text('29°C'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(ListView).first, const Offset(0, -550));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    vm.dispose();
  });
}
