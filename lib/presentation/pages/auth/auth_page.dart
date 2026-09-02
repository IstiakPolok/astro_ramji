import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

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
            backgroundColor: AppColors.getBackground(isDark),
            body: Stack(
              children: [
                // In Light Mode: Light background with celestial art
                if (!isDark)
                  Positioned.fill(
                    child: Image.asset(
                      AppAssets.bgLight1,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (!isDark)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                // Watermark Om Symbol in background
                Positioned.fill(
                  child: Align(
                    alignment: const Alignment(0.0, 0.7),
                    child: Opacity(
                      opacity: isDark ? 0.05 : 0.07,
                      child: Text(
                        'ॐ',
                        style: GoogleFonts.cinzel(
                          fontSize: 320,
                          color: AppColors.getGold(isDark),
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
                              icon: Icon(
                                Icons.chevron_left,
                                color: AppColors.getGold(isDark),
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
                                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Subtitle
                            Text(
                              _isLoginTab
                                  ? 'Sign in to continue your cosmic journey'
                                  : 'Begin your Vedic journey today',
                              style: GoogleFonts.roboto(
                                color: AppColors.getTextSecondary(isDark),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 36),
                            // Toggle Tabs (Login / Sign Up)
                            _buildToggleTabs(isDark),
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
                                  if (success && context.mounted) {
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
                                Expanded(
                                  child: Divider(
                                    color: isDark ? AppColors.borderDark : const Color(0x30D4A827),
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
                                      color: AppColors.getTextMuted(isDark),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: isDark ? AppColors.borderDark : const Color(0x30D4A827),
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
                                  if (success && context.mounted) {
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
                                    color: isDark ? AppColors.cardDark : Colors.white,
                                    border: Border.all(
                                      color: isDark ? AppColors.borderDark : const Color(0x35D4A827),
                                      width: 1.5,
                                    ),
                                    boxShadow: isDark
                                        ? null
                                        : [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.05),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Image.network(
                                    'https://img.icons8.com/color/48/google-logo.png',
                                    width: 28,
                                    height: 28,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Text(
                                        'G',
                                        style: TextStyle(
                                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
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

  Widget _buildToggleTabs(bool isDark) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : const Color(0xF5FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0x35D4A827),
          width: 1.5,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
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
                    color: _isLoginTab
                        ? Colors.black
                        : (isDark ? AppColors.textSecondary : AppColors.textSecondaryLight),
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
                        : (isDark ? AppColors.textSecondary : AppColors.textSecondaryLight),
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
