import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_theme.dart';
import 'firebase_options.dart';
import 'providers/providers.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/user_details_form_screen.dart';
import 'services/database.dart';
import 'services/profile_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final database = AppDatabase();
  final profileRepository = ProfileRepository(database);

  runApp(
    ProviderScope(
      overrides: [
        profileRepositoryProvider.overrideWithValue(profileRepository),
      ],
      child: const BmiTrackerApp(),
    ),
  );
}

class BmiTrackerApp extends StatelessWidget {
  const BmiTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) return const LoginScreen();

        final profilesAsync = ref.watch(profilesProvider(user.uid));

        return profilesAsync.when(
          data: (profiles) => profiles.isEmpty
              ? UserDetailsFormScreen(ownerUid: user.uid)
              : DashboardScreen(ownerUid: user.uid),
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (err, _) => Scaffold(
            body: Center(child: Text('Error loading profiles: $err')),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(
        body: Center(child: Text('Something went wrong: $err')),
      ),
    );
  }
}
