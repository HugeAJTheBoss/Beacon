import 'package:flutter/material.dart';

import 'app_theme.dart';

import 'org_signup_screen.dart';
import 'signin_screen.dart';
import 'widgets/provider_mark.dart';

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



  Widget _buildProviderButton({
    required String label,
    required String assetPath,
    required String semanticLabel,
  }) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: ProviderMark(
                assetPath: assetPath,
                semanticLabel: semanticLabel,
              ),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navBar,
        foregroundColor: AppColors.ink,
        elevation: 0,
        title: const Text(
          'Register Organization',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide =
                constraints.maxWidth >= AppLayout.authWideBreakpoint;
            final horizontalPadding = isWide
                ? AppLayout.authHorizontalPaddingWide
                : AppLayout.authHorizontalPaddingNarrow;
            final availableWidth =
                constraints.maxWidth - (horizontalPadding * 2);
            final contentWidth = availableWidth > AppLayout.authChoiceCardMaxWidth
                ? AppLayout.authChoiceCardMaxWidth
                : availableWidth;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                AppLayout.authScreenTopPadding,
                horizontalPadding,
                AppLayout.authScreenBottomPadding,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: contentWidth > 0 ? contentWidth : constraints.maxWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          child: Image.asset(
                            AppAssets.stemLogoPlaceholder,
                            width: AppLayout.authLogoWidth,
                            height: AppLayout.authLogoHeight,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.medium,
                          ),
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
                        style: AppTextStyles.authHeroSubtitle,
                      ),
                      const SizedBox(height: 28),
                      Container(
                        padding: AppInsets.authCard,
                        decoration: AppSurfaces.authFormCard,
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
                              children: const [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'or',
                                    style: AppTextStyles.dividerCaption,
                                  ),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildProviderButton(
                              label: 'Continue with Google',
                              assetPath: AppAssets.googleLogo,
                              semanticLabel: 'Google',
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _buildProviderButton(
                              label: 'Continue with Microsoft',
                              assetPath: AppAssets.microsoftLogo,
                              semanticLabel: 'Microsoft',
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _buildProviderButton(
                              label: 'Continue with Apple',
                              assetPath: AppAssets.appleLogo,
                              semanticLabel: 'Apple',
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Already have a Beacon account? ',
                                  style: AppTextStyles.subtleAction,
                                ),
                                TextButton(
                                  onPressed: () => _openSignIn(context),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Log In',
                                    style: AppTextStyles.subtleAction.copyWith(
                                      color: AppColors.title,
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

                      const SizedBox(height: AppLayout.authScreenBottomGap),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
