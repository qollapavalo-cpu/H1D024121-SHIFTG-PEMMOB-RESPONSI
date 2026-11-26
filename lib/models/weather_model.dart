double? _number(dynamic value) => (value as num?)?.toDouble();

class DailyWeather {
  const DailyWeather(
      {required this.date,
      this.max,
      this.min,
      this.rainProbability,
      this.code});
  final DateTime date;
  final double? max;
  final double? min;
  final double? rainProbability;
  final int? code;
}

/// Nilai API yang null tetap null, agar tidak ditampilkan sebagai angka nol palsu.
class WeatherModel {
  const WeatherModel(
      {required this.time,
      required this.timezone,
      required this.days,
      this.temperature,
      this.humidity,
      this.feelsLike,
      this.precipitation,
      this.code,
      this.windSpeed,
      this.isDay = true});
  final String time;
  final String timezone;
  final double? temperature;
  final double? humidity;
  final double? feelsLike;
  final double? precipitation;
  final int? code;
  final double? windSpeed;
  final bool isDay;
  final List<DailyWeather> days;

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>?;
    if (current == null || current.isEmpty) {
      throw const FormatException('Data cuaca terkini tidak tersedia.');
    }
    final daily = json['daily'] as Map<String, dynamic>? ?? {};
    final dates = daily['time'] as List<dynamic>? ?? [];
    dynamic at(String key, int i) {
      final values = daily[key] as List<dynamic>?;
      return values != null && i < values.length ? values[i] : null;
    }

    return WeatherModel(
      time: current['time'] as String? ?? '',
      timezone: json['timezone'] as String? ?? '',
      temperature: _number(current['temperature_2m']),
      humidity: _number(current['relative_humidity_2m']),
      feelsLike: _number(current['apparent_temperature']),
      precipitation: _number(current['precipitation']),
      code: (current['weather_code'] as num?)?.toInt(),
      windSpeed: _number(current['wind_speed_10m']),
      isDay: current['is_day'] != 0,
      days: List.generate(
          dates.length,
          (i) => DailyWeather(
                date: DateTime.parse(dates[i] as String),
                max: _number(at('temperature_2m_max', i)),
                min: _number(at('temperature_2m_min', i)),
                rainProbability:
                    _number(at('precipitation_probability_max', i)),
                code: (at('weather_code', i) as num?)?.toInt(),
              )),
    );
  }
}
