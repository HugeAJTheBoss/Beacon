// Sources also used in previous files
// StatefulWidget/StatelessWidget: https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html
// TextEditingController:          https://api.flutter.dev/flutter/widgets/TextEditingController-class.html
// GlobalKey<FormState>/validate(): https://api.flutter.dev/flutter/widgets/FormState-class.html
// Navigator/MaterialPageRoute:    https://api.flutter.dev/flutter/widgets/Navigator/push.html
// ElevatedButton/OutlinedButton:  https://api.flutter.dev/flutter/material/ElevatedButton-class.html
// Scaffold/AppBar:                https://api.flutter.dev/flutter/material/Scaffold-class.html
// setState/mounted/dispose:       https://api.flutter.dev/flutter/widgets/State/setState.html
// SafeArea:                       https://api.flutter.dev/flutter/widgets/SafeArea-class.html
// Form:                           https://api.flutter.dev/flutter/widgets/Form-class.html
// InputDecoration:                https://api.flutter.dev/flutter/material/InputDecoration-class.html

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

  void _openSignInScreen() {
    // Navigator.push - pushes a new route onto the navigation stack
    // Tutorial: https://www.geeksforgeeks.org/flutter-navigator/
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

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

  String? _validateOrganizationName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Organization name is required';
    return null;
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
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateWebsiteUrl(String? value) {
    final website = value?.trim() ?? '';
    if (website.isEmpty) return 'Website URL is required';

    final normalizedWebsite =
        website.startsWith('http://') || website.startsWith('https://')
        ? website
        : 'https://$website';
    final uri = Uri.tryParse(normalizedWebsite);
    if (uri == null || uri.host.isEmpty) {
      return 'Enter a valid website URL';
    }
    return null;
  }

  String? _validateRegistrationNumber(String? value) {
    final registrationNumber = value?.trim() ?? '';
    if (registrationNumber.isEmpty) return 'Registration number is required';
    return null;
  }

  String? _validateDescription(String? value) {
    final description = value?.trim() ?? '';
    if (description.isEmpty) return 'Please add a description';
    return null;
  }

  /// Builds a standard form text field with bottom spacing.
  // Reusable TextFormField wrapper to avoid repeating decoration boilerplate (DRY principle)
  // Source: https://dart.dev/effective-dart/design
  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      // TextFormField - a text input that integrates with Form validation
      // Tutorial: https://docs.flutter.dev/cookbook/forms/validation
      child: TextFormField(
        controller: controller,
        keyboardType: maxLines > 1 ? TextInputType.multiline : keyboardType,
        textInputAction:
            maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, hintText: hint),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold - provides the basic Material Design page structure (appbar, body, etc.)
    // Tutorial: https://www.geeksforgeeks.org/flutter-scaffold-widget/
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Register Organization',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      // SafeArea - prevents content from being hidden behind notches or system UI
      // Source: https://api.flutter.dev/flutter/widgets/SafeArea-class.html
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
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
                    // Info panel
                    // Container with BoxDecoration - rounded corners + light tint background
                    // Tutorial: https://www.geeksforgeeks.org/flutter-container-widget/
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.heroTint.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(AppRadii.panel),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon widget - displays a Material icon at a given size and color
                          // Tutorial: https://www.geeksforgeeks.org/flutter-icon-widget/
                          Icon(
                            Icons.apartment_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Create your organization profile for review.',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.subtle,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Form card
                    // BoxShadow - adds a subtle shadow beneath the card
                    // Source: https://api.flutter.dev/flutter/painting/BoxShadow-class.html
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
                          _field(
                            controller: _nameController,
                            label: 'Organization Name',
                            hint: 'e.g. Worcester Robotics Club',
                            validator: _validateOrganizationName,
                          ),
                          _field(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'contact@yourorg.org',
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                          ),

                          // Password (custom because of visibility toggle)
                          // TextFormField with obscureText - hides password characters
                          // Tutorial: https://www.geeksforgeeks.org/flutter-textformfield/
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: !_passwordVisible, // toggles password visibility
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.newPassword],
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

                          _field(
                            controller: _websiteController,
                            label: 'Website URL',
                            hint: 'https://yourorg.org',
                            keyboardType: TextInputType.url,
                            validator: _validateWebsiteUrl,
                          ),
                          _field(
                            controller: _einController,
                            label: 'EIN / Registration Number',
                            hint: 'e.g. 12-3456789',
                            validator: _validateRegistrationNumber,
                          ),

                          // Info hint
                          // Container with withValues(alpha:) - tinted info banner using primary color at low opacity
                          // Source: https://api.flutter.dev/flutter/dart-ui/Color/withValues.html
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.08),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.control),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Use this email and password to sign in after approval.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.primary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          _field(
                            controller: _descriptionController,
                            label: 'Organization Description',
                            hint:
                                'What does your organization do? Who is it for?',
                            maxLines: 4,
                            validator: _validateDescription,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          const Text(
                            'Applications are reviewed before listing, typically within 1-3 business days.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.subtle,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // Submit button
                          // ElevatedButton - filled button for primary actions
                          // Tutorial: https://www.geeksforgeeks.org/flutter-elevatedbutton-widget/
                          ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            // CircularProgressIndicator - spinner shown while the async submit is running
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
                                : const Text('Submit application'),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          // TextButton - flat button used for low-emphasis actions
                          // Tutorial: https://www.geeksforgeeks.org/flutter-textbutton-widget/
                          TextButton(
                            onPressed: _openSignInScreen,
                            child: const Text(
                              'Already have an account? Sign in',
                              style: TextStyle(
                                color: AppColors.subtle,
                                fontSize: 14,
                              ),
                            ),
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
      ),
    );
  }
}

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Beacon',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
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
                'We\'re reviewing your organization. You\'ll receive an email within 1-3 business days once you\'ve been approved.',
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
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
