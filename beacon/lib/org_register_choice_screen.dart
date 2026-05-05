// Flutter Material widgets such as MaterialApp, Scaffold, AppBar, Buttons inspired by https://www.geeksforgeeks.org/flutter/flutter-material-design/
import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'org_signup_screen.dart';
import 'signin_screen.dart';

// StatelessWidget: https://www.geeksforgeeks.org/flutter/flutter-stateless-widget/
class OrgRegisterChoiceScreen extends StatelessWidget {
  const OrgRegisterChoiceScreen({super.key});

  // Navigator.push (route to a new screen): https://www.geeksforgeeks.org/routes-and-navigator-in-flutter/
  void _openEmailForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OrgSignupScreen()),
    );
  }

  void _openSignIn(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold (basic page structure): https://www.geeksforgeeks.org/flutter/scaffold-class-in-flutter-with-examples/
    return Scaffold(
      // AppBar (top navigation bar UI): https://www.geeksforgeeks.org/flutter/flutter-appbar-widget/
      appBar: AppBar(
        title: const Text(
          'Register Organization',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      // SafeArea (avoid system UI intrusions): https://www.geeksforgeeks.org/flutter/flutter-safearea-widget/
      body: SafeArea(
        child: Center(
          // ConstrainedBox (limit widget dimensions): https://www.geeksforgeeks.org/flutter/constrainedbox-widget-in-flutter/
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            // SingleChildScrollView (scrollable content): https://www.geeksforgeeks.org/flutter/flutter-scrollable-text/
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  // ClipRRect (rounded clipping of child widgets): https://www.geeksforgeeks.org/cliprrect-widget-in-flutter/
                  Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      AppAssets.beaconLogo,
                      width: 160,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Create your organization',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Bring your events to your community',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      color: AppColors.subtle,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Card
                  // Container (layout + styling wrapper): https://www.geeksforgeeks.org/flutter/flutter-working-with-layouts/
                  // BoxDecoration (borders, radius, shadows): https://www.geeksforgeeks.org/flutter/flutter-boxdecoration-class/
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ink.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ElevatedButton (primary action button): https://www.geeksforgeeks.org/flutter/flutter-elevatedbutton-widget/
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () => _openEmailForm(context),
                            child: const Text(
                              'Continue with your email address',
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Row and Column layout: https://www.geeksforgeeks.org/dart/row-and-column-widgets-in-flutter-with-example/
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have a Beacon account? ',
                              style: TextStyle(
                                color: AppColors.subtle,
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () => _openSignIn(context),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  color: AppColors.title,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
