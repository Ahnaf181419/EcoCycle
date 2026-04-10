const { GoogleGenerativeAI } = require('@google/generative-ai');
const { writeAudit } = require('./rbac');
const { awardPoints } = require('./rewards');

let admin, functions;

function init(adminRef, functionsRef) {
  admin = adminRef;
  functions = functionsRef;
}

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || '');

const PRIMARY_PROMPT = `You are a waste classification expert. Classify the item in this image into exactly one of these categories:
- recyclable (paper, cardboard, plastic bottles, glass, metal cans)
- organic (food waste, yard waste, biodegradable materials)
- e_waste (electronics, batteries, cables, circuit boards)
- hazardous (chemicals, paint, medical waste, fluorescent bulbs)

Respond in this exact JSON format:
{
  "category": "<one of: recyclable, organic, e_waste, hazardous>",
  "confidence": <float between 0.0 and 1.0>,
  "subcategory": "<specific item type, e.g. plastic_bottle>",
  "reasoning": "<brief explanation>"
}

If you cannot clearly identify the item, set confidence below 0.5.`;

const SECONDARY_PROMPT = `You are a materials science analyst. Analyze this item's physical composition
and determine its correct disposal pathway. Focus on material properties
(such as polymer type, biodegradability, toxicity) rather than visual appearance.

Classify into exactly one of: recyclable, organic, e_waste, hazardous.

Respond in this exact JSON format:
{
  "category": "<one of: recyclable, organic, e_waste, hazardous>",
  "confidence": <float between 0.0 and 1.0>,
  "subcategory": "<specific item type>",
  "reasoning": "<brief materials analysis explanation>"
}

If you cannot clearly identify the item, set confidence below 0.5.`;

function parseGeminiResponse(text) {
  try {
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (!jsonMatch) return null;
    const parsed = JSON.parse(jsonMatch[0]);
    if (!['recyclable', 'organic', 'e_waste', 'hazardous'].includes(parsed.category)) {
      return null;
    }
    return {
      category: parsed.category,
      confidence: Math.max(0, Math.min(1, parseFloat(parsed.confidence) || 0)),
      subcategory: parsed.subcategory || null,
      reasoning: parsed.reasoning || '',
    };
  } catch (e) {
    return null;
  }
}

async function classifyWithGemini(imageUrl, prompt) {
  try {
    const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
    const result = await model.generateContent([
      prompt,
      {
        inlineData: {
          mimeType: 'image/jpeg',
          data: await fetchImageAsBase64(imageUrl),
        },
      },
    ]);
    const text = result.response.text();
    return parseGeminiResponse(text);
  } catch (e) {
    console.error('Gemini classification error:', e);
    return null;
  }
}

async function fetchImageAsBase64(imageUrl) {
  const fetch = (await import('node-fetch')).default;
  const response = await fetch(imageUrl);
  const buffer = await response.buffer();
  return buffer.toString('base64');
}

async function computePHash(imageUrl) {
  try {
    const fetch = (await import('node-fetch')).default;
    const sharp = require('sharp');
    const response = await fetch(imageUrl);
    const buffer = await response.buffer();

    const resized = await sharp(buffer)
      .grayscale()
      .resize(32, 32, { fit: 'fill' })
      .raw()
      .toBuffer();

    const dct = computeDCT(Array.from(resized));
    const lowFreq = dct.slice(0, 8).flat().slice(0, 64);
    const median = lowFreq.sort((a, b) => a - b)[Math.floor(lowFreq.length / 2)];

    let hash = '';
    for (let i = 0; i < 64; i++) {
      hash += lowFreq[i] > median ? '1' : '0';
    }
    return hash;
  } catch (e) {
    console.error('pHash computation error:', e);
    return null;
  }
}

function computeDCT(pixels) {
  const N = 32;
  const matrix = [];
  for (let i = 0; i < N; i++) {
    matrix.push(pixels.slice(i * N, (i + 1) * N));
  }

  const result = [];
  for (let u = 0; u < 8; u++) {
    const row = [];
    for (let v = 0; v < 8; v++) {
      let sum = 0;
      for (let i = 0; i < N; i++) {
        for (let j = 0; j < N; j++) {
          sum += matrix[i][j] *
            Math.cos(((2 * i + 1) * u * Math.PI) / (2 * N)) *
            Math.cos(((2 * j + 1) * v * Math.PI) / (2 * N));
        }
      }
      const cu = u === 0 ? 1 / Math.sqrt(2) : 1;
      const cv = v === 0 ? 1 / Math.sqrt(2) : 1;
      row.push((1 / 4) * cu * cv * sum);
    }
    result.push(row);
  }
  return result;
}

function hammingDistance(hash1, hash2) {
  if (!hash1 || !hash2 || hash1.length !== hash2.length) return Infinity;
  let dist = 0;
  for (let i = 0; i < hash1.length; i++) {
    if (hash1[i] !== hash2[i]) dist++;
  }
  return dist;
}

async function classifySubmission(data, context) {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Authentication required');
  }

  const db = admin.firestore();
  const { imageUrl, storagePath, idempotencyKey, tfliteResult } = data;
  const uid = context.auth.uid;

  if (!imageUrl || !storagePath || !idempotencyKey) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
  }

  const existingQuery = await db.collection('submissions')
    .where('idempotencyKey', '==', idempotencyKey)
    .where('userId', '==', uid)
    .limit(1)
    .get();

  if (!existingQuery.empty) {
    const existing = existingQuery.docs[0].data();
    return {
      submissionId: existing.id,
      state: existing.state,
      category: existing.category,
      confidence: existing.confidence,
      pointsAwarded: existing.pointsAwarded,
    };
  }

  const userDoc = await db.collection('users').doc(uid).get();
  const userData = userDoc.data();
  const now = admin.firestore.FieldValue.serverTimestamp();

  const configDoc = await db.collection('config').doc('system').get();
  const config = configDoc.data() || {};
  const threshold = config.confidenceThreshold || 0.7;
  const duplicateWindowHours = config.duplicateTimeWindowHours || 24;
  const duplicateThreshold = config.duplicateHammingThreshold || 5;

  const submissionRef = db.collection('submissions').doc();
  await submissionRef.set({
    id: submissionRef.id,
    userId: uid,
    username: userData.username,
    imageUrl,
    storagePath,
    imageHash: null,
    category: null,
    subcategory: null,
    confidence: null,
    primaryApproach: 'gemini',
    state: 'SUBMITTED',
    pointsAwarded: 0,
    idempotencyKey,
    flaggedReason: null,
    duplicateOf: null,
    classifiedAt: null,
    createdAt: now,
    updatedAt: now,
  });

  const imageHash = await computePHash(imageUrl);

  if (imageHash) {
    await submissionRef.update({ imageHash });
    const windowStart = new Date(Date.now() - duplicateWindowHours * 60 * 60 * 1000);
    const recentSubs = await db.collection('submissions')
      .where('userId', '==', uid)
      .where('createdAt', '>', windowStart)
      .get();

    for (const doc of recentSubs.docs) {
      if (doc.id === submissionRef.id) continue;
      const existingHash = doc.data().imageHash;
      if (!existingHash) continue;
      const dist = hammingDistance(imageHash, existingHash);
      if (dist < duplicateThreshold) {
        await db.runTransaction(async (transaction) => {
          transaction.update(submissionRef, {
            state: 'FLAGGED_DUPLICATE',
            flaggedReason: 'duplicate',
            duplicateOf: doc.id,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          transaction.set(db.collection('audit_log').doc(), {
            eventType: 'DUPLICATE_FLAGGED',
            actorId: uid,
            actorRole: 'system',
            targetType: 'submission',
            targetId: submissionRef.id,
            details: { duplicateOf: doc.id, hammingDistance: dist },
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
          });
        });

        return {
          submissionId: submissionRef.id,
          state: 'FLAGGED_DUPLICATE',
          category: null,
          confidence: null,
          pointsAwarded: 0,
        };
      }
    }
  }

  let primaryResult = null;
  let secondaryResult = null;

  const isWeb = !tfliteResult;

  if (isWeb) {
    const [primary, secondary] = await Promise.all([
      classifyWithGemini(imageUrl, PRIMARY_PROMPT),
      classifyWithGemini(imageUrl, SECONDARY_PROMPT),
    ]);
    primaryResult = primary;
    secondaryResult = secondary;
  } else {
    primaryResult = await classifyWithGemini(imageUrl, PRIMARY_PROMPT);
    secondaryResult = {
      category: tfliteResult.category,
      confidence: tfliteResult.confidence,
      subcategory: null,
      reasoning: 'TFLite on-device classification',
    };
  }

  if (!primaryResult) {
    await submissionRef.update({
      state: 'DISPUTED',
      flaggedReason: 'classification_failed',
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      submissionId: submissionRef.id,
      state: 'DISPUTED',
      category: null,
      confidence: null,
      pointsAwarded: 0,
    };
  }

  const primaryClassRef = db.collection('classifications').doc();
  await primaryClassRef.set({
    id: primaryClassRef.id,
    submissionId: submissionRef.id,
    approach: 'gemini',
    category: primaryResult.category,
    subcategory: primaryResult.subcategory,
    confidence: primaryResult.confidence,
    modelVersion: 'gemini-1.5-flash',
    rawResponse: { reasoning: primaryResult.reasoning },
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  if (secondaryResult) {
    const secondaryClassRef = db.collection('classifications').doc();
    await secondaryClassRef.set({
      id: secondaryClassRef.id,
      submissionId: submissionRef.id,
      approach: isWeb ? 'gemini_secondary' : 'tflite',
      category: secondaryResult.category,
      subcategory: secondaryResult.subcategory,
      confidence: secondaryResult.confidence,
      modelVersion: isWeb ? 'gemini-1.5-flash-secondary' : 'mobilenet-v2',
      rawResponse: { reasoning: secondaryResult.reasoning },
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  const classifiedNow = admin.firestore.FieldValue.serverTimestamp();

  if (primaryResult.confidence >= threshold) {
    await submissionRef.update({
      state: 'CLASSIFIED',
      category: primaryResult.category,
      subcategory: primaryResult.subcategory,
      confidence: primaryResult.confidence,
      classifiedAt: classifiedNow,
      updatedAt: classifiedNow,
    });

    await writeAudit(db, {
      eventType: 'STATE_CHANGED',
      actorId: uid,
      actorRole: 'system',
      targetType: 'submission',
      targetId: submissionRef.id,
      details: { from: 'SUBMITTED', to: 'CLASSIFIED', category: primaryResult.category, confidence: primaryResult.confidence },
    });

    await submissionRef.update({
      state: 'VERIFIED',
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const awardResult = await awardPoints(db, submissionRef.id, uid, primaryResult.category, idempotencyKey);

    const updatedDoc = await submissionRef.get();
    const updatedData = updatedDoc.data();

    return {
      submissionId: submissionRef.id,
      state: updatedData.state,
      category: primaryResult.category,
      subcategory: primaryResult.subcategory,
      confidence: primaryResult.confidence,
      pointsAwarded: updatedData.pointsAwarded,
    };
  } else {
    if (secondaryResult && secondaryResult.category === primaryResult.category) {
      const resolvedCategory = primaryResult.category;
      await submissionRef.update({
        state: 'DISPUTED',
        category: primaryResult.category,
        subcategory: primaryResult.subcategory,
        confidence: primaryResult.confidence,
        classifiedAt: classifiedNow,
        updatedAt: classifiedNow,
      });

      const disputeRef = db.collection('disputes').doc();
      await disputeRef.set({
        id: disputeRef.id,
        submissionId: submissionRef.id,
        submitterId: uid,
        originalCategory: primaryResult.category,
        originalConfidence: primaryResult.confidence,
        secondaryCategory: secondaryResult.category,
        secondaryConfidence: secondaryResult.confidence,
        resolvedCategory: resolvedCategory,
        resolvedBy: 'system',
        resolution: 'approved',
        resolutionNote: 'Auto-resolved: both classifiers agree on category despite low confidence',
        status: 'resolved',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        resolvedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      await submissionRef.update({
        state: 'RESOLVED',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      const awardResult = await awardPoints(db, submissionRef.id, uid, resolvedCategory, idempotencyKey);

      const updatedDoc = await submissionRef.get();
      const updatedData = updatedDoc.data();

      return {
        submissionId: submissionRef.id,
        state: updatedData.state,
        category: resolvedCategory,
        subcategory: primaryResult.subcategory,
        confidence: primaryResult.confidence,
        pointsAwarded: updatedData.pointsAwarded,
      };
    } else {
      await submissionRef.update({
        state: 'DISPUTED',
        category: primaryResult.category,
        subcategory: primaryResult.subcategory,
        confidence: primaryResult.confidence,
        classifiedAt: classifiedNow,
        updatedAt: classifiedNow,
      });

      const disputeRef = db.collection('disputes').doc();
      await disputeRef.set({
        id: disputeRef.id,
        submissionId: submissionRef.id,
        submitterId: uid,
        originalCategory: primaryResult.category,
        originalConfidence: primaryResult.confidence,
        secondaryCategory: secondaryResult ? secondaryResult.category : null,
        secondaryConfidence: secondaryResult ? secondaryResult.confidence : null,
        resolvedCategory: null,
        resolvedBy: null,
        resolution: null,
        resolutionNote: null,
        status: 'pending',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        resolvedAt: null,
      });

      await writeAudit(db, {
        eventType: 'STATE_CHANGED',
        actorId: uid,
        actorRole: 'system',
        targetType: 'submission',
        targetId: submissionRef.id,
        details: { from: 'SUBMITTED', to: 'DISPUTED', category: primaryResult.category, confidence: primaryResult.confidence },
      });

      return {
        submissionId: submissionRef.id,
        state: 'DISPUTED',
        category: primaryResult.category,
        subcategory: primaryResult.subcategory,
        confidence: primaryResult.confidence,
        pointsAwarded: 0,
      };
    }
  }
}

module.exports = { classifySubmission, init };
