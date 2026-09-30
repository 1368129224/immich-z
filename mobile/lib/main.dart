import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import 'src/providers/theme_provider.dart';
import 'src/routing/app_router.dart';
import 'src/services/background_service.dart';
import 'src/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();
  await Workmanager().initialize(
    backgroundTaskDispatcher,
    isInDebugMode: false,
  );

  runApp(const ProviderScope(child: ImmichZApp()));
}

class ImmichZApp extends ConsumerStatefulWidget {
  const ImmichZApp({super.key});

  @override
  ConsumerState<ImmichZApp> createState() => _ImmichZAppState();
}

class _ImmichZAppState extends ConsumerState<ImmichZApp> {
  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final accent = ref.watch(accentColorProvider);
    final textScale = ref.watch(textScaleProvider);

    final light = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: accent,
    );
    final dark = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: accent,
    );

    return MaterialApp.router(
      title: 'Immich Z',
      debugShowCheckedModeBanner: false,
      theme: light,
      darkTheme: dark,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(textScale)),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
