import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:unibites/resources/drawable.dart';
import 'package:unibites/authentication/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/main_page.dart'; // Adjust this import to your actual MainPage location
import 'package:unibites/authentication/email_verification_login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Initialize controller and animation directly
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Initialize the shake animation
    _shakeAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticIn,
      ),
    );

    // Start the animation
    _animationController.repeat(reverse: true);

    // Check login status and navigate accordingly after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _checkLoginStatus();
      }
    });
  }

  // Function to check if user is logged in
  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Get the boolean value, defaulting to false if it doesn't exist
      final isLoggedIn = prefs.getBool('loggedin') ?? false;
      // No need to check for emailVerified in SharedPreferences since
      // we're now handling that in the Auth class directly
      if (mounted) {
        if (isLoggedIn) {
          final isEmailVerified = prefs.getBool('emailVerified') ?? false;

          if (isEmailVerified) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainPage()),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const VerifyEmailLogin()),
            );
          }
        } else {
          // Navigate to login screen if user is not logged in
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      print('Error retrieving login status: $e');
      // Navigate to login in case of error
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    // Clean up the controller
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: child,
                );
              },
              child: SvgPicture.asset(
                AppImages.splashLogo,
                width: 140,
                height: 140,
              ),
            ),
          ],
        ),
      ),
    );
  }
}