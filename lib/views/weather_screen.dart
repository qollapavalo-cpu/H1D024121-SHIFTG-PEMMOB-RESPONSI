// Tetap kompatibel dengan Flutter sebelum pemisahan package Material UI.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../utils/weather_display.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../widgets/state_panel.dart';
import '../widgets/storage_notice.dart';
import 'location_screen.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});
  void _openSearch(BuildContext context) => Navigator.push(
      context, MaterialPageRoute<void>(builder: (_) => const LocationScreen()));

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Langit', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
              tooltip: 'Cari lokasi dan favorit',
              onPressed: vm.initializing ? null : () => _openSearch(context),
              icon: const Icon(Icons.search_rounded)),
          IconButton(
              tooltip: 'Perbarui cuaca',
              onPressed: vm.selectedLocation == null || vm.weatherLoading
                  ? null
                  : vm.refresh,
              icon: const Icon(Icons.refresh_rounded)),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
          child: Center(
              child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: RefreshIndicator(
            onRefresh: vm.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                const StorageNotice(),
                if (vm.initializing)
                  const Padding(
                      padding: EdgeInsets.all(64),
                      child: Center(child: CircularProgressIndicator()))
                else if (vm.selectedLocation == null)
                  StatePanel(
                      icon: Icons.wb_sunny_outlined,
                      title: 'Hari ini, langitnya bagaimana?',
                      message:
                          'Pilih kota untuk melihat cuaca terkini dan prakiraan tujuh hari ke depan.',
                      actionLabel: 'Pilih kota',
                      onAction: () => _openSearch(context))
                else ...[
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(vm.selectedLocation!.name,
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                          Text(vm.selectedLocation!.subtitle),
                        ])),
                    IconButton(
                      tooltip: vm.isFavorite(vm.selectedLocation!)
                          ? 'Hapus dari favorit'
                          : 'Simpan favorit',
                      onPressed: vm.savingFavorite
                          ? null
                          : () => vm.toggleFavorite(vm.selectedLocation!),
                      icon: Icon(
                          vm.isFavorite(vm.selectedLocation!)
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: const Color(0xFFAF7100),
                          size: 30),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  if (vm.weatherLoading) ...[
                    const Padding(
                        padding: EdgeInsets.all(44),
                        child: Center(child: CircularProgressIndicator())),
                    const Center(child: Text('Mengambil cuaca terbaru...')),
                  ] else if (vm.weatherError != null)
                    StatePanel(
                        icon: Icons.cloud_off_rounded,
                        title: 'Cuaca belum dapat dimuat',
                        message: vm.weatherError!,
                        onAction: vm.refresh)
                  else if (vm.weather != null) ...[
                    _CurrentWeather(weather: vm.weather!),
                    const SizedBox(height: 24),
                    Text('Detail cuaca',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _WeatherDetails(weather: vm.weather!),
                    const SizedBox(height: 28),
                    Text('Prakiraan 7 hari',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    if (vm.weather!.days.isEmpty)
                      const Text(
                          'Prakiraan harian belum tersedia untuk lokasi ini.')
                    else
                      ...vm.weather!.days.map((day) => _ForecastCard(day: day)),
                    const SizedBox(height: 20),
                    Text(
                        'Waktu data: ${vm.weather!.time.replaceFirst('T', ' • ')}\n'
                        'Zona waktu: ${vm.weather!.timezone}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                  ],
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                      onPressed: () => _openSearch(context),
                      icon: const Icon(Icons.location_on_outlined),
                      label: const Text('Ganti kota / buka favorit')),
                ],
                const SizedBox(height: 24),
                const Text(
                    'Data cuaca: Open-Meteo • CC BY 4.0\n'
                    'Prakiraan dapat berubah. Tarik ke bawah untuk memperbarui.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            )),
      ))),
    );
  }
}

class _CurrentWeather extends StatelessWidget {
  const _CurrentWeather({required this.weather});
  final WeatherModel weather;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: weather.isDay
                    ? const [Color(0xFF1D55A5), Color(0xFF3A85D7)]
                    : const [Color(0xFF182C59), Color(0xFF40558A)])),
        child: Column(children: [
          const Text('CUACA TERKINI',
              style: TextStyle(color: Colors.white70, letterSpacing: 2)),
          const SizedBox(height: 20),
          Icon(weatherIcon(weather.code, isDay: weather.isDay),
              color: const Color(0xFFFFD681), size: 70),
          const SizedBox(height: 8),
          FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(valueText(weather.temperature, '°C'),
                  style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w300,
                      color: Colors.white))),
          Text(weatherLabel(weather.code),
              style: const TextStyle(fontSize: 20, color: Colors.white),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Terasa seperti ${valueText(weather.feelsLike, '°C')}',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center),
        ]),
      );
}

class _WeatherDetails extends StatelessWidget {
  const _WeatherDetails({required this.weather});
  final WeatherModel weather;
  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.water_drop_outlined,
        'Kelembapan',
        valueText(weather.humidity, '%')
      ),
      (
        Icons.air_rounded,
        'Kecepatan angin',
        valueText(weather.windSpeed, ' km/j', decimals: 1)
      ),
      (
        Icons.umbrella_outlined,
        'Peluang hujan hari ini',
        valueText(
            weather.days.isEmpty ? null : weather.days.first.rainProbability,
            '%')
      ),
      (
        Icons.grain_rounded,
        'Curah hujan saat ini',
        valueText(weather.precipitation, ' mm', decimals: 1)
      ),
    ];
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= 700
          ? 4
          : constraints.maxWidth < 280
              ? 1
              : 2;
      final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
      return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items
              .map((item) => SizedBox(
                    width: width,
                    child: Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(item.$1,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                const SizedBox(height: 12),
                                Text(item.$3,
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(item.$2,
                                    style: const TextStyle(fontSize: 12)),
                              ]),
                        )),
                  ))
              .toList());
    });
  }
}

class _ForecastCard extends StatelessWidget {
  const _ForecastCard({required this.day});
  final DailyWeather day;
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Icon(weatherIcon(day.code),
                  color: Theme.of(context).colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(dayLabel(day.date),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(weatherLabel(day.code),
                        style: const TextStyle(fontSize: 12)),
                    Text('Peluang hujan ${valueText(day.rainProbability, '%')}',
                        style: const TextStyle(fontSize: 12)),
                  ])),
              const SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('Maks ${valueText(day.max, '°')}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                Text('Min ${valueText(day.min, '°')}',
                    style: const TextStyle(color: Colors.black54)),
              ]),
            ])),
      );
}
