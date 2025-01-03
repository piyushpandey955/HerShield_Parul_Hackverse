/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// import { onRequest } from "firebase-functions/v2/https";
// import { info } from "firebase-functions/logger";

// export const helloWorld = onRequest((request, response) => {
//   info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });


import { firestore } from "firebase-functions";
import { initializeApp, messaging } from "firebase-admin";
initializeApp();

export const sendPanicAlert = firestore.document("alerts/{alertId}").onCreate(async (snap, context) => {
  const alertData = snap.data();
  const alertLocation = alertData.location;  // Assume you store location here
  const nearbyUserTokens = alertData.nearbyUserTokens;  // Array of device tokens

  const payload = {
    notification: {
      title: "Panic Alert!",
      body: `User is in distress! Location: ${alertLocation}`,
      clickAction: "FLUTTER_NOTIFICATION_CLICK",
    },
    data: {
      location: alertLocation,
    }
  };

  const options = {
    priority: "high",
  };

  try {
    const response = await messaging().send(nearbyUserTokens, payload, options);
    console.log("Notification sent successfully:", response);
  } catch (error) {
    console.error("Error sending notification:", error);
  }
});
