import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../../../social/data/models/user_profile_model.dart';
import '../../../../core/constants/firestore_constants.dart';

class AuthRepository {
  final AuthService _authService;
  final FirebaseFirestore _firestore;

  AuthRepository({
    required AuthService authService,
    FirebaseFirestore? firestore,
  }) : _authService = authService,
       _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  User? get currentUser => _authService.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> register({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) {
    return _authService.registerWithEmailAndPassword(
      email: email,
      password: password,
      username: username,
      displayName: displayName,
    );
  }

  Future<void> signOut() => _authService.signOut();

  Stream<UserProfile?> userProfileStream(String uid) {
    return _firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return UserProfile.fromJson(doc.data()!);
        });
  }

  Future<UserProfile?> getCurrentUserProfile() {
    return _authService.getCurrentUserProfile();
  }
}
