// Tetap kompatibel dengan Flutter sebelum pemisahan package Material UI.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/weather_viewmodel.dart';

class StorageNotice extends StatelessWidget {
  const StorageNotice({super.key});
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();
    if (vm.storageError == null) return const SizedBox.shrink();
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(child: Text(vm.storageError!)),
            IconButton(
                onPressed: vm.dismissStorageError,
                tooltip: 'Tutup pemberitahuan',
                icon: const Icon(Icons.close)),
          ])),
    );
  }
}
