import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'signin_screen.dart';
import 'services/auth_service.dart';

class OrgSignupScreen extends StatefulWidget {
  const OrgSignupScreen({super.key});

  @override
  State<OrgSignupScreen> createState() => _OrgSignupScreenState();
}

class _OrgSignupScreenState extends State<OrgSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _websiteController = TextEditingController();
  final _einController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _passwordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    // Controllers must be disposed to free memory when the widget is removed
    // Source: https://api.flutter.dev/flutter/widgets/TextEditingController/dispose.html
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _websiteController.dispose();
    _einController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    // _formKey.currentState!.validate() - runs all validator functions in the Form
    // Source: https://api.flutter.dev/flutter/widgets/FormState/validate.html
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    await AuthService().registerOrg(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      orgName: _nameController.text.trim(),
      webURL: _websiteController.text.trim(),
      regNumber: _einController.text.trim(),
      orgDescription: _descriptionController.text.trim(),
    );

    setState(() => _isLoading = false);
    if (!mounted) return; // prevents acting on a disposed widget
    // Navigator.pushReplacement - replaces the current route so the user can't go back to the form
    // Source: https://api.flutter.dev/flutter/widgets/NavigatorState/pushReplacement.html
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PendingApprovalScreen()),
    );
  }

  void _signUpWithGoogle() {
    // TODO: implement Google Sign-In
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Register Organization',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        // SingleChildScrollView - makes the form scrollable when the keyboard is open
        // Tutorial: https://www.geeksforgeeks.org/flutter-single-child-scroll-view/
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Tell us about your organization.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.subtle,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                // OutlinedButton.icon - outlined button with a leading icon
                // Tutorial: https://www.geeksforgeeks.org/flutter-outlinedbutton-widget/
                OutlinedButton.icon(
                  onPressed: _signUpWithGoogle,
                  icon: const Icon(Icons.g_mobiledata, size: 24),
                  label: const Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.title,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    // RoundedRectangleBorder - gives the button rounded corners
                    // Source: https://api.flutter.dev/flutter/painting/RoundedRectangleBorder-class.html
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
                const SizedBox(height: 20),
                // Row with Dividers - common Flutter pattern for an "or" separator line
                // Tutorial: https://www.geeksforgeeks.org/flutter-divider-widget/
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or sign up with email',
                        style:
                            TextStyle(color: AppColors.subtle, fontSize: 13),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                _FormField(
                  controller: _nameController,
                  label: 'Organization Name',
                  hint: 'e.g. Worcester Robotics Club',
                  validator: (val) =>
                      val!.isEmpty ? 'Organization name is required' : null,
                ),
                _FormField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'contact@yourorg.org',
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) =>
                      !val!.contains('@') ? 'Enter a valid email' : null,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  // TextFormField with obscureText - hides password characters
                  // Tutorial: https://www.geeksforgeeks.org/flutter-textformfield/
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible, // toggles password visibility
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
                            () => _passwordVisible = !_passwordVisible),
                      ),
                    ),
                    validator: (val) => val!.length < 6
                        ? 'Password must be at least 6 characters'
                        : null,
                  ),
                ),
                _FormField(
                  controller: _websiteController,
                  label: 'Website URL',
                  hint: 'https://yourorg.org',
                  keyboardType: TextInputType.url,
                  validator: (val) =>
                      val!.isEmpty ? 'Website URL is required' : null,
                ),
                _FormField(
                  controller: _einController,
                  label: 'EIN / Registration Number',
                  hint: 'e.g. 12-3456789',
                  validator: (val) =>
                      val!.isEmpty ? 'Registration number is required' : null,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  // Container with withValues(alpha:) - tinted info banner using primary color at low opacity
                  // Source: https://api.flutter.dev/flutter/dart-ui/Color/withValues.html
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 16, color: AppColors.primary),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your email and password will be used to sign in after approval.',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.primary,
                                height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _FormField(
                  controller: _descriptionController,
                  label: 'Organization Description',
                  hint: 'What does your organization do? Who is it for?',
                  maxLines: 4,
                  validator: (val) =>
                      val!.isEmpty ? 'Please add a description' : null,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your organization will be reviewed before being listed on Beacon. This typically takes 1–3 business days.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.subtle,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  // CircularProgressIndicator - spinner shown while the async submit is running
                  // Tutorial: https://www.geeksforgeeks.org/flutter-circular-progress-indicator/
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
                          'Submit for Review',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
                const SizedBox(height: 16),
                // TextButton - flat button used for low-emphasis actions
                // Tutorial: https://www.geeksforgeeks.org/flutter-textbutton-widget/
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Reusable TextFormField wrapper to avoid repeating decoration boilerplate (DRY principle)
// Source: https://dart.dev/effective-dart/design
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?) validator;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      // TextFormField - a text input that integrates with Form validation
      // Tutorial: https://docs.flutter.dev/cookbook/forms/validation
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
        validator: validator,
      ),
    );
  }
}

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          // Column with mainAxisAlignment.center - centers content vertically on the screen
          // Tutorial: https://www.geeksforgeeks.org/flutter-column-widget/
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon widget - displays a Material icon at a given size and color
              // Tutorial: https://www.geeksforgeeks.org/flutter-icon-widget/
              const Icon(
                Icons.hourglass_top_rounded,
                size: 72,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'Application Submitted',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.title,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'We\'re reviewing your organization. You\'ll receive an email within 1–3 business days once you\'ve been approved.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.subtle,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                // Navigator.popUntil - pops all routes until the very first screen is reached
                // Source: https://api.flutter.dev/flutter/widgets/NavigatorState/popUntil.html
                onPressed: () =>
                    Navigator.popUntil(context, (r) => r.isFirst),
                child: const Text(
                  'Back to Home',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}