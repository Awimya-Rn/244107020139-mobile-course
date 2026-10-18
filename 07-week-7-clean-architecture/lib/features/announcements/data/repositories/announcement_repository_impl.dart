import 'package:dio/dio.dart';

import '../../../../core/failures.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../models/announcement_model.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  AnnouncementRepositoryImpl(this._client);
  final Dio _client;

  @override
  Future<({List<Announcement> items, Failure? failure})>
      fetchAnnouncements() async {
    try {
      final res = await _client
          .get<List<dynamic>>('/posts', queryParameters: {'_limit': 10});
      final items = (res.data ?? [])
          .cast<Map<String, dynamic>>()
          .map((j) => AnnouncementModel.fromJson(j).toEntity())
          .toList();
      return (items: items, failure: null);
    } on DioException catch (e) {
      final msg = switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.connectionError =>
          'Tidak dapat terhubung ke server. Periksa koneksi internet.',
        _ => 'Server bermasalah (${e.response?.statusCode ?? 'tanpa status'}).',
      };
      return (items: const <Announcement>[], failure: NetworkFailure(msg));
    } catch (_) {
      return (
        items: const <Announcement>[],
        failure: const NetworkFailure('Data pengumuman tidak valid.'),
      );
    }
  }
}