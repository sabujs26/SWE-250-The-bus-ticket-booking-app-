import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🔴 CODE SMELL: Message Chain (FirebaseAuth.instance...)
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(); // 🔴 CODE SMELL: Primitive Obsession
  final _passwordController = TextEditingController(); // 🔴 CODE SMELL: Primitive Obsession

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true; // 🔴 CODE SMELL: Temporary Field (used only for UI toggle)

  late AnimationController _animationController; // 🔴 CODE SMELL: Speculative Generality (initialized but not visibly used)
                                                 // 🔴 CODE SMELL: Dead Code (no animation widget references found)

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      value: _isLogin ? 0 : 1,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
      if (_isLogin) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
  }

  Future<void> _submit() async { // 🔴 CODE SMELL: Long Method (many responsibilities)
                                 // 🔴 CODE SMELL: Feature Envy (uses too much of Firebase API)
                                 // 🔴 CODE SMELL: Message Chain (FirebaseAuth.instance...)
                                 // 🔴 CODE SMELL: Duplicate Code (login/signup share same logic)
                                 // 🔴 CODE SMELL: Data Clumps (email & password always go together)
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(), // 🔴 CODE SMELL: Primitive Obsession
          password: _passwordController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      _showError(_getFirebaseErrorMessage(e));
    } catch (e) {
      _showError("Unexpected error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    // 🔴 CODE SMELL: Message Chain (e.code access and long switch block)
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password must be at least 8 characters.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'network-request-failed':
        return 'Please check your internet connection.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) { // 🔴 CODE SMELL: Large Class (manages UI, auth, animation)
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Logo
                Icon(Icons.directions_bus_filled, size: 80, color: theme.primaryColor),
                const SizedBox(height: 20),
                Text(
                  _isLogin ? "Welcome Back!" : "Create Account",
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  _isLogin ? "Please login to continue" : "Please sign up to get started",
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your email';
                          if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () => setState(() {
                              _obscurePassword = !_obscurePassword;
                            }),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your password';
                          if (value.length < 8) return 'Password must be at least 8 characters';
                          if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$').hasMatch(value)) {
                            return 'Use letters, numbers & special characters ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                )
                              : Text(_isLogin ? 'Login' : 'Sign Up', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _isLoading ? null : _toggleAuthMode,
                        child: Text(
                          _isLogin
                              ? "Don't have an account? Sign up"
                              : "Already have an account? Login",
                          style: TextStyle(color: theme.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Optional: Add a loading overlay to block interaction when loading
          if (_isLoading)
            Container(
              color: Colors.black38,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
