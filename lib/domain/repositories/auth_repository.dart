abstract class AuthRepository {
  Future<bool> signInWithEmailAndPassword(String email, String password);
  Future<bool> signUpWithEmailAndPassword(String email, String password);
  Future<bool> signInWithGoogle();
  Future<void> signOut();
  Future<bool> isUserSignedIn();
}
