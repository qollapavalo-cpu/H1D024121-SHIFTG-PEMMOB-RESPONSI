import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';

/// SharedPreferencesAsync menyimpan JSON favorit dan lokasi terakhir di perangkat.
class LocalStorageService {
  LocalStorageService({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();
  final SharedPreferencesAsync _preferences;
  static const favoritesKey = 'cuaca_favorites_v1';
  static const lastLocationKey = 'cuaca_last_location_v1';

  Future<List<LocationModel>> readFavorites() async {
    final value = await _preferences.getString(favoritesKey);
    if (value == null) return [];
    return (jsonDecode(value) as List<dynamic>)
        .map((item) => LocationModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveFavorites(List<LocationModel> locations) =>
      _preferences.setString(favoritesKey,
          jsonEncode(locations.map((item) => item.toJson()).toList()));

  Future<LocationModel?> readLastLocation() async {
    final value = await _preferences.getString(lastLocationKey);
    if (value == null) return null;
    return LocationModel.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  Future<void> saveLastLocation(LocationModel location) =>
      _preferences.setString(lastLocationKey, jsonEncode(location.toJson()));
}
