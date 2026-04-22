import 'package:flutter/material.dart';
import 'app_theme.dart';

import 'signin_screen.dart';
import 'services/auth_service.dart';
import 'widgets/app_form_field.dart';


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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }





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
            final isWide = constraints.maxWidth >= AppLayout.authWideBreakpoint;
            final horizontalPadding = isWide
                ? AppLayout.authHorizontalPaddingWide
                : AppLayout.authHorizontalPaddingNarrow;
            final availableWidth =
                constraints.maxWidth - (horizontalPadding * 2);
            final contentWidth = availableWidth > AppLayout.authContentMaxWidth
                ? AppLayout.authContentMaxWidth
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
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: AppSurfaces.authInfoPanel,
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.apartment_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Create your organization profile for review.',
                                  style: AppTextStyles.authPanelMessage,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          padding: AppInsets.authCard,
                          decoration: AppSurfaces.authFormCard,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppFormField(
                                controller: _nameController,
                                label: 'Organization Name',
                                hint: 'e.g. Worcester Robotics Club',
                                validator: _validateOrganizationName,
                              ),
                              AppFormField(
                                controller: _emailController,
                                label: 'Email',
                                hint: 'contact@yourorg.org',
                                keyboardType: TextInputType.emailAddress,
                                validator: _validateEmail,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_passwordVisible,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
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
                              AppFormField(
                                controller: _websiteController,
                                label: 'Website URL',
                                hint: 'https://yourorg.org',
                                keyboardType: TextInputType.url,
                                validator: _validateWebsiteUrl,
                              ),
                              AppFormField(
                                controller: _einController,
                                label: 'EIN / Registration Number',
                                hint: 'e.g. 12-3456789',
                                validator: _validateRegistrationNumber,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: AppOpacity.soft,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.control,
                                    ),
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
                              AppFormField(
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
                                style: AppTextStyles.helperBody,
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : _submitForm,
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
                                        'Submit application',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              TextButton(
                                onPressed: _openSignInScreen,
                                child: const Text(
                                  'Already have an account? Sign in',
                                  style: AppTextStyles.subtleAction,
                                ),
                              ),

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

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navBar,
        foregroundColor: AppColors.ink,
        elevation: 0,
        title: const Text(
          'Beacon',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
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
                'We\'re reviewing your organization. You\'ll receive an email within 1ΓÇô3 business days once you\'ve been approved.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.subtle,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
