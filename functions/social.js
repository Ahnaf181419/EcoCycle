const { writeAudit } = require('./rbac');

let admin;

function init(adminRef) {
  admin = adminRef;
}

async function followUser(data, context) {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Authentication required');
  }

  const db = admin.firestore();
  const followerId = context.auth.uid;
  const { targetUserId } = data;

  if (!targetUserId) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing targetUserId');
  }

  if (followerId === targetUserId) {
    throw new functions.https.HttpsError('invalid-argument', 'Cannot follow yourself');
  }

  const followDocId = `${followerId}_${targetUserId}`;
  const followRef = db.collection('follows').doc(followDocId);

  const existingFollow = await followRef.get();
  if (existingFollow.exists) {
    return { success: true, alreadyFollowing: true };
  }

  await db.runTransaction(async (transaction) => {
    transaction.set(followRef, {
      followerId,
      followeeId: targetUserId,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    transaction.update(db.collection('users').doc(followerId), {
      followingCount: admin.firestore.FieldValue.increment(1),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    transaction.update(db.collection('users').doc(targetUserId), {
      followerCount: admin.firestore.FieldValue.increment(1),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    transaction.set(db.collection('audit_log').doc(), {
      eventType: 'USER_FOLLOWED',
      actorId: followerId,
      actorRole: 'citizen',
      targetType: 'user',
      targetId: targetUserId,
      details: {},
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  return { success: true };
}

async function unfollowUser(data, context) {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Authentication required');
  }

  const db = admin.firestore();
  const followerId = context.auth.uid;
  const { targetUserId } = data;

  if (!targetUserId) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing targetUserId');
  }

  const followDocId = `${followerId}_${targetUserId}`;
  const followRef = db.collection('follows').doc(followDocId);

  const existingFollow = await followRef.get();
  if (!existingFollow.exists) {
    return { success: true, alreadyUnfollowed: true };
  }

  await db.runTransaction(async (transaction) => {
    transaction.delete(followRef);

    transaction.update(db.collection('users').doc(followerId), {
      followingCount: admin.firestore.FieldValue.increment(-1),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    transaction.update(db.collection('users').doc(targetUserId), {
      followerCount: admin.firestore.FieldValue.increment(-1),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    transaction.set(db.collection('audit_log').doc(), {
      eventType: 'USER_UNFOLLOWED',
      actorId: followerId,
      actorRole: 'citizen',
      targetType: 'user',
      targetId: targetUserId,
      details: {},
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  return { success: true };
}

module.exports = { followUser, unfollowUser, init };
