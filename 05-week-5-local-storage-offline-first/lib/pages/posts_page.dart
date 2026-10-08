import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/sync.dart';

class PostsPage extends ConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Posts (cache-first)')),
      body: posts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('Belum ada cache. Buka sekali saat online.'))
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) => ListTile(
                  title: Text(items[i].title),
                  subtitle: Text(items[i].body, maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ),
      ),
    );
  }
}