import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/widgets/post_tile.dart';

void main() {
  testWidgets('PostTile menampilkan judul dan id post', (WidgetTester tester) async {
    const post = Post(
      id: 42,
      userId: 1,
      title: 'Judul Post Pengujian',
      body: 'Isi ringkas post pengujian',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PostTile(post: post),
        ),
      ),
    );

    expect(find.text('Judul Post Pengujian'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('Isi ringkas post pengujian'), findsOneWidget);
  });
}
