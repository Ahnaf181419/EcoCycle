import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/submission_model.dart';
import '../models/classification_model.dart';
import '../../../../core/constants/firestore_constants.dart';

class SubmissionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SubmissionRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  Stream<List<Submission>> getSubmissionHistory({int limit = 20}) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection(FirestoreConstants.submissionsCollection)
        .where(FirestoreConstants.userId, isEqualTo: uid)
        .orderBy(FirestoreConstants.createdAt, descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Submission.fromJson(doc.data()))
              .toList(),
        );
  }

  Stream<Submission?> watchSubmission(String submissionId) {
    return _firestore
        .collection(FirestoreConstants.submissionsCollection)
        .doc(submissionId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return Submission.fromJson(doc.data()!);
        });
  }

  Future<Submission?> getSubmission(String submissionId) async {
    final doc = await _firestore
        .collection(FirestoreConstants.submissionsCollection)
        .doc(submissionId)
        .get();

    if (!doc.exists) return null;
    return Submission.fromJson(doc.data()!);
  }

  Future<List<Classification>> getClassifications(String submissionId) async {
    final snapshot = await _firestore
        .collection(FirestoreConstants.classificationsCollection)
        .where(FirestoreConstants.submissionId, isEqualTo: submissionId)
        .get();

    return snapshot.docs
        .map((doc) => Classification.fromJson(doc.data()))
        .toList();
  }

  Stream<List<Submission>> getRecentSubmissions({int limit = 10}) {
    return _firestore
        .collection(FirestoreConstants.submissionsCollection)
        .orderBy(FirestoreConstants.createdAt, descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Submission.fromJson(doc.data()))
              .toList(),
        );
  }
}
