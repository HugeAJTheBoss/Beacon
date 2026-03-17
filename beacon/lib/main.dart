import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beacon',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF), // light blue-white background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const SizedBox(height: 90),

              // App name
              const Text(
                'Beacon',
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: -1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Tagline
              const Text(
                'Find STEM clubs, internships, and\nevents near you in Massachusetts.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(), // pushes buttons to bottom

              // Student button
              ElevatedButton(
                onPressed: () {}, // empty for now
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2979FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'I\'m a Student',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 12),

              // Organization button
              OutlinedButton(
                onPressed: () {}, // empty for now
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2979FF),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  side: const BorderSide(color: Color(0xFF2979FF), width: 1.5),
                ),
                child: const Text(
                  'I\'m an Organization',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 16),

              // Sign in link for returning users
              TextButton(
                onPressed: () {}, // empty for now
                child: const Text(
                  'Already have an account? Sign in',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}