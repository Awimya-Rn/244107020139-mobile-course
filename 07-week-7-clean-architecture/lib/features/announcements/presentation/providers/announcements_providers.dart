import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/http_client.dart';
import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/usecases/get_announcements.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepositoryImpl(buildHttpClient());
});

final getAnnouncementsProvider = Provider<GetAnnouncements>((ref) {
  return GetAnnouncements(ref.watch(announcementRepositoryProvider));
});

final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  final result = await ref.watch(getAnnouncementsProvider).call();
  if (result.failure != null) throw result.failure!;
  return result.items;
});