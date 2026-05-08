import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'org_register_choice_screen.dart';
import 'org_dashboard_screen.dart';
import 'services/auth_service.dart';

// Sign-in form for already-approved orgs.
// Form validation: https://www.geeksforgeeks.org/flutter/form-validation-in-flutter/
// AlertDialog basics: https://www.geeksforgeeks.org/flutter/alert-dialog-box-in-flutter/
// StatefulWidget: https://www.geeksforgeeks.org/flutter/flutter-stateful-widget/
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // GlobalKey<FormState> lets us call validate() across all the fields.
  // Tutorial: https://www.geeksforgeeks.org/flutter/form-validation-in-flutter/
  final _form_key = GlobalKey<FormState>();
  // TextEditingController gives us read/write access to the field's text.
  // Tutorial: https://www.geeksforgeeks.org/flutter/retrieve-data-from-textfields-in-flutter/
  final _email_controller = TextEditingController();
  final _password_controller = TextEditingController();

  bool _password_visible = false;
  bool _is_loading = false;

  // Shows a friendly status dialog. `isError` just swaps the OK button's color
  // so failed sign-ins read as red instead of brand green.
  // showDialog tutorial: https://www.geeksforgeeks.org/flutter/flutter-dialogs/
  Future<void> _showStatusDialog({
    required String title,
    required String message,
    bool isError = false,
  }) {
    final action_color = isError ? AppColors.destructive : AppColors.primary;
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
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
              backgroundColor: action_color,
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

  // Free up the controllers when the widget leaves the tree.
  // Tutorial: https://www.geeksforgeeks.org/flutter/flutter-dispose-method-with-example/
  @override
  void dispose() {
    _email_controller.dispose();
    _password_controller.dispose();
    super.dispose();
  }

  void _signIn() async {
    if (!_form_key.currentState!.validate()) return;
    setState(() => _is_loading = true);

    try {
      final user = await AuthService().loginOrg(
        email: _email_controller.text.trim(),
        password: _password_controller.text.trim(),
      );

      setState(() => _is_loading = false);
      if (!mounted) return;

      if (user != null) {
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
      setState(() => _is_loading = false);
      if (!mounted) return;
      _showStatusDialog(
        title: 'Account Approval Pending',
        message:
            'Your organization account is still under review. We will email you once it is approved.',
      );
    } on AccountNotApprovedException {
      setState(() => _is_loading = false);
      if (!mounted) return;
      _showStatusDialog(
        title: 'Account Approval Pending',
        message:
            'Your organization account is still under review. We will email you once it is approved.',
      );
    } catch (e) {
      setState(() => _is_loading = false);
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
    // Scaffold + AppBar give the page its standard structure.
    // Scaffold tutorial: https://www.geeksforgeeks.org/flutter/scaffold-class-in-flutter-with-examples/
    // AppBar tutorial: https://www.geeksforgeeks.org/flutter/flutter-appbar-widget/
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign in',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Form(
                key: _form_key,
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
                      controller: _email_controller,
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
                      controller: _password_controller,
                      obscureText: !_password_visible,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _password_visible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.subtle,
                          ),
                          onPressed: () => setState(
                            () => _password_visible = !_password_visible,
                          ),
                        ),
                      ),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Sign in button
                    ElevatedButton(
                      onPressed: _is_loading ? null : _signIn,
                      child: _is_loading
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
