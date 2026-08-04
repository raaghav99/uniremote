import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'features/remote/domain/remote_model.dart';
import 'features/remote/presentation/screens/home_screen.dart';
import 'features/remote/presentation/screens/remote_screen.dart';
import 'features/setup/presentation/screens/add_remote_screen.dart';

class UniRemoteApp extends ConsumerWidget {
  const UniRemoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'UniRemote',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            );
          case '/add':
            return MaterialPageRoute(
              builder: (_) => const AddRemoteScreen(),
              fullscreenDialog: true,
            );
          case '/remote':
            final remote = settings.arguments as RemoteModel;
            return MaterialPageRoute(
              builder: (_) => RemoteScreen(remote: remote),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            );
        }
      },
    );
  }
}
