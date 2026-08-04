import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'src/app.dart';
import 'src/features/remote/domain/remote_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(RemoteModelAdapter());
  Hive.registerAdapter(IrButtonAdapter());
  await Hive.openBox<RemoteModel>('remotes');
  runApp(const ProviderScope(child: UniRemoteApp()));
}
