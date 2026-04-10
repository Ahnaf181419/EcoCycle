const { verifyRole, writeAudit } = require('./rbac');

let admin;

function init(adminRef) {
  admin = adminRef;
}

async function updateRole(data, context) {
  const { uid, role } = verifyRole(context, ['admin']);
  const db = admin.firestore();
  const { targetUserId, newRole } = data;

  if (!targetUserId || !newRole) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing targetUserId or newRole');
  }

  if (!['citizen', 'moderator', 'admin'].includes(newRole)) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid role');
  }

  await db.runTransaction(async (transaction) => {
    transaction.update(db.collection('users').doc(targetUserId), {
      role: newRole,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    transaction.set(db.collection('audit_log').doc(), {
      eventType: 'ROLE_UPDATED',
      actorId: uid,
      actorRole: role,
      targetType: 'user',
      targetId: targetUserId,
      details: { newRole },
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  await admin.auth().setCustomUserClaims(targetUserId, { role: newRole });

  return { success: true, targetUserId, newRole };
}

async function updateConfig(data, context) {
  const { uid, role } = verifyRole(context, ['admin']);
  const db = admin.firestore();

  const allowedFields = [
    'confidenceThreshold', 'pointsPerCategory', 'duplicateTimeWindowHours',
    'duplicateHammingThreshold', 'maxDailySubmissions', 'leaderboardCacheSeconds',
  ];

  const updates = {};
  for (const field of allowedFields) {
    if (data[field] !== undefined) {
      updates[field] = data[field];
    }
  }

  if (Object.keys(updates).length === 0) {
    throw new functions.https.HttpsError('invalid-argument', 'No valid config fields provided');
  }

  const configRef = db.collection('config').doc('system');

  await db.runTransaction(async (transaction) => {
    const configDoc = await transaction.get(configRef);
    const oldConfig = configDoc.data() || {};

    transaction.update(configRef, updates);

    transaction.set(db.collection('audit_log').doc(), {
      eventType: 'CONFIG_UPDATED',
      actorId: uid,
      actorRole: role,
      targetType: 'config',
      targetId: 'system',
      details: { oldValues: oldConfig, newValues: updates },
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  return { success: true, updatedFields: Object.keys(updates) };
}

module.exports = { updateRole, updateConfig, init };
