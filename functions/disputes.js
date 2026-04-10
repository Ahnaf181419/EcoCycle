const { writeAudit, verifyRole } = require('./rbac');
const { awardPoints } = require('./rewards');

let admin;

function init(adminRef) {
  admin = adminRef;
}

async function resolveDispute(data, context) {
  const { uid, role } = verifyRole(context, ['moderator', 'admin']);
  const db = admin.firestore();
  const { disputeId, resolution, category, note } = data;

  if (!disputeId || !resolution) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
  }

  if (!['approved', 'overridden', 'rejected'].includes(resolution)) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid resolution');
  }

  const disputeDoc = await db.collection('disputes').doc(disputeId).get();
  if (!disputeDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'Dispute not found');
  }

  const dispute = disputeDoc.data();
  if (dispute.status !== 'pending') {
    throw new functions.https.HttpsError('failed-precondition', 'Dispute already resolved');
  }

  const submissionDoc = await db.collection('submissions').doc(dispute.submissionId).get();
  if (!submissionDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'Submission not found');
  }

  const resolvedCategory = resolution === 'overridden'
      ? (category || dispute.originalCategory)
      : dispute.originalCategory;

  await db.runTransaction(async (transaction) => {
    transaction.update(db.collection('disputes').doc(disputeId), {
      status: 'resolved',
      resolvedCategory,
      resolvedBy: uid,
      resolution,
      resolutionNote: note || null,
      resolvedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    if (resolution === 'rejected') {
      transaction.update(db.collection('submissions').doc(dispute.submissionId), {
        state: 'REJECTED',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } else {
      transaction.update(db.collection('submissions').doc(dispute.submissionId), {
        state: 'RESOLVED',
        category: resolvedCategory,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    transaction.set(db.collection('audit_log').doc(), {
      eventType: 'DISPUTE_RESOLVED',
      actorId: uid,
      actorRole: role,
      targetType: 'dispute',
      targetId: disputeId,
      details: { resolution, resolvedCategory, note },
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  if (resolution !== 'rejected') {
    await awardPoints(db, dispute.submissionId, dispute.submitterId, resolvedCategory, `dispute_${disputeId}`);
  }

  return { success: true, disputeId, resolution, resolvedCategory };
}

module.exports = { resolveDispute, init };
