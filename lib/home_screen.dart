import 'package:flutter/material.dart';

import 'earnings/earnings_api.dart';
import 'earnings/earnings_screen.dart';
import 'projects_api.dart';
import 'projects_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Funngro assignment')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ListTile(
            title: const Text('Part 1: Earnings'),
            subtitle: const Text('Code-review rewrite'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => EarningsScreen(
                    userId: 'teen_demo',
                    api: DemoEarningsApi(),
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Part 2: Projects'),
            subtitle: const Text('Infinite scroll + flaky API'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ProjectsScreen(api: ProjectsApi()),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
