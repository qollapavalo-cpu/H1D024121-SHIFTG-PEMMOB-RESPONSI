import 'dart:async';
// Tetap kompatibel dengan Flutter sebelum pemisahan package Material UI.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/location_model.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../widgets/state_panel.dart';
import '../widgets/storage_notice.dart';

/// StatefulWidget mengelola lifecycle controller input pencarian.
class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});
  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late final TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: context.read<WeatherViewModel>().query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search() {
    FocusScope.of(context).unfocus();
    unawaited(context.read<WeatherViewModel>().search(_controller.text));
  }

  void _choose(LocationModel location) {
    unawaited(context.read<WeatherViewModel>().selectLocation(location));
    Navigator.pop(context);
  }

  Future<void> _favorite(LocationModel location) async {
    final vm = context.read<WeatherViewModel>();
    final removing = vm.isFavorite(location);
    final success = await vm.toggleFavorite(location);
    if (!mounted || !success) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(removing
          ? '${location.name} dihapus dari favorit.'
          : '${location.name} disimpan ke favorit.'),
      duration: const Duration(seconds: 2),
    ));
  }

  Widget _locationCard(LocationModel location, WeatherViewModel vm) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: const Icon(Icons.location_on_outlined),
          title: Text(location.name,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(location.subtitle),
          onTap: () => _choose(location),
          trailing: IconButton(
            tooltip: vm.isFavorite(location)
                ? 'Hapus favorit ${location.name}'
                : 'Favoritkan ${location.name}',
            onPressed: vm.savingFavorite ? null : () => _favorite(location),
            icon: Icon(
                vm.isFavorite(location)
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color:
                    vm.isFavorite(location) ? const Color(0xFFAF7100) : null),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Cari lokasi')),
      body: SafeArea(
          child: Center(
              child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Text('Cuaca di kotamu',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Cari kota, pilih lokasinya, lalu lihat cuaca terbaru.'),
          const SizedBox(height: 20),
          TextField(
            key: const Key('cityInput'),
            controller: _controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              labelText: 'Nama kota',
              hintText: 'Contoh: Purwokerto',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                  tooltip: 'Bersihkan pencarian',
                  onPressed: () {
                    _controller.clear();
                    unawaited(vm.search(''));
                  },
                  icon: const Icon(Icons.close)),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
              onPressed: _search,
              icon: const Icon(Icons.search),
              label: const Padding(
                  padding: EdgeInsets.all(12), child: Text('Cari kota'))),
          const StorageNotice(),
          if (vm.searchLoading) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 12),
            const Center(child: Text('Mencari lokasi...')),
          ] else if (vm.searchError != null)
            StatePanel(
                icon: Icons.wifi_off_rounded,
                title: 'Pencarian belum berhasil',
                message: vm.searchError!,
                onAction: _search)
          else if (vm.searched) ...[
            const SizedBox(height: 24),
            Text('Hasil untuk “${vm.query}”',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (vm.results.isEmpty)
              const StatePanel(
                  icon: Icons.search_off_rounded,
                  title: 'Kota tidak ditemukan',
                  message: 'Coba nama kota lain atau periksa ejaannya.')
            else
              ...vm.results.map((location) => _locationCard(location, vm)),
          ],
          const SizedBox(height: 28),
          Text('Lokasi favorit', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
              'Ketuk nama kota untuk membuka cuaca. Ketuk bintang untuk menyimpan atau menghapus.'),
          const SizedBox(height: 12),
          if (vm.favorites.isEmpty)
            const StatePanel(
                icon: Icons.star_outline_rounded,
                title: 'Belum ada favorit',
                message:
                    'Cari kota di atas dan ketuk ikon bintang pada hasil pencarian.')
          else
            ...vm.favorites.map((location) => _locationCard(location, vm)),
          const SizedBox(height: 16),
          const Text('Data lokasi: Open-Meteo / GeoNames',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54)),
        ]),
      ))),
    );
  }
}
