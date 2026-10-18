import 'package:flutter_test/flutter_test.dart';
import 'package:week7_clean_notes/core/failures.dart';
import 'package:week7_clean_notes/features/announcements/domain/entities/announcement.dart';
import 'package:week7_clean_notes/features/announcements/domain/usecases/get_announcements.dart';

import 'fakes.dart';

void main() {
  test('GetAnnouncements mengurutkan id terbesar di atas', () async {
    final repo = FakeAnnouncementRepository(items: const [
      Announcement(id: 1, title: 'lama', body: ''),
      Announcement(id: 3, title: 'baru', body: ''),
      Announcement(id: 2, title: 'tengah', body: ''),
    ]);
    final result = await GetAnnouncements(repo).call();
    expect(result.items.map((e) => e.id), [3, 2, 1]);
  });

  test('GetAnnouncements meneruskan NetworkFailure', () async {
    final result =
        await GetAnnouncements(FakeAnnouncementRepository(fail: true)).call();
    expect(result.failure, isA<NetworkFailure>());
    expect(result.items, isEmpty);
  });
}