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

// StatefulWidget: https://www.geeksforgeeks.org/flutter/flutter-stateful-widget/
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // GlobalKey<FormState> (identify and validate a Form): https://www.geeksforgeeks.org/flutter-form-validation/
  final _formKey = GlobalKey<FormState>();
  // TextEditingController (read and control TextField input): https://www.geeksforgeeks.org/retrieve-data-from-textfields-in-flutter/
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // bool state variables to track UI state: https://www.geeksforgeeks.org/dart/dart-data-types/
  bool _passwordVisible = false;
  bool _isLoading = false;

  // showDialog / AlertDialog (modal dialog for status messages): https://www.geeksforgeeks.org/flutter/flutter-alertdialog-widget/
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

  // dispose() for memory leak prevention: https://www.geeksforgeeks.org/flutter/flutter-dispose-method-with-example/
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // async/await and try-catch for error handling: https://www.geeksforgeeks.org/using-await-async-in-dart/
  void _signIn() async {
    // Form validation: https://www.geeksforgeeks.org/flutter-form-validation/
    if (!_formKey.currentState!.validate()) return;
    // setState (trigger UI rebuild): https://www.geeksforgeeks.org/flutter/flutter-state-management/
    setState(() => _isLoading = true);

    try {
      final user = await AuthService().loginOrg(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      setState(() => _isLoading = false);
      if (!mounted) return;

      if (user != null) {
        // Navigator.pushReplacement (replace current route): https://www.geeksforgeeks.org/routes-and-navigator-in-flutter/
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

  @override
  Widget build(BuildContext context) {
    // Scaffold (basic page structure): https://www.geeksforgeeks.org/flutter/scaffold-class-in-flutter-with-examples/
    return Scaffold(
      // AppBar (top navigation bar): https://www.geeksforgeeks.org/flutter/flutter-appbar-widget/
      appBar: AppBar(
        title: const Text(
          'Sign in',
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
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
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
                    const SizedBox(height: AppSpacing.xl),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'contact@yourorg.org',
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 20),

                    // Password field with visibility toggle
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      textInputAction: TextInputAction.done,
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
                            () => _passwordVisible = !_passwordVisible,
                          ),
                        ),
                      ),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Sign in button
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
                          : const Text('Sign In'),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Don\'t have an account? ',
                          style: TextStyle(
                            color: AppColors.subtle,
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const OrgRegisterChoiceScreen(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Sign Up',
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
            ),
          ),
        ),
      ),
    );
  }
}
