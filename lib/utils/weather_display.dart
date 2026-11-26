// Tetap kompatibel dengan Flutter sebelum pemisahan package Material UI.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

String valueText(double? value, String unit, {int decimals = 0}) =>
    value == null ? '—' : '${value.toStringAsFixed(decimals)}$unit';

String weatherLabel(int? code) {
  if (code == 0) return 'Cerah';
  if (code == 1) return 'Umumnya cerah';
  if (code == 2) return 'Cerah berawan';
  if (code == 3) return 'Mendung';
  if (code == 45 || code == 48) return 'Berkabut';
  if ([51, 53, 55, 56, 57].contains(code)) return 'Gerimis';
  if ([61, 63, 65, 66, 67].contains(code)) return 'Hujan';
  if ([71, 73, 75, 77].contains(code)) return 'Salju';
  if ([80, 81, 82].contains(code)) return 'Hujan sesaat';
  if ([85, 86].contains(code)) return 'Hujan salju';
  if ([95, 96, 99].contains(code)) return 'Badai petir';
  return 'Kondisi tidak tersedia';
}

IconData weatherIcon(int? code, {bool isDay = true}) {
  if (code == 0 || code == 1) {
    return isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round;
  }
  if (code == 2) return Icons.wb_cloudy_rounded;
  if (code == 3) return Icons.cloud_rounded;
  if (code == 45 || code == 48) return Icons.foggy;
  if ([71, 73, 75, 77, 85, 86].contains(code)) return Icons.ac_unit_rounded;
  if ([95, 96, 99].contains(code)) return Icons.thunderstorm_rounded;
  if (code != null && code >= 51 && code <= 82) return Icons.water_drop_rounded;
  return Icons.cloud_outlined;
}

String dayLabel(DateTime date) {
  const names = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  return '${names[date.weekday - 1]}, ${date.day}/${date.month}';
}
