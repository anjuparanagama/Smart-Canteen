import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unibites/pages/main_page.dart';
import 'package:unibites/resources/color.dart';
import 'package:unibites/resources/dimension.dart';
import 'package:unibites/resources/drawable.dart';
import 'package:unibites/resources/font.dart';
import 'package:unibites/resources/string.dart';
import 'package:unibites/authentication/signup_screen.dart';
import '../widgets/agreement_dialog.dart';
import 'auth.dart';
import 'email_verification_login.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isChecked = false;
  bool _obscureText = true;
  bool _isLoading = false;

  // Add the Auth instance here
  final Auth _auth = Auth();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Method to save login state
  Future<bool> _saveLoginState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('loggedin', true);
      if (kDebugMode) {
        print('Login state saved to SharedPreferences');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving login state: $e');
      }
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save login state. Please try again.')),
        );
      }
      return false;
    }
  }

  // New method to handle login process
  Future<void> _handlePressed() async {
    // Hide keyboard first
    _dismissKeyboard();

    // Validate form first
    if (!_formKey.currentState!.validate()) {
      // Form has errors, don't proceed
      return;
    }

    // Check terms agreement
    if (!_isChecked) {
      showCustomAlertDialog(
        context,
        [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();

              setState(() {
                _isChecked = !_isChecked;
              });
              // Call login again after user agrees to terms
              if (_isChecked) {
                _handlePressed();
              }
            },
            child: Text('Agree',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
              ),),
          ),
        ],
      );
      return;
    }

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Use Firebase auth to sign in
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Check if email is verified
      if (_auth.currentUser != null) {
        // First save login state
        bool saveSuccess = await _saveLoginState();

        if (!saveSuccess) {
          // If we couldn't save the login state, stop here
          return;
        }

        // Then check email verification and navigate accordingly
        if (_auth.currentUser!.emailVerified) {
          // Email is verified, navigate to MainPage
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainPage()),
            );
          }
          _saveLoginState();
        } else {
          // Email is not verified, navigate to EmailVerification page
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const VerifyEmailLogin()),
            );
          }
        }
      }
    } catch (e) {
      // Handle login errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account not found!'),
            backgroundColor: Colors.red, // Success color
            duration: Duration(seconds: 3), // Duration before dismissal
          ),
        );
      }

      if (kDebugMode) {
        print('Login error: $e');
      }
    } finally {
      // Reset loading state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide'); // Add this line
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimension.paddingDefault * 2),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimension.paddingDefault),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        AppImages.splashLogo,
                        width: 50,
                        height: 50,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppDimension.paddingDefault),
                        child: Text(
                          AppStrings.appName,
                          style: TextStyle(
                              fontSize: 32,
                              color: Colors.black,
                              fontFamily: AppFonts.kanitBlack
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 15),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimension.paddingDefault),
                  child: Row(
                    children: [
                      Text(
                        'Login To Explore your\nFavourite!',
                        style: TextStyle(
                          color: Colors.black,
                          height: 1.1,
                          fontSize: 24,
                          fontFamily: AppFonts.outfitBold,
                        ),
                      )
                    ],
                  ),
                ),

                SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimension.paddingDefault),
                      child: Text(
                        textAlign: TextAlign.left,
                        AppStrings.loginGuide,
                        style: TextStyle(
                          color: AppColors.textDarkGrey,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Email/Phone text field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimension.paddingDefault),
                  child: TextFormField(
                    controller: _emailController,
                    style: TextStyle(
                        color: Colors.black
                    ),
                    decoration: InputDecoration(
                      hintText: 'Email Address',
                      hintStyle: const TextStyle(color: AppColors.hintTextSilver),
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.iconSilver),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFFFD634)),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email address is required';
                      }
                      // Basic email validation
                      if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 16),
                // Password text field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimension.paddingDefault),
                  child: TextFormField(
                    controller: _passwordController,
                    style: TextStyle(
                        color: Colors.black
                    ),
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: AppColors.hintTextSilver),
                      prefixIcon: Icon(Icons.lock_outline, color: AppColors.iconSilver),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.iconSilver,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFFFD634)),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimension.paddingDefault + 5),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isChecked = !_isChecked;
                          });
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isChecked ? Colors.black : Colors.grey,
                              width: 1.5,
                            ),
                          ),
                          child: _isChecked
                              ? const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.black,
                          )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(color: AppColors.textSilver, fontSize: 14),
                            children: [
                              TextSpan(
                                  text: 'I confirm that I have read, consent and agree to UniBites\' ',
                                  style: TextStyle(
                                  )
                              ),
                              TextSpan(
                                text: 'Terms of Use',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // Handle the tap event, e.g., navigate to another page
                                    if (kDebugMode) {
                                      print('Terms of Use tapped!');
                                    }
                                  },
                              ),
                              TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // Handle the tap event, e.g., navigate to another page
                                    if (kDebugMode) {
                                      print('Terms of Use tapped!');
                                    }
                                  },
                              ),
                              TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Login button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimension.paddingDefault),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handlePressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFD634),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              strokeWidth: 5,
                            ),
                          ),
                          SizedBox(width: 15),
                          Text(
                            'Log in',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontFamily: AppFonts.outfitBold,
                            ),
                          ),
                        ],
                      )
                          : Text(
                        'Log in',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontFamily: AppFonts.outfitBold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                // Forgot password and sign up
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Padding(
                        padding: const EdgeInsets.only(left: AppDimension.paddingDefault * 0.1),
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: AppDimension.paddingDefault * 0.1),
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const SignupScreen()),
                          );
                        },
                        child: const Text(
                          'Sign up',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar:
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimension.paddingDefault * 2),
          child: BottomAppBar(
            child: Column(
              children: [
                // Google sign in button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: SvgPicture.asset(
                      AppImages.googleLogo,
                      height: 24,
                      width: 24,
                    ),
                    label: const Text(
                      'Sign in with Google',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}