import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'org_register_choice_screen.dart';
import 'org_dashboard_screen.dart';
import 'services/auth_service.dart';
import 'widgets/app_form_field.dart';
import 'widgets/provider_mark.dart';
import 'widgets/status_dialog.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _passwordVisible = false;
  bool _isLoading = false;



  Future<void> _showSignInStatusDialog({
    required String title,
    required String message,
    bool isError = false,
  }) {
    return showStatusDialog(
      context: context,
      title: title,
      message: message,
      isError: isError,
      messageLineHeight: 1.5,
    );
  }



  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    if (!email.contains('@') || !email.contains('.')) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value?.trim() ?? '';
    if (password.isEmpty) return 'Password is required';
    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = await AuthService().loginOrg(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      setState(() => _isLoading = false);
      if (!mounted) return;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const OrgDashboardScreen(),
          ),
        );
      } else {
        _showSignInStatusDialog(
          title: 'Sign In Failed',
          message: 'Invalid email or password.',
          isError: true,
        );
      }
    } on PendingApprovalException {
      setState(() => _isLoading = false);
      if (!mounted) return;
      _showSignInStatusDialog(
        title: 'Account Pending',
        message: 'Your organization application is still under review.',
        isError: true,
      );
    } on AccountNotApprovedException {
      setState(() => _isLoading = false);
      if (!mounted) return;
      _showSignInStatusDialog(
        title: 'Account Not Approved',
        message: 'Your organization account is not approved for access.',
        isError: true,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      _showSignInStatusDialog(
        title: 'Error',
        message: 'An unexpected error occurred. Please try again.',
        isError: true,
      );
    }
  }

  void _signInWithGoogle() {
    // TODO: implement Google Sign-In + same role check as above
  }

  Widget _buildProviderButton() {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: _signInWithGoogle,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: const [
            Align(
              alignment: Alignment.centerLeft,
              child: ProviderMark(
                assetPath: AppAssets.googleLogo,
                semanticLabel: 'Google',
              ),
            ),
            Text('Continue with Google'),
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
          'Sign in',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= AppLayout.authWideBreakpoint;
            final horizontalPadding = isWide
                ? AppLayout.authHorizontalPaddingWide
                : AppLayout.authHorizontalPaddingNarrow;
            final availableWidth =
                constraints.maxWidth - (horizontalPadding * 2);
            final contentWidth =
              availableWidth > AppLayout.authChoiceCardMaxWidth
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
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
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
                          'Sign in to your organization',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Text(
                          'Use your approved organization account credentials.',
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
                              _buildProviderButton(),
                              const SizedBox(height: AppSpacing.lg),
                              Row(
                                children: const [
                                  Expanded(child: Divider()),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      'or continue with email',
                                      style: AppTextStyles.dividerCaption,
                                    ),
                                  ),
                                  Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              AppFormField(
                                controller: _emailController,
                                label: 'Email',
                                hint: 'you@example.com',
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.username,
                                  AutofillHints.email,
                                ],
                                validator: _validateEmail,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_passwordVisible,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [AutofillHints.password],
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _passwordVisible
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: AppColors.subtle,
                                      ),
                                      onPressed: () => setState(
                                        () => _passwordVisible =
                                            !_passwordVisible,
                                      ),
                                    ),
                                  ),
                                  validator: _validatePassword,
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed:
                                      () {}, // TODO: forgot password flow
                                  child: const Text(
                                    'Forgot password?',
                                    style: AppTextStyles.subtleActionSmall,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              ElevatedButton(
                                onPressed: _isLoading ? null : _signIn,
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: AppColors.onPrimary,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Sign in',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Need an account? ',
                                    style: AppTextStyles.subtleAction,
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const OrgRegisterChoiceScreen(),
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Register organization',
                                      style: AppTextStyles.subtleAction.copyWith(
                                        color: AppColors.title,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),

                            ],
                          ),
                        ),
                        const SizedBox(height: AppLayout.authScreenBottomGap),
                      ],
                    ),
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
