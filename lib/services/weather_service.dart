import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';
import '../models/weather_model.dart';

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Semua HTTP GET dan decoding JSON ditempatkan di service, bukan di View.
class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<Map<String, dynamic>> _get(Uri uri) async {
    try {
      final response =
          await _client.get(uri).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw ApiException(response.statusCode == 429
            ? 'Permintaan terlalu sering. Tunggu sebentar lalu coba lagi.'
            : 'Server cuaca bermasalah (HTTP ${response.statusCode}). Coba lagi.');
      }
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Format respons bukan objek JSON.');
      }
      if (data['error'] == true) {
        throw const ApiException('Permintaan data ditolak server cuaca.');
      }
      return data;
    } on TimeoutException {
      throw const ApiException(
          'Koneksi terlalu lama. Periksa internet lalu coba lagi.');
    } on http.ClientException {
      throw const ApiException(
          'Tidak dapat terhubung. Periksa koneksi internet kamu.');
    } on FormatException {
      throw const ApiException(
          'Respons server tidak dapat dibaca. Coba lagi nanti.');
    }
  }

  Future<List<LocationModel>> searchCities(String query) async {
    final data =
        await _get(Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': query.trim(),
      'count': '10',
      'language': 'id',
      'format': 'json',
    }));
    return (data['results'] as List<dynamic>? ?? [])
        .map((item) => LocationModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<WeatherModel> getWeather(LocationModel location) async {
    final data = await _get(Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': location.latitude.toString(),
      'longitude': location.longitude.toString(),
      'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,'
          'precipitation,weather_code,wind_speed_10m,is_day',
      'daily': 'temperature_2m_max,temperature_2m_min,'
          'precipitation_probability_max,weather_code',
      'timezone': 'auto',
      'forecast_days': '7',
      'temperature_unit': 'celsius',
      'wind_speed_unit': 'kmh',
      'precipitation_unit': 'mm',
    }));
    return WeatherModel.fromJson(data);
  }

  void dispose() => _client.close();
}
