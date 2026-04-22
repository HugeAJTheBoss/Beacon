// Sources also used in auth_service.dart / database_service.dart
// Firebase core setup:     https://firebase.google.com/docs/flutter/setup
// FirebaseAuth/Firestore:  https://firebase.flutter.dev/docs/overview

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app_theme.dart';
import 'firebase_options.dart';
import 'student_screen.dart';
import 'org_signup_screen.dart';
import 'signin_screen.dart';
import 'org_dashboard_screen.dart';
import 'services/auth_service.dart';
import 'preferences_service.dart';

const double _appBarLogoHeight = 40;

void main() async {
  // ensures Flutter engine is ready before calling native code
  // Tutorial: https://www.geeksforgeeks.org/flutter-main-dart-file/
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase.initializeApp() - initializes Firebase using platform-specific options
  // Source: https://firebase.google.com/docs/flutter/setup
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const BeaconApp());
}
// StatelessWidget - used here because BeaconApp itself holds no mutable state
// Tutorial: https://www.geeksforgeeks.org/flutter-stateful-vs-stateless-widgets/
class BeaconApp extends StatelessWidget {
  const BeaconApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp - top-level widget that sets up navigation, theming, and title
    // Tutorial: https://www.geeksforgeeks.org/flutter-materialapp-widget/
    return MaterialApp(
      title: 'Beacon',
      debugShowCheckedModeBanner: false, // hides the debug banner in the corner
      theme: AppTheme.lightTheme,
      home: const _StartupGate(),
    );
  }
}

class _StartupGate extends StatelessWidget {
  const _StartupGate();
  // Decides which screen to open on launch based on saved preferences and auth state
  Future<Widget> _resolveInitialScreen() async {
    final restoreStudent = await PreferencesService.shouldRestoreStudentOnLaunch();
    if (restoreStudent) {
      return const _RestoreStudentEntry();
    }

    final approvedOrgUser = await AuthService().getApprovedCurrentUser();
    if (approvedOrgUser != null) {
      final restoreOrg = await PreferencesService.shouldRestoreOrgOnLaunch();
      if (restoreOrg) {
        return const _RestoreOrgEntry();
      }
    }

    return const WelcomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    // FutureBuilder - rebuilds the widget when an async Future completes
    // Tutorial: https://www.geeksforgeeks.org/flutter-futurebuilder-widget/
    return FutureBuilder<Widget>(
      future: _resolveInitialScreen(),
      builder: (context, snapshot) {
        // ConnectionState.waiting - Future is still running, show a loading spinner
        // Source: https://api.flutter.dev/flutter/widgets/ConnectionState.html
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return snapshot.data ?? const WelcomeScreen();
      },
    );
  }
}
// StatefulWidget used here because we need to trigger a Navigator.push exactly once after the widget is mounted
// Source: https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html
// Tutorial: https://www.geeksforgeeks.org/flutter-stateful-vs-stateless-widgets/
class _RestoreStudentEntry extends StatefulWidget {
  const _RestoreStudentEntry();

  @override
  State<_RestoreStudentEntry> createState() => _RestoreStudentEntryState();
}

class _RestoreStudentEntryState extends State<_RestoreStudentEntry> {
  bool _pushed = false; // guard flag to prevent pushing the route more than once

  @override
  void didChangeDependencies() {
    // Source: https://api.flutter.dev/flutter/widgets/State/didChangeDependencies.html
    super.didChangeDependencies();
    if (_pushed) return;
    _pushed = true;
    // addPostFrameCallback - runs the callback after the current frame is drawn, ensuring the widget tree is fully built before navigating
    // Tutorial: https://www.geeksforgeeks.org/flutter-addpostframecallback/
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.push(
        context,
        // Source: https://api.flutter.dev/flutter/material/MaterialPageRoute-class.html
        MaterialPageRoute(builder: (_) => const StudentScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const WelcomeScreen();
  }
}

class _RestoreOrgEntry extends StatefulWidget {
  const _RestoreOrgEntry();

  @override
  State<_RestoreOrgEntry> createState() => _RestoreOrgEntryState();
}

class _RestoreOrgEntryState extends State<_RestoreOrgEntry> {
  bool _pushed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pushed) return;
    _pushed = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.push(
        context,
        // Source: https://api.flutter.dev/flutter/material/MaterialPageRoute-class.html
        MaterialPageRoute(builder: (_) => const OrgDashboardScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const WelcomeScreen();
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold - provides the basic Material Design page structure (appbar, body, etc.)
    // Tutorial: https://www.geeksforgeeks.org/flutter-scaffold-widget/
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        automaticallyImplyLeading: false, // hides the default back arrow
        titleSpacing: 12,
        title: Image.asset(
          'assets/beacon_app_bar.png',
          height: _appBarLogoHeight,
          fit: BoxFit.fitHeight,
          filterQuality: FilterQuality.high,
        ),
      ),
      // SafeArea - prevents content from being hidden behind notches or system UI
      // Source: https://api.flutter.dev/flutter/widgets/SafeArea-class.html
      body: SafeArea(
        top: false,
        // Padding + Column - standard Flutter layout pattern
        // Tutorial: https://www.geeksforgeeks.org/flutter-column-widget/
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 90),
              Text(
                'Beacon',
                textAlign: TextAlign.center,
              // Theme.of(context) - accesses the app's current theme for consistent styling
              // Source: https://api.flutter.dev/flutter/material/Theme/of.html
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              const Text(
                'Find STEM clubs, events, and\nvolunteering opportunities near you in Massachusetts.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.subtle,
                  height: 1.5,
                ),
              ),
              // Spacer - pushes the buttons to the bottom of the column
              // Source: https://api.flutter.dev/flutter/widgets/Spacer-class.html
              const Spacer(),
              _PrimaryButton(
                label: 'Browse Events',
                // Navigator.push - pushes a new route onto the navigation stack
                // Tutorial: https://www.geeksforgeeks.org/flutter-navigator/
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentScreen()),
                ),
              ),
              const SizedBox(height: 12),
              _OutlineButton(
                label: 'I\'m an Organization',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrgSignupScreen()),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                ),
                child: const Text(
                  'Already have an account? Sign in',
                  style: TextStyle(color: AppColors.subtle, fontSize: 14),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ElevatedButton - filled button for primary actions
// Tutorial: https://www.geeksforgeeks.org/flutter-elevatedbutton-widget/
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
    );
  }
}
// OutlinedButton - border-only button used for secondary actions
// Source: https://api.flutter.dev/flutter/material/OutlinedButton-class.html
class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
    );
  }
}
