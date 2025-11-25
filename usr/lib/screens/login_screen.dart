import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLogin = true; // true = Login, false = Sign Up
  bool _isLoading = false;
  bool _isObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // --- LOGIN FLOW ---
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        // Success: AuthWrapper in main.dart will detect session change and navigate to Home
      } else {
        // --- SIGN UP FLOW ---
        final AuthResponse res = await Supabase.instance.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          // Updated redirect URL for email confirmation
          emailRedirectTo: 'https://i.could.ai/?019aa9fa-38d1-7340-afd4-becc18e65372',
        );

        // Check if session is established immediately (e.g. "Confirm Email" is disabled in Supabase)
        if (res.session != null) {
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          // AuthWrapper handles navigation
        } else {
          // Session is null -> Email confirmation is required
          if (mounted) {
            _showVerificationDialog();
          }
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        // Print the detailed error to the console for debugging
        debugPrint('Supabase Auth Error: ${e.message}');
        _handleAuthError(e);
      }
    } catch (e) {
       if (mounted) {
        debugPrint('Generic Error: $e');
        _handleAuthError(e);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Verify Your Account'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 48, color: Colors.deepPurple),
              const SizedBox(height: 16),
              Text(
                'We have sent a verification email to:',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                _emailController.text.trim(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please check your email inbox (and spam folder) and click the confirmation link to activate your account.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: const Text(
                  'After clicking the link, please return to this app and sign in.',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isLogin = true; // Switch to login mode automatically
                _passwordController.clear(); // Clear password for security
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleAuthError(Object e) {
    String title = 'Error';
    String message = 'An unexpected error occurred. Please try again.';

    if (e is AuthException) {
      title = 'Authentication Error';
      if (e.message.contains('User already registered')) {
        message = 'This email is already in use. Please sign in instead.';
      } else if (e.message.contains('Invalid login credentials')) {
        message = 'Incorrect email or password. Please try again.';
      } else if (e.message.contains('Email not confirmed')) {
        message = 'Please verify your email address before signing in. Check your inbox for the confirmation link.';
      } else if (e.message.contains('Password should be at least 6 characters')) {
        message = 'Your password must be at least 6 characters long.';
      } else if (e.message.contains('network')) {
        message = 'A network error occurred. Please check your internet connection and try again.';
      } else {
        message = e.message; // Show the raw message for other cases
      }
    }

    // Show error dialog instead of snackbar for better visibility
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[700]),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  const Icon(
                    Icons.lock_person_rounded,
                    size: 64,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Passwords',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Securely manage your credentials',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Toggle Switch
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isLogin = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isLogin ? Theme.of(context).cardColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _isLogin
                                    ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
                                    : null,
                              ),
                              child: Text(
                                'Sign In',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: _isLogin ? FontWeight.bold : FontWeight.normal,
                                  color: _isLogin 
                                      ? (isDark ? Colors.white : Colors.black87)
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isLogin = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isLogin ? Theme.of(context).cardColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: !_isLogin
                                    ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
                                    : null,
                              ),
                              child: Text(
                                'Register',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: !_isLogin ? FontWeight.bold : FontWeight.normal,
                                  color: !_isLogin 
                                      ? (isDark ? Colors.white : Colors.black87)
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'name@example.com',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Email is required';
                      if (!value.contains('@') || !value.contains('.')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isObscured,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: _isLogin ? 'Enter your password' : 'Create a password (min 6 chars)',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _isObscured = !_isObscured),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Password is required';
                      if (!_isLogin && value.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            _isLogin ? 'Sign In' : 'Create Account',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                  
                  if (_isLogin) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        // Password reset functionality could go here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password reset feature coming soon')),
                        );
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
