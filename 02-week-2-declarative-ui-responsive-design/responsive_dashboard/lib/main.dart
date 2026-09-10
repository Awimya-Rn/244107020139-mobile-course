import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DashboardApp());
}

class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  bool isDark = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: DashboardPage(
        isDark: isDark,
        onDarkChanged: (value) => setState(() => isDark = value),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.isDark,
    required this.onDarkChanged,
    super.key,
  });
  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(header: true, child: const Text("Student Dashboard")),
        actions: [
          Row(
            children: [
              ExcludeSemantics(
                child: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              ),
              const SizedBox(width: 4),
              Semantics(
                label: isDark ? 'Mode Terang' : 'Mode Gelap',
                child: CupertinoSwitch(value: isDark, onChanged: onDarkChanged),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          const ProfileHeader(
            name: "Mokh. Ilham",
            nim: "244107020139",
            email: "244107020139@student.polinema.ac.id",
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 700 ? 2 : 1;
                final cards = [
                  const DashboardCard(title: 'Assignments', value: '8'),
                  const DashboardCard(title: 'Attendance', value: '92%'),
                  const DashboardCard(title: 'Portfolio', value: 'Ready'),
                  const DashboardCard(title: 'Current week', value: '02'),
                ];

                final rows = <Widget>[];
                for (var i = 0; i < cards.length; i += columns) {
                  final rowChildren = cards.skip(i).take(columns).map((c) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: c,
                      ),
                    );
                  }).toList();
                  while (rowChildren.length < columns) {
                    rowChildren.add(
                      const Expanded(child: SizedBox()),
                    ); 
                  }
                  rows.add(Row(children: rowChildren));
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: rows),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.name,
    required this.nim,
    required this.email,
    super.key,
  });
  final String name;
  final String nim;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: Theme.of(context).textTheme.titleMedium),
              Text(nim, style: Theme.of(context).textTheme.bodyMedium),
              Text(email, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  const DashboardCard({required this.title, required this.value, super.key});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$title: $value',
      excludeSemantics: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(child: Text(title)),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}
