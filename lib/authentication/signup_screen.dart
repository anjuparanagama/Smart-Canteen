import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unibites/authentication/email_verification_signup.dart';
import 'package:unibites/resources/color.dart';
import 'package:unibites/resources/dimension.dart';
import 'package:unibites/resources/drawable.dart';
import 'package:unibites/resources/font.dart';
import 'package:unibites/resources/string.dart';
import '../services/firestore_user_service.dart';
import '../widgets/agreement_dialog.dart';
import '../widgets/custom_toast_error.dart';
import 'auth.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Create instance of Auth class
  final Auth _auth = Auth();

  final UserService _userService = UserService();

  bool _isChecked = false;
  bool _obscureText = true;
  bool _isLoading = false; // Add loading state

  // Validation error text variables
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _passwordError;
  String? _phoneError;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final RegExp phoneRegex = RegExp(r'^07\d{8}$');
    return phoneRegex.hasMatch(phone);
  }

  bool _isValidPassword(String password) {
    if (password.length < 8) {
      return false;
    }

    final RegExp upperCaseRegex = RegExp(r'[A-Z]');
    final RegExp lowerCaseRegex = RegExp(r'[a-z]');
    final RegExp symbolRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

    bool hasUpperCase = upperCaseRegex.hasMatch(password);
    bool hasLowerCase = lowerCaseRegex.hasMatch(password);
    bool hasSymbol = symbolRegex.hasMatch(password);

    return hasUpperCase && hasLowerCase && hasSymbol;
  }

  String? _getPasswordErrorMessage(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }

    List<String> requirements = [];

    if (password.length < 8) {
      requirements.add('at least 8 characters');
    }

    final RegExp upperCaseRegex = RegExp(r'[A-Z]');
    if (!upperCaseRegex.hasMatch(password)) {
      requirements.add('one uppercase letter');
    }

    final RegExp lowerCaseRegex = RegExp(r'[a-z]');
    if (!lowerCaseRegex.hasMatch(password)) {
      requirements.add('one lowercase letter');
    }

    final RegExp symbolRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    if (!symbolRegex.hasMatch(password)) {
      requirements.add('one special character');
    }

    if (requirements.isEmpty) {
      return null;
    }

    return 'Password must have ${requirements.join(', ')}';
  }

  bool _validateInputs() {
    bool isValid = true;

    // Reset error messages
    setState(() {
      _firstNameError = null;
      _lastNameError = null;
      _emailError = null;
      _passwordError = null;
      _phoneError = null;
    });

    // Validate first name
    String firstName = _firstNameController.text.trim();
    if (firstName.isEmpty) {
      setState(() {
        _firstNameError = 'First name is required';
      });
      isValid = false;
    }

    // Validate last name
    String lastName = _lastNameController.text.trim();
    if (lastName.isEmpty) {
      setState(() {
        _lastNameError = 'Last name is required';
      });
      isValid = false;
    }

    // Validate email
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _emailError = 'Email is required';
      });
      isValid = false;
    } else if (!_isValidEmail(email)) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
      isValid = false;
    }

    // Validate password
    String password = _passwordController.text;
    String? passwordError = _getPasswordErrorMessage(password);
    if (passwordError != null) {
      setState(() {
        _passwordError = passwordError;
      });
      isValid = false;
    }

    // Validate phone
    String phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() {
        _phoneError = 'Phone number is required';
      });
      isValid = false;
    } else if (!_isValidPhone(phone)) {
      setState(() {
        _phoneError = 'Phone must be 10 digits starting with 07';
      });
      isValid = false;
    }

    return isValid;
  }

  // New method to handle Firebase authentication
  Future<void> _createUserAccount() async {
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String phone = _phoneController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Create Firebase Authentication account
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Get current user
      User? user = _auth.currentUser;

      // 3. Send email verification
      if (user != null) {

      }

      // 4. Save additional user data to Firestore
      await _userService.saveUserData(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
      );

      // 5. Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created successfully! Please verify your email.'),
          backgroundColor: Colors.green, // Success color
          // behavior: SnackBarBehavior.floating, // Optional for better visibility
          duration: Duration(seconds: 3), // Duration before dismissal
        ),
      );


      // 6. Navigate to email verification screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => VerifyEmailSignup()),
        );
      }
    } catch (e) {
      // Handle Firebase authentication errors
      String errorMessage = 'Failed to create account. Please try again.';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'This email is already in use. Please try a different one.';
            setState(() {
              _emailError = errorMessage;
            });
            break;
          case 'weak-password':
            errorMessage = 'Password is too weak. Please use a stronger password.';
            setState(() {
              _passwordError = errorMessage;
            });
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email address. Please check and try again.';
            setState(() {
              _emailError = errorMessage;
            });
            break;
          default:
            errorMessage = 'Error: ${e.message}';
        }
      }

      // Show error toast
      CustomToast.show(errorMessage);
      if (kDebugMode) {
        print('Error creating user: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _signup() {

    // Hide keyboard first
    _dismissKeyboard();

    // First validate all inputs
    if (!_validateInputs()) {
      // Show toast if validation fails
      CustomToast.show('Please fill all required fields correctly');
      return;
    }

    if (_isChecked) {
      // Call Firebase authentication method instead of navigating to VerifyEmail directly
      _createUserAccount();
    } else {
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
              // Call signup again after user agrees to terms
              if (_isChecked) {
                _createUserAccount();
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
    }
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide'); // Add this line
  }

  @override
  Widget build(BuildContext context) {
    // Initialize the toast context
    CustomToast.init(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppDimension.paddingDefault * 2),
            child: Column(
              children: [
                SizedBox(height: 90),
                Row(
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
                SizedBox(height: 15),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimension.paddingDefault),
                  child: Row(
                    children: [
                      Text(
                        'Register For\nJoin Our Community',
                        style: TextStyle(
                            color: Colors.black,
                            height: 1.1,
                            fontSize: 24,
                            fontFamily: AppFonts.outfitBold
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
                        AppStrings.signupGuide,
                        maxLines: 2,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.textDarkGrey,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                // First and Last Name row
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppDimension.paddingDefault),
                        child: TextField(
                          controller: _firstNameController,
                          style: const TextStyle(color: Colors.black),
                          onChanged: (_) {
                            // Clear error when user starts typing
                            if (_firstNameError != null) {
                              setState(() {
                                _firstNameError = null;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'First Name*',
                            hintStyle: const TextStyle(color: AppColors.hintTextSilver),
                            prefixIcon: const Icon(Icons.person_2_outlined, color: AppColors.iconSilver),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: _firstNameError != null ? Colors.red : Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: _firstNameError != null ? Colors.red : Color(0xFFFFD634)),
                            ),
                            errorText: _firstNameError,
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
                        ),
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppDimension.paddingDefault),
                        child: TextField(
                          controller: _lastNameController,
                          style: const TextStyle(color: Colors.black),
                          onChanged: (_) {
                            // Clear error when user starts typing
                            if (_lastNameError != null) {
                              setState(() {
                                _lastNameError = null;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Last Name*',
                            hintStyle: const TextStyle(color: AppColors.hintTextSilver),
                            prefixIcon: const Icon(Icons.person_2_outlined, color: AppColors.iconSilver),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: _lastNameError != null ? Colors.red : Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: _lastNameError != null ? Colors.red : Color(0xFFFFD634)),
                            ),
                            errorText: _lastNameError,
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
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Email Address
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimension.paddingDefault),
                  child: TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.black),
                    onChanged: (_) {
                      // Clear error when user starts typing
                      if (_emailError != null) {
                        setState(() {
                          _emailError = null;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Email Address*',
                      hintStyle: const TextStyle(color: AppColors.hintTextSilver),
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.iconSilver),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: _emailError != null ? Colors.red : Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: _emailError != null ? Colors.red : Color(0xFFFFD634)),
                      ),
                      errorText: _emailError,
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
                  ),
                ),

                const SizedBox(height: 16),
                // Password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimension.paddingDefault),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _passwordController,
                        style: const TextStyle(color: Colors.black),
                        obscureText: _obscureText,
                        onChanged: (_) {
                          // Clear error when user starts typing
                          if (_passwordError != null) {
                            setState(() {
                              _passwordError = null;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Password*',
                          hintStyle: const TextStyle(color: AppColors.hintTextSilver),
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.iconSilver),
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
                            borderSide: BorderSide(color: _passwordError != null ? Colors.red : Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: _passwordError != null ? Colors.red : Color(0xFFFFD634)),
                          ),
                          errorText: _passwordError,
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
                      ),
                      if (_passwordError == null) Padding(
                        padding: const EdgeInsets.only(top: 5, left: 15),
                        child: Text(
                          'Password must be at least 8 characters with 1 uppercase letter, 1 lowercase letter, and 1 special character',
                          style: TextStyle(
                            color: AppColors.textSilver,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Phone Number
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimension.paddingDefault),
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.black),
                    onChanged: (_) {
                      // Clear error when user starts typing
                      if (_phoneError != null) {
                        setState(() {
                          _phoneError = null;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Phone Number* (e.g., 0712345678)',
                      prefixStyle: const TextStyle(color: Colors.black),
                      hintStyle: const TextStyle(color: AppColors.hintTextSilver),
                      prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.iconSilver),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: _phoneError != null ? Colors.red : Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: _phoneError != null ? Colors.red : Color(0xFFFFD634)),
                      ),
                      errorText: _phoneError,
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
                  ),
                ),

                const SizedBox(height: 16),

                // Terms and Conditions Checkbox
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
                              const TextSpan(
                                  text: 'I confirm that I have read, consent and agree to UniBites\' ',
                                  style: TextStyle(
                                  )
                              ),
                              TextSpan(
                                text: 'Terms of Use',
                                style: const TextStyle(
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
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // Handle the tap event, e.g., navigate to another page
                                    if (kDebugMode) {
                                      print('Privacy Policy tapped!');
                                    }
                                  },
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Sign Up Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimension.paddingDefault),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD634),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        // Disable button during loading
                        disabledBackgroundColor: Colors.white,
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
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontFamily: AppFonts.outfitBold,
                            ),
                          ),
                        ],
                      )
                          : const Text(
                        'Sign up',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontFamily: AppFonts.outfitBold
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),

                // Contact Us and Login Links
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Padding(
                        padding: const EdgeInsets.only(left: AppDimension.paddingDefault * 0.1),
                        child: const Text(
                          'Contact us',
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
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Extra space at bottom to ensure scrolling works well
                const SizedBox(height: 20),
              ],
            ),
          ),
          // Overlay loading indicator for the entire screen (optional for better UX)
        ],
      ),
    );
  }
}