// Tutorials/sources used for this screen:
// StatefulWidget basics:          https://www.geeksforgeeks.org/flutter-stateful-vs-stateless-widgets/
// Form validation pattern:        https://docs.flutter.dev/cookbook/forms/validation
// AlertDialog usage:              https://www.geeksforgeeks.org/flutter-alertdialog-widget/
// Navigator push/pop patterns:    https://www.geeksforgeeks.org/flutter-navigator/
// TextFormField usage:            https://www.geeksforgeeks.org/flutter-textformfield/
// Password visibility pattern:    https://www.geeksforgeeks.org/flutter-show-hide-password-in-textfield/
// Circular progress indicator:    https://www.geeksforgeeks.org/flutter-circular-progress-indicator/
// mounted check (needed):         https://api.flutter.dev/flutter/widgets/BuildContext/mounted.html

import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'org_register_choice_screen.dart';
import 'org_dashboard_screen.dart';
import 'services/auth_service.dart';

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

  // showDialog - displays a Material dialog above the current screen
  // Tutorial: https://www.geeksforgeeks.org/flutter-alertdialog-widget/
  Future<void> _showStatusDialog({
    required String title,
    required String message,
    bool isError = false,
  }) {
    final actionColor = isError ? AppColors.destructive : AppColors.primary;
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        // RoundedRectangleBorder - gives the dialog rounded corners
        // Source: https://api.flutter.dev/flutter/painting/RoundedRectangleBorder-class.html
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.title,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.subtle, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: actionColor,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: const StadiumBorder(),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
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
    // Controllers must be disposed to free memory when the widget is removed
    // Source: https://api.flutter.dev/flutter/widgets/TextEditingController/dispose.html
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    // _formKey.currentState!.validate() - runs all validator functions in the Form
    // Source: https://api.flutter.dev/flutter/widgets/FormState/validate.html
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = await AuthService().loginOrg(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      setState(() => _isLoading = false);
      if (!mounted) return; // prevents acting on a disposed widget

      if (user != null) {
        // Navigator.pushReplacement - replaces the current route so the user can't go back
        // Source: https://api.flutter.dev/flutter/widgets/NavigatorState/pushReplacement.html
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OrgDashboardScreen()),
        );
      } else {
        _showStatusDialog(
          title: 'Sign In Failed',
          message: 'Check your email or password.',
          isError: true,
        );
      }
    } on PendingApprovalException {
      setState(() => _isLoading = false);
      if (!mounted) return;
      _showStatusDialog(
        title: 'Account Approval Pending',
        message:
            'Your organization account is still under review. We will email you once it is approved.',
      );
    } on AccountNotApprovedException {
      setState(() => _isLoading = false);
      if (!mounted) return;
      _showStatusDialog(
        title: 'Account Approval Pending',
        message:
            'Your organization account is still under review. We will email you once it is approved.',
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      _showStatusDialog(
        title: 'Sign In Failed',
        message: 'Something is wrong with your email or password.',
        isError: true,
      );
    }
  }

  void _signInWithGoogle() {
    // TODO: implement Google Sign-In + same role check as above
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold - provides the basic Material Design page structure (appbar, body, etc.)
    // Tutorial: https://www.geeksforgeeks.org/flutter-scaffold-widget/
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign in',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      // SafeArea - prevents content from being hidden behind notches or system UI
      // Source: https://api.flutter.dev/flutter/widgets/SafeArea-class.html
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            // SingleChildScrollView - makes the form scrollable when the keyboard is open
            // Tutorial: https://www.geeksforgeeks.org/flutter-single-child-scroll-view/
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              // Form - groups TextFormFields and manages validation together
              // Tutorial: https://docs.flutter.dev/cookbook/forms/validation
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Align(
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        child: Image.asset(
                          AppAssets.stemLogoPlaceholder,
                          width: 180,
                          height: 110,
                          fit: BoxFit.cover,
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
                      style: TextStyle(
                        fontSize: 17,
                        color: AppColors.subtle,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Form card
                    // Container with BoxDecoration - rounded corners and a soft drop shadow
                    // Tutorial: https://www.geeksforgeeks.org/flutter-container-widget/
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
                          // Google sign-in button
                          // OutlinedButton - border-only button used for secondary actions
                          // Source: https://api.flutter.dev/flutter/material/OutlinedButton-class.html
                          SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              onPressed: _signInWithGoogle,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Image.asset(
                                      AppAssets.googleLogo,
                                      width: AppLayout.providerMarkSize,
                                      height: AppLayout.providerMarkSize,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const Text('Continue with Google'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Divider
                          // Row with Dividers - common Flutter pattern for an "or" separator line
                          // Tutorial: https://www.geeksforgeeks.org/flutter-divider-widget/
                          const Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'or continue with email',
                                  style: TextStyle(
                                    color: AppColors.subtle,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Email field
                          // TextFormField - a text input that integrates with Form validation
                          // Tutorial: https://www.geeksforgeeks.org/flutter-textformfield/
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [
                                AutofillHints.username,
                                AutofillHints.email,
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                hintText: 'you@example.com',
                              ),
                              validator: _validateEmail,
                            ),
                          ),

                          // Password field
                          // obscureText - hides password characters
                          // Tutorial: https://www.geeksforgeeks.org/flutter-show-hide-password-in-textfield/
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: !_passwordVisible, // toggles password visibility
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              decoration: InputDecoration(
                                labelText: 'Password',
                                // suffixIcon with IconButton - tapping the eye icon toggles visibility
                                // Source: https://api.flutter.dev/flutter/material/IconButton-class.html
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.subtle,
                                  ),
                                  onPressed: () => setState(
                                    () => _passwordVisible = !_passwordVisible,
                                  ),
                                ),
                              ),
                              validator: _validatePassword,
                            ),
                          ),

                          // Forgot password
                          // TextButton - flat button used for low-emphasis actions
                          // Tutorial: https://www.geeksforgeeks.org/flutter-textbutton-widget/
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {}, // TODO: forgot password flow
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: AppColors.subtle,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // Sign in button
                          // ElevatedButton - filled button for primary actions
                          // Tutorial: https://www.geeksforgeeks.org/flutter-elevatedbutton-widget/
                          ElevatedButton(
                            onPressed: _isLoading ? null : _signIn,
                            // CircularProgressIndicator - spinner shown while the async sign-in runs
                            // Tutorial: https://www.geeksforgeeks.org/flutter-circular-progress-indicator/
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: AppColors.onPrimary,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Sign in'),
                          ),
                          const SizedBox(height: 16),

                          // Register link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Need an account? ',
                                style: TextStyle(
                                  color: AppColors.subtle,
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                // Navigator.push - pushes a new route onto the navigation stack
                                // Tutorial: https://www.geeksforgeeks.org/flutter-navigator/
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
                                child: const Text(
                                  'Register organization',
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
                          const SizedBox(height: AppSpacing.sm),
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
      ),
    );
  }
}
