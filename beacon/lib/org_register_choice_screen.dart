import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'org_signup_screen.dart';
import 'signin_screen.dart';

// Lets a new org pick how to start their account (currently just email).
// Material design widgets: https://www.geeksforgeeks.org/flutter/flutter-material-design/
// Routes and Navigator: https://www.geeksforgeeks.org/flutter/routes-and-navigator-in-flutter/
// StatelessWidget: https://www.geeksforgeeks.org/flutter/flutter-stateless-widget/
class OrgRegisterChoiceScreen extends StatelessWidget {
  const OrgRegisterChoiceScreen({super.key});

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
    // Scaffold tutorial: https://www.geeksforgeeks.org/flutter/scaffold-class-in-flutter-with-examples/
    // AppBar tutorial: https://www.geeksforgeeks.org/flutter/flutter-appbar-widget/
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Register Organization',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
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

                  // Card with the two account-creation paths.
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
