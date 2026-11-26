import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/local_storage_service.dart';
import '../services/weather_service.dart';

/// ViewModel mengatur state kedua screen. View hanya membaca state dan memanggil aksi.
class WeatherViewModel extends ChangeNotifier {
  WeatherViewModel(
      {required WeatherService weatherService,
      required LocalStorageService storageService})
      : _api = weatherService,
        _storage = storageService;
  final WeatherService _api;
  final LocalStorageService _storage;
  bool initializing = true;
  bool weatherLoading = false;
  bool searchLoading = false;
  bool savingFavorite = false;
  bool searched = false;
  String query = '';
  String? weatherError;
  String? searchError;
  String? storageError;
  LocationModel? selectedLocation;
  WeatherModel? weather;
  List<LocationModel> results = [];
  List<LocationModel> favorites = [];
  int _searchRequest = 0;
  int _weatherRequest = 0;
  bool _disposed = false;

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  Future<void> initialize() async {
    try {
      favorites = await _storage.readFavorites();
    } catch (_) {
      storageError = 'Favorit belum dapat dibaca. Coba buka ulang aplikasi.';
    }
    LocationModel? last;
    try {
      last = await _storage.readLastLocation();
    } catch (_) {
      storageError =
          'Lokasi terakhir belum dapat dibaca. Silakan pilih kota lagi.';
    }
    if (_disposed) return;
    initializing = false;
    _emit();
    if (last != null) await selectLocation(last, persist: false);
  }

  String _message(Object error) => error is ApiException
      ? error.message
      : 'Data tidak dapat diproses. Silakan coba lagi.';

  /// Nomor request mencegah hasil pencarian lama menimpa pencarian baru.
  Future<void> search(String input) async {
    final request = ++_searchRequest;
    query = input.trim();
    results = [];
    searchError = null;
    searched = query.length >= 2;
    searchLoading = searched;
    if (query.isNotEmpty && !searched) {
      searchError = 'Ketik minimal 2 karakter.';
    }
    _emit();
    if (!searched) return;
    try {
      final found = await _api.searchCities(query);
      if (request == _searchRequest && !_disposed) results = found;
    } catch (error) {
      if (request == _searchRequest && !_disposed) {
        searchError = _message(error);
      }
    } finally {
      if (request == _searchRequest && !_disposed) {
        searchLoading = false;
        _emit();
      }
    }
  }

  Future<void> selectLocation(LocationModel location,
      {bool persist = true}) async {
    selectedLocation = location;
    final weatherTask = _loadWeather(location);
    if (persist) {
      try {
        await _storage.saveLastLocation(location);
      } catch (_) {
        storageError =
            'Lokasi terakhir gagal disimpan. Cuaca tetap dapat dilihat.';
        _emit();
      }
    }
    await weatherTask;
  }

  Future<void> _loadWeather(LocationModel location) async {
    final request = ++_weatherRequest;
    weatherLoading = true;
    weatherError = null;
    weather = null; // Jangan tampilkan data kota lama sebagai data kota baru.
    _emit();
    try {
      final loaded = await _api.getWeather(location);
      if (request == _weatherRequest && !_disposed) weather = loaded;
    } catch (error) {
      if (request == _weatherRequest && !_disposed) {
        weatherError = _message(error);
      }
    } finally {
      if (request == _weatherRequest && !_disposed) {
        weatherLoading = false;
        _emit();
      }
    }
  }

  Future<void> refresh() async {
    final location = selectedLocation;
    if (location != null) await _loadWeather(location);
  }

  bool isFavorite(LocationModel location) =>
      favorites.any((x) => x.id == location.id);

  /// UI berubah setelah penyimpanan berhasil; kegagalan tidak memberi sukses palsu.
  Future<bool> toggleFavorite(LocationModel location) async {
    if (savingFavorite || initializing) return false;
    savingFavorite = true;
    storageError = null;
    _emit();
    final updated = [...favorites];
    if (isFavorite(location)) {
      updated.removeWhere((item) => item.id == location.id);
    } else {
      updated.add(location);
    }
    try {
      await _storage.saveFavorites(updated);
      if (_disposed) return false;
      favorites = updated;
      return true;
    } catch (_) {
      storageError =
          'Favorit gagal disimpan. Periksa ruang penyimpanan lalu coba lagi.';
      return false;
    } finally {
      savingFavorite = false;
      _emit();
    }
  }

  void dismissStorageError() {
    storageError = null;
    _emit();
  }

  @override
  void dispose() {
    _disposed = true;
    _api.dispose();
    super.dispose();
  }
}
