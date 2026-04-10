import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../social/data/models/user_profile_model.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/errors/app_error.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthService({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthError.fromFirebaseCode(e.code);
    }
  }

  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user!.updateDisplayName(displayName);

      await _createUserProfile(
        uid: credential.user!.uid,
        email: email,
        username: username,
        displayName: displayName,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthError.fromFirebaseCode(e.code);
    }
  }

  Future<void> _createUserProfile({
    required String uid,
    required String email,
    required String username,
    required String displayName,
  }) async {
    final now = DateTime.now();
    final profile = UserProfile(
      uid: uid,
      username: username,
      email: email,
      displayName: displayName,
      role: 'citizen',
      points: 0,
      redeemedPoints: 0,
      classificationCount: 0,
      correctCount: 0,
      isPrivate: false,
      followerCount: 0,
      followingCount: 0,
      createdAt: now,
      updatedAt: now,
    );

    await _firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .set(profile.toJson());
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<UserProfile?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final doc = await _firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(user.uid)
        .get();

    if (!doc.exists) return null;

    return UserProfile.fromJson(doc.data()!);
  }
}
