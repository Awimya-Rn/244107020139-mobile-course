import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/providers/stats_provider.dart';

class _FakeRandom extends Fake implements Random {
  final double fixedValue;
  _FakeRandom(this.fixedValue);

  @override
  double nextDouble() => fixedValue;
}

class _SuccessStatsNotifier extends StatsNotifier {
  _SuccessStatsNotifier() : super(random: _FakeRandom(0.5));
}

class _FailStatsNotifier extends StatsNotifier {
  _FailStatsNotifier() : super(random: _FakeRandom(0.1));
}

void main() {
  test('StatsNotifier returns 3 items on success', () async {
    final container = ProviderContainer(
      overrides: [
        statsProvider.overrideWith(() => _SuccessStatsNotifier()),
      ],
    );
    addTearDown(container.dispose);

    final subscription = container.listen(statsProvider, (_, _) {});

    await container.read(statsProvider.future);

    final state = container.read(statsProvider);

    expect(state, isA<AsyncData<List<StatItem>>>());

    final items = state.value!;
    expect(items.length, 3);

    expect(items[0].label, 'Pengguna Aktif');
    expect(items[1].label, 'Total Pesanan');
    expect(items[2].label, 'Pendapatan (juta)');

    expect(items[0].value, 1240);
    expect(items[1].value, 389);
    expect(items[2].value, 57);

    subscription.close();
  });

  test('StatsNotifier throws on failure', () async {
    final container = ProviderContainer(
      overrides: [
        statsProvider.overrideWith(() => _FailStatsNotifier()),
      ],
    );
    addTearDown(container.dispose);

    final subscription = container.listen(statsProvider, (_, _) {});

    expect(
      () => container.read(statsProvider.future),
      throwsA(isA<Exception>()),
    );

    subscription.close();
  });

  test('StatsNotifier refresh re-fetches data', () async {
    final container = ProviderContainer(
      overrides: [
        statsProvider.overrideWith(() => _SuccessStatsNotifier()),
      ],
    );
    addTearDown(container.dispose);

    final subscription = container.listen(statsProvider, (_, _) {});

    await container.read(statsProvider.future);
    expect(container.read(statsProvider).value?.length, 3);

    final notifier = container.read(statsProvider.notifier);
    await notifier.refresh();

    final state = container.read(statsProvider);
    expect(state, isA<AsyncData<List<StatItem>>>());
    expect(state.value?.length, 3);

    subscription.close();
  });

  test('StatItem equality works correctly', () {
    const a = StatItem(label: 'Test', value: 42);
    const b = StatItem(label: 'Test', value: 42);
    const c = StatItem(label: 'Other', value: 99);

    expect(a, equals(b));
    expect(a, isNot(equals(c)));
    expect(a.hashCode, b.hashCode);
  });
}