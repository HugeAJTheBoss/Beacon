import 'package:flutter/material.dart';
import 'main.dart' show AppColors;
import 'student_screen.dart';
import 'signin_screen.dart';

class StudentSignupScreen extends StatefulWidget {
  const StudentSignupScreen({super.key});

  @override
  State<StudentSignupScreen> createState() => _StudentSignupScreenState();
}

class _StudentSignupScreenState extends State<StudentSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _zipController = TextEditingController();

  bool _passwordVisible = false;
  bool _isLoading = false;
  DateTime? _dateOfBirth;

  final Map<String, bool> _interests = {
    'Robotics': false,
    'Biology': false,
    'Math': false,
    'Computer Science': false,
    'Engineering': false,
    'Physics': false,
  };

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // TODO: create Firebase Auth account + save to Firestore
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const StudentScreen()),
    );
  }

  void _signUpWithGoogle() {
    // TODO: implement Google Sign-In
  }

  Future<void> _pickDateOfBirth(FormFieldState<DateTime> field) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 14, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );

    if (picked != null) {
      setState(() => _dateOfBirth = picked);
      field.didChange(picked);
    }
  }

  String _formatDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    return '$mm/$dd/$yyyy';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.title,
        elevation: 0,
        title: const Text(
          'Create Account',
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
                  'Find STEM opportunities that match you.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.subtle,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                OutlinedButton.icon(
                  onPressed: _signUpWithGoogle,
                  icon: const Icon(Icons.g_mobiledata, size: 24),
                  label: const Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.title,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                const SizedBox(height: 20),
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
                  label: 'Full Name',
                  hint: 'Your name',
                  validator: (val) =>
                      val!.isEmpty ? 'Name is required' : null,
                ),
                _FormField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) =>
                      !val!.contains('@') ? 'Enter a valid email' : null,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
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
                  controller: _zipController,
                  label: 'Zip Code',
                  hint: 'e.g. 01601',
                  keyboardType: TextInputType.number,
                  validator: (val) =>
                      val!.length != 5 ? 'Enter a valid zip code' : null,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Date of Birth',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 8),
                FormField<DateTime>(
                  initialValue: _dateOfBirth,
                  validator: (value) =>
                      value == null ? 'Date of birth is required' : null,
                  builder: (field) {
                    return InkWell(
                      onTap: () => _pickDateOfBirth(field),
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Select your date of birth',
                          errorText: field.errorText,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: const Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.subtle,
                            size: 20,
                          ),
                        ),
                        child: Text(
                          _dateOfBirth == null
                              ? 'Select your date of birth'
                              : _formatDate(_dateOfBirth!),
                          style: TextStyle(
                            color: _dateOfBirth == null
                                ? AppColors.subtle
                                : AppColors.title,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Interests',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Select all that apply — we\'ll use these to filter opportunities for you.',
                  style: TextStyle(
                      color: AppColors.subtle, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _interests.keys.map((interest) {
                    final selected = _interests[interest]!;
                    return GestureDetector(
                      onTap: () => setState(
                          () => _interests[interest] = !selected),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Text(
                          interest,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : AppColors.subtle,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
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
                          'Find Opportunities',
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
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
    // ignore: unused_element_parameter
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
          hintStyle:
              const TextStyle(color: AppColors.subtle, fontSize: 13),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: validator,
      ),
    );
  }
}