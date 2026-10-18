import '../../../../core/failures.dart';
import '../entities/announcement.dart';
import '../repositories/announcement_repository.dart';

class GetAnnouncements {
  const GetAnnouncements(this._repository);
  final AnnouncementRepository _repository;

  Future<({List<Announcement> items, Failure? failure})> call() async {
    final result = await _repository.fetchAnnouncements();
    if (result.failure != null) return result;
    final sorted = [...result.items]..sort((a, b) => b.id.compareTo(a.id));
    return (items: sorted, failure: null);
  }
}