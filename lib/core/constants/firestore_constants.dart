class FirestoreConstants {
  FirestoreConstants._();

  static const String usersCollection = 'users';
  static const String submissionsCollection = 'submissions';
  static const String classificationsCollection = 'classifications';
  static const String disputesCollection = 'disputes';
  static const String rewardsCollection = 'rewards';
  static const String followsCollection = 'follows';
  static const String auditLogCollection = 'audit_log';
  static const String configCollection = 'config';
  static const String systemConfigDoc = 'system';

  static const String uid = 'uid';
  static const String username = 'username';
  static const String email = 'email';
  static const String displayName = 'displayName';
  static const String photoUrl = 'photoUrl';
  static const String role = 'role';
  static const String points = 'points';
  static const String redeemedPoints = 'redeemedPoints';
  static const String classificationCount = 'classificationCount';
  static const String correctCount = 'correctCount';
  static const String isPrivate = 'isPrivate';
  static const String followerCount = 'followerCount';
  static const String followingCount = 'followingCount';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';

  static const String userId = 'userId';
  static const String imageUrl = 'imageUrl';
  static const String storagePath = 'storagePath';
  static const String imageHash = 'imageHash';
  static const String category = 'category';
  static const String subcategory = 'subcategory';
  static const String confidence = 'confidence';
  static const String primaryApproach = 'primaryApproach';
  static const String state = 'state';
  static const String pointsAwarded = 'pointsAwarded';
  static const String idempotencyKey = 'idempotencyKey';
  static const String flaggedReason = 'flaggedReason';
  static const String duplicateOf = 'duplicateOf';
  static const String classifiedAt = 'classifiedAt';

  static const String submissionId = 'submissionId';
  static const String approach = 'approach';
  static const String modelVersion = 'modelVersion';
  static const String rawResponse = 'rawResponse';
  static const String timestamp = 'timestamp';

  static const String submitterId = 'submitterId';
  static const String originalCategory = 'originalCategory';
  static const String originalConfidence = 'originalConfidence';
  static const String secondaryCategory = 'secondaryCategory';
  static const String secondaryConfidence = 'secondaryConfidence';
  static const String resolvedCategory = 'resolvedCategory';
  static const String resolvedBy = 'resolvedBy';
  static const String resolution = 'resolution';
  static const String resolutionNote = 'resolutionNote';
  static const String status = 'status';
  static const String resolvedAt = 'resolvedAt';

  static const String type = 'type';

  static const String followerId = 'followerId';
  static const String followeeId = 'followeeId';

  static const String eventType = 'eventType';
  static const String actorId = 'actorId';
  static const String actorRole = 'actorRole';
  static const String targetType = 'targetType';
  static const String targetId = 'targetId';
  static const String details = 'details';

  static const String confidenceThreshold = 'confidenceThreshold';
  static const String pointsPerCategory = 'pointsPerCategory';
  static const String duplicateTimeWindowHours = 'duplicateTimeWindowHours';
  static const String duplicateHammingThreshold = 'duplicateHammingThreshold';
  static const String maxDailySubmissions = 'maxDailySubmissions';
  static const String leaderboardCacheSeconds = 'leaderboardCacheSeconds';

  static const String classifySubmission = 'classifySubmission';
  static const String resolveDispute = 'resolveDispute';
  static const String redeemPoints = 'redeemPoints';
  static const String followUser = 'followUser';
  static const String unfollowUser = 'unfollowUser';
  static const String updateRole = 'updateRole';
  static const String updateConfig = 'updateConfig';
}
