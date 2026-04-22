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

  Future<void> _showStatusPopup({
    required String title,
    required String message,
    bool isError = false,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: isError ? Colors.red : AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
        _showStatusPopup(
          title: 'Sign In Failed',
          message: 'Check your email or password.',
          isError: true,
        );
      }
    } on PendingApprovalException {
      setState(() => _isLoading = false);
      if (!mounted) return;

      _showStatusPopup(
        title: 'Account Approval Pending',
        message:
            'Your organization account is still under review. We will email you once it is approved.',
      );
    } on AccountNotApprovedException {
      setState(() => _isLoading = false);
      if (!mounted) return;

      _showStatusPopup(
        title: 'Account Approval Pending',
        message:
            'Your organization account is still under review. We will email you once it is approved.',
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;

      _showStatusPopup(
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign In',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                const Text(
                  'Sign in to manage your organization.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.subtle,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 28),

                OutlinedButton.icon(
                  onPressed: _signInWithGoogle,
                  icon: const Icon(Icons.g_mobiledata, size: 24),
                  label: const Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.title,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or sign in with email',
                        style:
                            TextStyle(color: AppColors.subtle, fontSize: 13),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 20),



                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'you@example.com',
                    ),
                    validator: (val) =>
                        !val!.contains('@') ? 'Enter a valid email' : null,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
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
                            () => _passwordVisible = !_passwordVisible),
                      ),
                    ),
                    validator: (val) =>
                        val!.isEmpty ? 'Password is required' : null,
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {}, // TODO: forgot password flow
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                          color: AppColors.primary, fontSize: 13),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  child: const Text(
                    'Don\'t have an account? Sign up',
                    style: TextStyle(color: AppColors.subtle, fontSize: 14),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
