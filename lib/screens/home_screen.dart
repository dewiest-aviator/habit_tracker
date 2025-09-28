import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habits')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => context.push('/settings'),
          icon: const Icon(Icons.settings),
          label: const Text('Settings'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Add habit',
        child: const Icon(Icons.add),
      ),
    );
  }
}