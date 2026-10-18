import '../../domain/entities/announcement.dart';

class AnnouncementModel {
  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.body,
  });

  final int id;
  final String title;
  final String body;

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  Announcement toEntity() => Announcement(id: id, title: title, body: body);
}