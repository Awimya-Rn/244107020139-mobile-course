import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/error_view.dart';
import '../providers/announcements_providers.dart';

class AnnouncementsPage extends ConsumerWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(announcementsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pengumuman')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: messageOf(e),
          onRetry: () => ref.invalidate(announcementsProvider),
        ),
        data: (items) => ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) => ListTile(
            title: Text(items[i].title),
            subtitle: Text(
              items[i].body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}