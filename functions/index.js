const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const classify = require('./classify');
const disputes = require('./disputes');
const rewards = require('./rewards');
const social = require('./social');
const adminFn = require('./admin');
const rbac = require('./rbac');

rbac.init(admin, functions);
classify.init(admin, functions);
rewards.init(admin);
disputes.init(admin);
social.init(admin);
adminFn.init(admin);

exports.classifySubmission = functions.https.onCall(classify.classifySubmission);
exports.resolveDispute = functions.https.onCall(disputes.resolveDispute);
exports.redeemPoints = functions.https.onCall(rewards.redeemPoints);
exports.followUser = functions.https.onCall(social.followUser);
exports.unfollowUser = functions.https.onCall(social.unfollowUser);
exports.updateRole = functions.https.onCall(adminFn.updateRole);
exports.updateConfig = functions.https.onCall(adminFn.updateConfig);
