import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/models/post.dart';

/// Widget baris untuk menampilkan item [Post] dalam list.
///
/// Mengekstrak ListTile agar ListView.builder di PostListPage dan PagedPostPage
/// lebih pendek, bersih, dan mudah diuji secara terisolasi.
class PostTile extends StatelessWidget {
  const PostTile({
    super.key,
    required this.post,
    this.onTap,
    this.showSubtitle = true,
  });

  final Post post;
  final VoidCallback? onTap;
  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(post.id.toString()),
      ),
      title: Text(
        post.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: showSubtitle && post.body.isNotEmpty
          ? Text(
              post.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      onTap: onTap ?? () => context.go('/post/${post.id}'),
    );
  }
}
