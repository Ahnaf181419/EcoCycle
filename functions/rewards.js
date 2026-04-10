const { writeAudit } = require('./rbac');

let admin;

function init(adminRef) {
  admin = adminRef;
}

async function awardPoints(db, submissionId, userId, category, idempotencyKey) {
  const configDoc = await db.collection('config').doc('system').get();
  const config = configDoc.data();
  const pointsPerCategory = config.pointsPerCategory || { recyclable: 10, organic: 8, e_waste: 15, hazardous: 20 };
  const points = pointsPerCategory[category] || 0;

  const existingReward = await db.collection('rewards')
    .where('idempotencyKey', '==', idempotencyKey)
    .limit(1)
    .get();

  if (!existingReward.empty) {
    return { alreadyAwarded: true, points: 0 };
  }

  const rewardRef = db.collection('rewards').doc();
  await db.runTransaction(async (transaction) => {
    transaction.set(rewardRef, {
      id: rewardRef.id,
      userId,
      submissionId,
      points,
      type: 'classification',
      idempotencyKey,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const submissionRef = db.collection('submissions').doc(submissionId);
    transaction.update(submissionRef, {
      state: 'REWARDED',
      pointsAwarded: points,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const userRef = db.collection('users').doc(userId);
    transaction.update(userRef, {
      points: admin.firestore.FieldValue.increment(points),
      correctCount: admin.firestore.FieldValue.increment(1),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    transaction.set(db.collection('audit_log').doc(), {
      eventType: 'POINTS_AWARDED',
      actorId: userId,
      actorRole: 'system',
      targetType: 'reward',
      targetId: rewardRef.id,
      details: { submissionId, category, points },
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  return { alreadyAwarded: false, points };
}

async function redeemPoints(data, context) {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Authentication required');
  }

  const db = admin.firestore();
  const uid = context.auth.uid;
  const { points, idempotencyKey } = data;

  if (!points || points <= 0 || !idempotencyKey) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid points or idempotency key');
  }

  const existingRedemption = await db.collection('rewards')
    .where('idempotencyKey', '==', idempotencyKey)
    .limit(1)
    .get();

  if (!existingRedemption.empty) {
    return { success: true, alreadyProcessed: true };
  }

  const userDoc = await db.collection('users').doc(uid).get();
  const userData = userDoc.data();
  const availablePoints = userData.points - userData.redeemedPoints;

  if (points > availablePoints) {
    throw new functions.https.HttpsError('failed-precondition', 'Insufficient points');
  }

  const rewardRef = db.collection('rewards').doc();
  await db.runTransaction(async (transaction) => {
    transaction.set(rewardRef, {
      id: rewardRef.id,
      userId: uid,
      submissionId: null,
      points: -points,
      type: 'redemption',
      idempotencyKey,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    transaction.update(db.collection('users').doc(uid), {
      redeemedPoints: admin.firestore.FieldValue.increment(points),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    transaction.set(db.collection('audit_log').doc(), {
      eventType: 'POINTS_REDEEMED',
      actorId: uid,
      actorRole: userData.role,
      targetType: 'reward',
      targetId: rewardRef.id,
      details: { points },
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  return { success: true, pointsRedeemed: points };
}

module.exports = { awardPoints, redeemPoints, init };
