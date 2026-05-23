import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _obscurePassword = true;
  bool _isCreator = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final name = _displayNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields.'),
          backgroundColor: const Color(0xFFFF4757),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.signUp(
      email: email,
      password: password,
      displayName: name,
      isCreator: _isCreator,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Signup failed. Try again.'),
          backgroundColor: const Color(0xFFFF4757),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0D1F12),
                    const Color(0xFF132718),
                    const Color(0xFF0D1F12),
                  ]
                : [
                    const Color(0xFFF0FFF4),
                    const Color(0xFFDCF5E4),
                    const Color(0xFFF0FFF4),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: isDark ? Colors.white : const Color(0xFF0D1F12),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF00C853), Color(0xFF00E676)],
                          ).createShader(bounds),
                          child: const Text(
                            'Join MangaBD',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Create your account today',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF4A7A55)
                                : const Color(0xFF9CA3AF),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF132718) : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                    alpha: isDark ? 0.3 : 0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              TextField(
                                controller: _displayNameController,
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                  hintText: 'Display Name',
                                  prefixIcon: Icon(
                                      Icons.person_outline_rounded,
                                      color: Color(0xFF00C853)),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  hintText: 'Email address',
                                  prefixIcon: Icon(Icons.email_outlined,
                                      color: Color(0xFF00C853)),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline,
                                      color: Color(0xFF00C853)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: const Color(0xFF4A7A55),
                                    ),
                                    onPressed: () => setState(() =>
                                        _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: _isCreator
                                      ? const Color(0xFF00C853).withValues(alpha: 0.1)
                                      : (isDark
                                          ? const Color(0xFF1A3320)
                                          : const Color(0xFFE8F5E9)),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _isCreator
                                        ? const Color(0xFF00C853).withValues(alpha: 0.4)
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _isCreator
                                            ? const Color(0xFF00C853)
                                            : const Color(0xFF4A7A55).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.draw_rounded,
                                        size: 18,
                                        color: _isCreator
                                            ? Colors.white
                                            : const Color(0xFF4A7A55),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Register as Creator',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: isDark
                                                  ? Colors.white
                                                  : const Color(0xFF0D1F12),
                                            ),
                                          ),
                                          Text(
                                            'Upload and manage manga',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark
                                                  ? const Color(0xFF4A7A55)
                                                  : const Color(0xFF9CA3AF),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: _isCreator,
                                      onChanged: (val) =>
                                          setState(() => _isCreator = val),
                                      activeThumbColor: const Color(0xFF00C853),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: auth.isLoading ? null : _signup,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00C853),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: auth.isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          'Create Account',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account? ',
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFF4A7A55)
                                    : const Color(0xFF9CA3AF),
                                fontSize: 14,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'Login',
                                  style: TextStyle(
                                    color: Color(0xFF00C853),
                                    fontWeight: FontWeight.w700,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}