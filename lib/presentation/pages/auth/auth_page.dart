import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoginTab = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                // Faint Om Symbol in background
                Positioned(
                  right: -80,
                  bottom: 80,
                  child: Opacity(
                    opacity: 0.04,
                    child: Text(
                      'ॐ',
                      style: TextStyle(
                        fontSize: 400,
                        color: AppColors.goldLight,
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Back Button
                            IconButton(
                              onPressed: () => context.pop(),
                              icon: const Icon(
                                Icons.chevron_left,
                                color: AppColors.goldPrimary,
                                size: 36,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Header
                            Text(
                              _isLoginTab ? 'WELCOME BACK' : 'CREATE ACCOUNT',
                              style: AppTextStyles.serifHeader(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Subtitle
                            Text(
                              _isLoginTab
                                  ? 'Sign in to continue your cosmic journey'
                                  : 'Join us to discover your astrological destiny',
                              style: AppTextStyles.sansBody(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 36),
                            // Toggle Tabs (Login / Sign Up)
                            _buildToggleTabs(),
                            const SizedBox(height: 36),
                            // Email Field
                            CustomTextField(
                              label: 'Email',
                              hintText: 'yourname@example.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) {
                                if (val == null || val.isEmpty || !val.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            // Password Field
                            CustomTextField(
                              label: 'Password',
                              hintText: '********',
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Password reset link sent to your email')),
                                    );
                                  },
                                  child: Text(
                                    'Forgot password?',
                                    style: AppTextStyles.sansBody(
                                      color: AppColors.goldPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 30),
                            // Error Message banner
                            if (authProvider.errorMessage != null) ...[
                              Text(
                                authProvider.errorMessage!,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                              ),
                              const SizedBox(height: 16),
                            ],
                            // Action Button
                            CustomButton(
                              text: _isLoginTab ? 'SIGN IN \u2794' : 'SIGN UP \u2794',
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
                                          _isLoginTab ? 'Successfully signed in!' : 'Successfully registered!',
                                        ),
                                      ),
                                    );
                                    // Navigate to homepage or show alert
                                  }
                                }
                              },
                            ),
                            const SizedBox(height: 24),
                            // "or" Divider
                            Row(
                              children: [
                                Expanded(child: Divider(color: AppColors.borderDark, thickness: 1.5)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text(
                                    'or',
                                    style: AppTextStyles.sansBody(color: AppColors.textMuted),
                                  ),
                                ),
                                Expanded(child: Divider(color: AppColors.borderDark, thickness: 1.5)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Google Sign-in Button
                            Center(
                              child: InkWell(
                                onTap: () async {
                                  final success = await authProvider.loginWithGoogle();
                                  if (success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Signed in with Google!')),
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(28),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.cardDark,
                                    border: Border.all(color: AppColors.borderDark, width: 1.5),
                                  ),
                                  alignment: Alignment.center,
                                  child: Image.network(
                                    'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                                    width: 24,
                                    height: 24,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Fallback letter if image fail or offline
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
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
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
                  gradient: _isLoginTab ? AppColors.goldGradient : null,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Login',
                  style: AppTextStyles.sansBody(
                    color: _isLoginTab ? Colors.black : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
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
                  gradient: !_isLoginTab ? AppColors.goldGradient : null,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Sign Up',
                  style: AppTextStyles.sansBody(
                    color: !_isLoginTab ? Colors.black : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
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
