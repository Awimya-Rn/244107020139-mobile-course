import 'package:go_router/go_router.dart';

import 'features/announcements/presentation/pages/announcements_page.dart';
import 'features/notes/presentation/pages/notes_page.dart';

class Routes {
  static const notes = '/';
  static const announcements = '/announcements';
}

final appRouter = GoRouter(
  routes: [
    GoRoute(path: Routes.notes, builder: (_, _) => const NotesPage()),
    GoRoute(
      path: Routes.announcements,
      builder: (_, _) => const AnnouncementsPage(),
    ),
  ],
);