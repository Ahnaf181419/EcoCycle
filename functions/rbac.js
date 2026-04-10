let admin, functions;

function init(adminRef, functionsRef) {
  admin = adminRef;
  functions = functionsRef;
}

function writeAudit(db, { eventType, actorId, actorRole, targetType, targetId, details }) {
  return db.collection('audit_log').add({
    eventType,
    actorId,
    actorRole,
    targetType,
    targetId,
    details: details || {},
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });
}

function verifyRole(context, requiredRoles) {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Authentication required');
  }
  const role = context.auth.token.role || 'citizen';
  if (!requiredRoles.includes(role)) {
    throw new functions.https.HttpsError('permission-denied', `Requires one of: ${requiredRoles.join(', ')}`);
  }
  return { uid: context.auth.uid, role };
}

module.exports = { writeAudit, verifyRole, init };
