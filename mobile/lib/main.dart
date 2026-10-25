import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/local/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Hive and open all required boxes before runApp
  // so the first frame can read cached data synchronously.
  await Hive.initFlutter();
  await HiveService.openBoxes();

  runApp(
    // ProviderScope is required for Riverpod
    const ProviderScope(
      child: ImeWeatherApp(),
    ),
  );
}
