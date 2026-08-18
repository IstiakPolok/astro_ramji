import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  // Simulated authentication delay
  @override
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    if (email.contains('@') && password.length >= 6) {
      return true;
    }
    return false;
  }

  @override
  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    if (email.contains('@') && password.length >= 6) {
      return true;
    }
    return false;
  }

  @override
  Future<bool> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<bool> isUserSignedIn() async {
    return false;
  }
}
