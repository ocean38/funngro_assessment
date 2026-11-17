import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.detail});

  final Object detail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earning detail')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(detail.toString(), textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
