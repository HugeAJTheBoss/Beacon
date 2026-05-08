// Entry point and welcome screen for Beacon.
// Firebase setup reference: https://firebase.google.com/docs/flutter/setup
// Material design widgets in Flutter: https://www.geeksforgeeks.org/flutter/flutter-material-design/

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app_theme.dart';
import 'firebase_options.dart';
import 'student_screen.dart';
import 'org_register_choice_screen.dart';
import 'signin_screen.dart';
import 'org_dashboard_screen.dart';
import 'services/auth_service.dart';
import 'preferences_service.dart';


// Static marketing copy for the welcome carousel (not Firestore data).
const List<Map<String, String>> _featuredHighlights = [
  {
    'title': 'Robotics Clubs',
    'subtitle':
        'Hands-on learning opportunities for middle and high school students.',
    'image': AppAssets.roboticsClub,
  },
  {
    'title': 'STEM Volunteering',
    'subtitle':
        'Find programs where you can mentor and support younger learners.',
    'image': AppAssets.volunteeringClub,
  },
  {
    'title': 'Club Spotlights',
    'subtitle':
        'Explore recurring clubs in engineering, coding, biology, and math.',
    'image': AppAssets.club,
  },
];


void main() async {
  // ensureInitialized must run before any plugin call (e.g. Firebase).
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const BeaconApp());
}

// MaterialApp wires up routing, theming, and the home widget.
// Tutorial: https://www.geeksforgeeks.org/flutter/materialapp-class-in-flutter/
// StatelessWidget: https://www.geeksforgeeks.org/flutter/flutter-stateless-widget/
class BeaconApp extends StatelessWidget {
  const BeaconApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beacon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const _StartupGate(),
    );
  }
}


// Decides which screen to show on launch based on saved prefs and auth state.
class _StartupGate extends StatelessWidget {
  const _StartupGate();

  Future<Widget> _resolveInitialScreen() async {
    final restoreStudent = await PreferencesService.shouldRestoreStudentOnLaunch();
    if (restoreStudent) return const _RestoreStudentEntry();

    final approvedUser = await AuthService().getApprovedCurrentUser();
    if (approvedUser != null) {
      final restoreOrg = await PreferencesService.shouldRestoreOrgOnLaunch();
      if (restoreOrg) return const _RestoreOrgEntry();
    }

    return const WelcomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    // FutureBuilder rebuilds the UI whenever its Future resolves.
    // Tutorial: https://www.geeksforgeeks.org/flutter/flutter-futurebuilder-widget/
    return FutureBuilder<Widget>(
      future: _resolveInitialScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snapshot.data ?? const WelcomeScreen();
      },
    );
  }
}

// Pushes the StudentScreen once after the first frame so the WelcomeScreen
// stays beneath it in the navigator stack (lets the user back out to home).
// StatefulWidget basics: https://www.geeksforgeeks.org/flutter/flutter-stateful-widget/
// Routes and Navigator: https://www.geeksforgeeks.org/flutter/routes-and-navigator-in-flutter/
class _RestoreStudentEntry extends StatefulWidget {
  const _RestoreStudentEntry();
  @override
  State<_RestoreStudentEntry> createState() => _RestoreStudentEntryState();
}

class _RestoreStudentEntryState extends State<_RestoreStudentEntry> {
  bool _pushed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pushed) return;
    _pushed = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentScreen()));
    });
  }

  @override
  Widget build(BuildContext context) => const WelcomeScreen();
}

// Same idea as _RestoreStudentEntry but for the org dashboard.
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
      Navigator.push(context, MaterialPageRoute(builder: (_) => const OrgDashboardScreen()));
    });
  }

  @override
  Widget build(BuildContext context) => const WelcomeScreen();
}


class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _highlightsPageController = PageController(viewportFraction: 0.88);
  int _activeHighlightIndex = 0;

  // Controllers must be disposed to free their resources.
  // Tutorial: https://www.geeksforgeeks.org/flutter/flutter-dispose-method-with-example/
  @override
  void dispose() {
    _highlightsPageController.dispose();
    super.dispose();
  }

  void _browseEvents() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentScreen()));
  }

  void _registerOrganization() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const OrgRegisterChoiceScreen()));
  }

  void _signIn() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const SignInScreen()));
  }

  void _handleMenuSelection(String menuAction) {
    if (menuAction == 'register') {
      _registerOrganization();
      return;
    }
    if (menuAction == 'signin') _signIn();
  }

  Widget _buildHeroSection(BuildContext context, {required bool wide}) {
    final titleStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
      fontSize: wide ? 48 : 36,
      height: 1.08,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Find STEM volunteering opportunities, clubs, events, and more near you',
          style: titleStyle,
        ),
        const SizedBox(height: 18),
        Text(
          'Discover local programs across Massachusetts and help shape the next generation of STEM leaders.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.subtle,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery exposes screen dimensions for responsive layout.
    // Tutorial: https://www.geeksforgeeks.org/flutter/flutter-managing-the-mediaquery-object/
    final isTablet = MediaQuery.of(context).size.width >= AppLayout.tabletBreakpoint;

    // Scaffold gives us the standard app bar + body shell.
    // Tutorial: https://www.geeksforgeeks.org/flutter/scaffold-class-in-flutter-with-examples/
    // AppBar: https://www.geeksforgeeks.org/flutter/flutter-appbar-widget/
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Beacon | SHAPING FUTURES, ONE EVENT AT A TIME',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (isTablet) ...[
            _NavPrimaryButton(label: 'Browse Events', onTap: _browseEvents),
            const SizedBox(width: AppSpacing.sm),
            _NavSecondaryButton(label: 'Register Organization', onTap: _registerOrganization),
            const SizedBox(width: 6),
            TextButton(onPressed: _signIn, child: const Text('Sign In')),
            const SizedBox(width: AppSpacing.sm),
          ] else ...[
            // TextButton: https://www.geeksforgeeks.org/flutter/flutter-textbutton-widget/
            TextButton(onPressed: _browseEvents, child: const Text('Browse')),
            // PopupMenuButton (overflow menu): https://www.geeksforgeeks.org/flutter/flutter-pop-up-menu/
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu_rounded),
              onSelected: _handleMenuSelection,
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'register', child: Text('Register Organization')),
                PopupMenuItem(value: 'signin', child: Text('Sign In')),
              ],
            ),
          ],
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= AppLayout.desktopBreakpoint;
          final isTabletLayout = constraints.maxWidth >= AppLayout.tabletBreakpoint;
          final contentHorizontalPadding = isDesktop
              ? 48.0
              : (isTabletLayout ? 28.0 : AppSpacing.lg);

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              contentHorizontalPadding,
              28,
              contentHorizontalPadding,
              28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: _buildHeroSection(context, wide: true)),
                      const SizedBox(width: 30),
                      const Expanded(flex: 5, child: _HeroGraphicCard(height: 410)),
                    ],
                  )
                else ...[
                  _buildHeroSection(context, wide: false),
                  const SizedBox(height: 24),
                  _HeroGraphicCard(height: isTabletLayout ? 320 : 240),
                ],
                const SizedBox(height: 34),
                Text(
                  'Featured Opportunities',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                // PageView is a swipeable horizontal carousel.
                // Tutorial: https://www.geeksforgeeks.org/dart/pageview-widget-in-flutter/
                SizedBox(
                  height: isDesktop ? 210 : 190,
                  child: PageView.builder(
                    controller: _highlightsPageController,
                    itemCount: _featuredHighlights.length,
                    onPageChanged: (index) {
                      setState(() => _activeHighlightIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return _CarouselCard(
                        title: _featuredHighlights[index]['title']!,
                        subtitle: _featuredHighlights[index]['subtitle']!,
                        image: _featuredHighlights[index]['image']!,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _featuredHighlights.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _activeHighlightIndex == index ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _activeHighlightIndex == index
                            ? AppColors.primary
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(AppRadii.xl),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


class _NavPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavPrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppLayout.navBarActionButtonHeight,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// OutlinedButton tutorial: https://www.geeksforgeeks.org/flutter/flutter-material-widget-outlined-button-class/
class _NavSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavSecondaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppLayout.navBarActionButtonHeight,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.card,
          foregroundColor: AppColors.title,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _HeroGraphicCard extends StatelessWidget {
  final double height;
  const _HeroGraphicCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              AppAssets.stemLogoPlaceholder,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.12),
                    AppColors.ink.withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Single card used in the featured-opportunities carousel.
// Row + Column layout: https://www.geeksforgeeks.org/dart/row-and-column-widgets-in-flutter-with-example/
class _CarouselCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  const _CarouselCard({
    required this.title,
    required this.subtitle,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.card),
        color: AppColors.heroTint,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppRadii.card)),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                height: double.infinity,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
