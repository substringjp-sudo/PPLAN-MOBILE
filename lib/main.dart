import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/shared/data/local/collections/scrap.dart';
import 'package:mobile/shared/data/local/collections/trip.dart';
import 'package:mobile/shared/data/local/collections/sync_action.dart';
import 'package:mobile/shared/data/local/collections/timeline_item.dart';
import 'package:mobile/shared/data/local/repositories/sync_repository.dart';
import 'package:mobile/shared/data/local/isar_provider.dart';
import 'package:mobile/features/scrapbook/application/sharing_service.dart';
import 'package:mobile/features/scrapbook/presentation/screens/scrap_inbox_screen.dart';
import 'package:mobile/features/trips/presentation/widgets/trip_creation_bottom_sheet.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile/firebase_options.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final isar = await Isar.open([
        ScrapSchema,
        TripSchema,
        SyncActionSchema,
        TimelineItemSchema,
      ], directory: dir.path);

      final syncRepo = SyncRepository(isar);
      await syncRepo.processPendingActions();
      return true;
    } catch (e) {
      debugPrint('Background Sync Failed: $e');
      return false;
    }
  });
}

void main() async {
  debugPrint('PPLAN: Starting application...');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('PPLAN: Widgets binding initialized.');

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('PPLAN: Firebase initialized.');

  // Initialize Workmanager only on supported platforms (Android/iOS)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    debugPrint('PPLAN: Initializing Workmanager for mobile...');
    try {
      await Workmanager().initialize(callbackDispatcher);

      // Register periodic sync task
      await Workmanager().registerPeriodicTask(
        'pplan-sync-task',
        'pplan-sync-task',
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
      );
      debugPrint('PPLAN: Workmanager initialized.');
    } catch (e) {
      debugPrint('PPLAN: Workmanager initialization failed: $e');
    }
  } else {
    debugPrint(
      'PPLAN: Workmanager skipped (Platform: ${Platform.operatingSystem})',
    );
  }

  debugPrint('PPLAN: Running app via ProviderScope');
  runApp(const ProviderScope(child: PPlanApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/inbox',
      builder: (context, state) => const ScrapInboxScreen(),
    ),
  ],
);

class PPlanApp extends ConsumerWidget {
  const PPlanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('PPLAN: Building PPlanApp...');
    final isarAsync = ref.watch(isarDatabaseProvider);

    return isarAsync.when(
      data: (isar) {
        debugPrint('PPLAN: Isar initialized successfully.');
        return MaterialApp.router(
          title: 'PPLAN',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6366F1),
              brightness: Brightness.light,
            ),
            textTheme: GoogleFonts.interTextTheme(),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6366F1),
              brightness: Brightness.dark,
            ),
            textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system,
          routerConfig: _router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
      loading: () {
        debugPrint('PPLAN: Isar is loading...');
        return const MaterialApp(
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        );
      },
      error: (err, stack) {
        debugPrint('PPLAN: Isar initialization error: $err');
        debugPrint('PPLAN: Stack trace: $stack');
        return MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Error initializing database: $err')),
          ),
        );
      },
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize the sharing service to start listening for intents
    ref.watch(sharingServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('PPLAN Mobile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Ready for Scrapping'),
            const Gap(20),
            ElevatedButton.icon(
              onPressed: () => context.push('/inbox'),
              icon: const Icon(Icons.inbox),
              label: const Text('Go to Scrap Inbox'),
            ),
            const Gap(12),
            ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const TripCreationBottomSheet(),
                );
              },
              icon: const Icon(Icons.add_road),
              label: const Text('Create New Trip'),
            ),
          ],
        ),
      ),
    );
  }
}
