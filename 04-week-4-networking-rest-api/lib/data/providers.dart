import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'api_client.dart';
import 'models/post.dart';
import 'models/comment.dart';
import 'repositories/post_repository.dart';
import 'repositories/comment_repository.dart';
import 'paged_posts.dart';
export 'network_errors.dart';


final dioProvider = Provider<Dio>((ref) => createDio());

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(ref.watch(dioProvider)),
);

final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

class PostListNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final repository = ref.watch(postRepositoryProvider);
    return repository.fetchPosts();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(postRepositoryProvider);
      state = AsyncData(await repository.fetchPosts());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final postListProvider =
    AsyncNotifierProvider<PostListNotifier, List<Post>>(
        PostListNotifier.new,
        retry: (retryCount, error) => null);

Future<List<Post>> readPostsOnce(ProviderContainer container) {
  final completer = Completer<List<Post>>();
  final sub = container.listen<AsyncValue<List<Post>>>(
    postListProvider,
    (previous, next) {
      if (next.isLoading || completer.isCompleted) return;
      next.whenData(completer.complete);
      if (next.hasError) {
        completer.completeError(
          next.error ?? StateError('unknown error'),
          next.stackTrace ?? StackTrace.empty,
        );
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(sub.close);
}

Future<Object?> readPostsErrorOnce(ProviderContainer container) {
  final completer = Completer<Object?>();
  final sub = container.listen<AsyncValue<List<Post>>>(
    postListProvider,
    (previous, next) {
      if (next.isLoading || completer.isCompleted) return;
      completer.complete(next.error);
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(sub.close);
}

final postDetailProvider = FutureProvider.family<Post, int>((ref, id) async {
  final postListAsync = ref.read(postListProvider);
  if (postListAsync.hasValue && postListAsync.value != null) {
    for (final post in postListAsync.value!) {
      if (post.id == id) return post;
    }
  }

  final pagedState = ref.read(pagedPostsProvider);
  for (final post in pagedState.items) {
    if (post.id == id) return post;
  }
  final repository = ref.watch(postRepositoryProvider);
  return repository.fetchPostById(id);
}, retry: (retryCount, error) => null);


final commentListProvider =
    FutureProvider.family<List<Comment>, int>((ref, postId) async {
  final repository = ref.watch(commentRepositoryProvider);

  return repository.fetchComments(postId);
}, retry: (retryCount, error) => null);

Future<List<Comment>> readCommentsOnce(
  ProviderContainer container,
  int postId,
) {
  final completer = Completer<List<Comment>>();
  final sub = container.listen<AsyncValue<List<Comment>>>(
    commentListProvider(postId),
    (previous, next) {
      if (next.isLoading || completer.isCompleted) return;
      next.whenData(completer.complete);
      if (next.hasError) {
        completer.completeError(
          next.error ?? StateError('unknown error'),
          next.stackTrace ?? StackTrace.empty,
        );
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(sub.close);
}

Future<Object?> readCommentsErrorOnce(
  ProviderContainer container,
  int postId,
) {
  final completer = Completer<Object?>();
  final sub = container.listen<AsyncValue<List<Comment>>>(
    commentListProvider(postId),
    (previous, next) {
      if (next.isLoading || completer.isCompleted) return;
      completer.complete(next.error);
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(sub.close);
}
