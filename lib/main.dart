import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aula/app/app.dart';
import 'package:aula/app/bootstrap.dart';

void main() async {
  final bootstrap = await bootstrapApp();
  runApp(
    UncontrolledProviderScope(
      container: bootstrap.container,
      child: const AulaApp(),
    ),
  );
}
