import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatItem {
  const StatItem({required this.label, required this.value});
  final String label;
  final int value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatItem && label == other.label && value == other.value;

  @override
  int get hashCode => label.hashCode ^ value.hashCode;

  @override
  String toString() => 'StatItem(label: $label, value: $value)';
}

class StatsNotifier extends AsyncNotifier<List<StatItem>> {
  final Random _random;
  StatsNotifier({Random? random}) : _random = random ?? Random();

  @override
  Future<List<StatItem>> build() => _fetchStats();

  Future<List<StatItem>> _fetchStats() async {
    await Future.delayed(const Duration(seconds: 2));

    if (_random.nextDouble() < 0.3) {
      throw Exception('Gagal mengambil data statistik');
    }

    return const [
      StatItem(label: 'Pengguna Aktif', value: 1240),
      StatItem(label: 'Total Pesanan', value: 389),
      StatItem(label: 'Pendapatan (juta)', value: 57),
    ];
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchStats());
  }
}

final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<StatItem>>(StatsNotifier.new);
