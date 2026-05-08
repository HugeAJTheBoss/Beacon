import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'signin_screen.dart';
import 'services/auth_service.dart';

// Email-based signup form for new orgs. The form runs through standard
// validators before handing the data off to AuthService.registerOrg.
// Form tutorial: https://www.geeksforgeeks.org/flutter/flutter-build-a-form/
// Validation tutorial: https://www.geeksforgeeks.org/flutter/form-validation-in-flutter/
// StatefulWidget: https://www.geeksforgeeks.org/flutter/flutter-stateful-widget/
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

  // dispose() releases the text controllers' resources.
  // Tutorial: https://www.geeksforgeeks.org/flutter/flutter-dispose-method-with-example/
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _websiteController.dispose();
    _einController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() async {
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
    if (!mounted) return;
    // Replace so the user can't navigate back into the form after submission.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PendingApprovalScreen()),
    );
  }

  void _signUpWithGoogle() {
    // TODO: implement Google Sign-In
  }

  String? _validateOrgEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';

    // Simplified RFC 5322-ish pattern. Catches the obvious typos without
    // pretending to be a full spec-compliant validator.
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    // Reject the most common personal-email domains so orgs don't sign up
    // with a Gmail/Yahoo address.
    final commonPersonalDomains = ['gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com', 'aol.com'];
    final domain = email.split('@').last.toLowerCase();
    if (commonPersonalDomains.contains(domain)) {
      return 'Please use your organization email, not a personal email';
    }

    return null;
  }

  String? _validateRegistrationNumber(String? value) {
    final regNum = value?.trim() ?? '';
    if (regNum.isEmpty) return 'Registration number is required';

    // Accept a few common formats: 12-3456789, 123456789, XX-XXXXXXX, etc.
    final cleanedNum = regNum.replaceAll('-', '').replaceAll(RegExp(r'\s'), '');
    if (cleanedNum.length < 7 || cleanedNum.length > 15) {
      return 'Registration number should be 7-15 characters';
    }

    if (!RegExp(r'[a-zA-Z0-9]').hasMatch(cleanedNum)) {
      return 'Registration number must contain alphanumeric characters';
    }

    return null;
  }

  String? _validateWebsiteUrl(String? value) {
    final url = value?.trim() ?? '';
    if (url.isEmpty) return 'Website URL is required';

    final normalizedUrl = url.startsWith('http://') || url.startsWith('https://')
        ? url
        : 'https://$url';

    final uri = Uri.tryParse(normalizedUrl);
    if (uri == null || uri.host.isEmpty) {
      return 'Enter a valid website URL';
    }

    if (!uri.host.contains('.')) {
      return 'Domain must contain at least one dot (e.g., example.com)';
    }

    return null;
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
        // Scrollable so the form stays usable when the keyboard pops up.
        // SingleChildScrollView usage: https://www.geeksforgeeks.org/flutter/flutter-scrollable-text/
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
                // OutlinedButton tutorial: https://www.geeksforgeeks.org/flutter/flutter-material-widget-outlined-button-class/
                OutlinedButton.icon(
                  onPressed: _signUpWithGoogle,
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
                // "or sign up with email" divider row.
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
                  validator: (val) => _validateOrgEmail(val),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
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
                  validator: (val) => _validateWebsiteUrl(val),
                ),
                _FormField(
                  controller: _einController,
                  label: 'EIN / Registration Number',
                  hint: 'e.g. 12-3456789',
                  validator: (val) => _validateRegistrationNumber(val),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
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

// Reusable TextFormField wrapper so we don't repeat the same decoration
// boilerplate at every field.
// TextFormField + validation walkthrough: https://www.geeksforgeeks.org/flutter/form-validation-in-flutter/
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                // popUntil(...isFirst) returns the user all the way back to the
                // welcome screen.
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
