import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test_7_solutions/presentation/app.dart';

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const MyApp());
  }, (error, stack) {
    debugPrint(error.toString());
    debugPrint(stack.toString());
  });
}
