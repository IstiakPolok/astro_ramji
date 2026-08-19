import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AuthPage extends StatefulWidget {
  final String initialTab;
  const AuthPage({super.key, this.initialTab = 'login'});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  late bool _isLoginTab;

  @override
  void initState() {
    super.initState();
    _isLoginTab = widget.initialTab == 'login';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepositoryImpl();
    final loginUseCase = LoginUseCase(authRepository);

    return ChangeNotifierProvider(
      create: (_) => AuthProvider(
        loginUseCase: loginUseCase,
        authRepository: authRepository,
      ),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Scaffold(
            backgroundColor: AppColors.spaceDark,
            body: Stack(
              children: [
                // Watermark Om Symbol in background (Mockup style)
                Positioned.fill(
                  child: Align(
                    alignment: const Alignment(0.0, 0.7),
                    child: Opacity(
                      opacity: 0.05,
                      child: Text(
                        'ॐ',
                        style: GoogleFonts.cinzel(
                          fontSize: 320,
                          color: AppColors.goldPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 16.0,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Back Button
                            IconButton(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.zero,
                              onPressed: () => context.pop(),
                              icon: const Icon(
                                Icons.chevron_left,
                                color: AppColors.goldPrimary,
                                size: 36,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Header Title
                            Text(
                              _isLoginTab ? 'WELCOME BACK' : 'CREATE ACCOUNT',
                              style: GoogleFonts.cinzel(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Subtitle
                            Text(
                              _isLoginTab
                                  ? 'Sign in to continue your cosmic journey'
                                  : 'Begin your Vedic journey today',
                              style: GoogleFonts.roboto(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 36),
                            // Toggle Tabs (Login / Sign Up)
                            _buildToggleTabs(),
                            const SizedBox(height: 36),

                            // Input fields based on active tab
                            if (!_isLoginTab) ...[
                              // Full Name Field (Sign Up only)
                              CustomTextField(
                                label: 'Full Name',
                                hintText: 'Aarav Sharma',
                                controller: _fullNameController,
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Email Field
                            CustomTextField(
                              label: 'Email',
                              hintText: 'you@example.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) {
                                if (val == null ||
                                    val.isEmpty ||
                                    !val.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            if (!_isLoginTab) ...[
                              // Phone Field (Sign Up only)
                              CustomTextField(
                                label: 'Phone',
                                hintText: '+91 98765 43210',
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Password Field
                            CustomTextField(
                              label: 'Password',
                              hintText: '••••••••',
                              controller: _passwordController,
                              obscureText: true,
                              validator: (val) {
                                if (val == null || val.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Forgot Password Link (only in Login)
                            if (_isLoginTab)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    context.push('/forgot-password');
                                  },
                                  child: Text(
                                    'Forgot password?',
                                    style: GoogleFonts.roboto(
                                      color: AppColors.goldOrange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 30),
                            // Error Message banner
                            if (authProvider.errorMessage != null) ...[
                              Text(
                                authProvider.errorMessage!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            // Action Button
                            CustomButton(
                              text: _isLoginTab
                                  ? 'SIGN IN \u2794'
                                  : 'CREATE ACCOUNT \u2794',
                              isLoading: authProvider.isLoading,
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  bool success;
                                  if (_isLoginTab) {
                                    success = await authProvider.login(
                                      _emailController.text.trim(),
                                      _passwordController.text.trim(),
                                    );
                                  } else {
                                    success = await authProvider.register(
                                      _emailController.text.trim(),
                                      _passwordController.text.trim(),
                                    );
                                  }
                                  if (success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          _isLoginTab
                                              ? 'Successfully signed in!'
                                              : 'Successfully registered!',
                                        ),
                                      ),
                                    );
                                    context.go('/home');
                                  }
                                }
                              },
                            ),
                            const SizedBox(height: 24),
                            // "or" Divider
                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(
                                    color: AppColors.borderDark,
                                    thickness: 1.5,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Text(
                                    'or',
                                    style: GoogleFonts.roboto(
                                      color: AppColors.textMuted,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(
                                    color: AppColors.borderDark,
                                    thickness: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Google Sign-in Button
                            Center(
                              child: InkWell(
                                onTap: () async {
                                  final success = await authProvider
                                      .loginWithGoogle();
                                  if (success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Signed in with Google!'),
                                      ),
                                    );
                                    context.go('/home');
                                  }
                                },
                                borderRadius: BorderRadius.circular(28),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.cardDark,
                                    border: Border.all(
                                      color: AppColors.borderDark,
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Image.network(
                                    'https://img.icons8.com/color/48/google-logo.png',
                                    width: 28,
                                    height: 28,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Text(
                                        'G',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildToggleTabs() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark, width: 1.5),
      ),
      child: Row(
        children: [
          // Login Tab
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLoginTab = true),
              child: Container(
                decoration: BoxDecoration(
                  gradient: _isLoginTab ? AppColors.buttonGradient : null,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  'LOGIN',
                  style: GoogleFonts.cinzel(
                    color: _isLoginTab ? Colors.black : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          // Sign Up Tab
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLoginTab = false),
              child: Container(
                decoration: BoxDecoration(
                  gradient: !_isLoginTab ? AppColors.buttonGradient : null,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  'SIGN UP',
                  style: GoogleFonts.cinzel(
                    color: !_isLoginTab
                        ? Colors.black
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
