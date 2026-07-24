import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const AuthScreen({
    super.key,
    required this.onAuthenticated,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignUp = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration inputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFF4F46E5),
          width: 2,
        ),
      ),
    );
  }

  Future<void> _submitEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService =
        Provider.of<AuthService>(context, listen: false);

    try {
      if (_isSignUp) {
        await authService.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
        );
      } else {
        await authService.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      widget.onAuthenticated();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Authentication Error\n$e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitGoogleAuth() async {
    setState(() => _isLoading = true);

    final authService =
        Provider.of<AuthService>(context, listen: false);

    try {
      await authService.signInWithGoogle();
      widget.onAuthenticated();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Google Sign In Error\n$e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the base decoration
    final passwordDecoration = inputDecoration(
      "Password",
      Icons.lock_outline,
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFE0E7FF),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Logo
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withOpacity(.25),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_person_rounded,
                    color: Colors.white,
                    size: 45,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  _isSignUp
                      ? "Welcome!"
                      : "Welcome Back!",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _isSignUp
                      ? "Create your account to get started."
                      : "Sign in to access your dashboard.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 32),

                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Toggle Buttons
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isSignUp = true;
                                    });
                                  },
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _isSignUp
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius:
                                          BorderRadius.circular(
                                        14,
                                      ),
                                    ),
                                    child: Text(
                                      "Create Account",
                                      textAlign:
                                          TextAlign.center,
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        color: _isSignUp
                                            ? const Color(
                                                0xFF4F46E5)
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isSignUp = false;
                                    });
                                  },
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: !_isSignUp
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius:
                                          BorderRadius.circular(
                                        14,
                                      ),
                                    ),
                                    child: Text(
                                      "Sign In",
                                      textAlign:
                                          TextAlign.center,
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        color: !_isSignUp
                                            ? const Color(
                                                0xFF4F46E5)
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              if (_isSignUp) ...[
                                TextFormField(
                                  controller:
                                      _nameController,
                                  decoration:
                                      inputDecoration(
                                    "Full Name",
                                    Icons.person_outline,
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty) {
                                      return "Enter your name";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],

                              TextFormField(
                                controller:
                                    _emailController,
                                keyboardType:
                                    TextInputType
                                        .emailAddress,
                                decoration:
                                    inputDecoration(
                                  "Email Address",
                                  Icons.email_outlined,
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      !value.contains(
                                          '@')) {
                                    return "Enter a valid email";
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              TextFormField(
                                controller:
                                    _passwordController,
                                obscureText:
                                    _obscurePassword,
                                decoration: passwordDecoration.copyWith(
                                  suffixIcon:
                                      IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons
                                              .visibility_off
                                          : Icons
                                              .visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword =
                                            !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      value.length < 6) {
                                    return "Minimum 6 characters";
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 28),

                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed:
                                      _isLoading
                                          ? null
                                          : _submitEmailAuth,
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(
                                            0xFF4F46E5),
                                    foregroundColor:
                                        Colors.white,
                                    elevation: 4,
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  18),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child:
                                              CircularProgressIndicator(
                                            color:
                                                Colors
                                                    .white,
                                          ),
                                        )
                                      : Text(
                                          _isSignUp
                                              ? "Create Account"
                                              : "Sign In",
                                          style:
                                              const TextStyle(
                                            fontSize:
                                                16,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Row(
                          children: [
                            Expanded(
                              child: Divider(),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(
                                      horizontal:
                                          12),
                              child: Text(
                                "OR",
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: OutlinedButton(
                            onPressed:
                                _isLoading
                                    ? null
                                    : _submitGoogleAuth,
                            style:
                                OutlinedButton.styleFrom(
                              backgroundColor:
                                  Colors.white,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(18),
                              ),
                              side: BorderSide(
                                color:
                                    Colors.grey.shade300,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                              children: [
                                Icon(
                                  Icons
                                      .g_mobiledata_rounded,
                                  size: 36,
                                  color: Color(
                                      0xFFEA4335),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Continue with Google",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        Colors.black87,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}