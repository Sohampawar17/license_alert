const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// Function to send a notification
async function sendNotification(userId, title, body) {
  const userRef = db.collection("licenses_data").doc(userId);
  const userDoc = await userRef.get();
  
  if (!userDoc.exists) {
    console.log(`User ${userId} not found`);
    return;
  }

  const userData = userDoc.data();
  const fcmToken = userData.fcmToken; // Store user's FCM token in Firestore

  if (!fcmToken) {
    console.log(`No FCM token found for user ${userId}`);
    return;
  }

  const message = {
    token: fcmToken,
    notification: {
      title: title,
      body: body,
    },
    android: {
      priority: "high",
      notification: {
        sound: "default",
      },
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
        },
      },
    },
  };

  try {
    await messaging.send(message);
    console.log(`Notification sent to ${userId}`);
  } catch (error) {
    console.error("Error sending notification:", error);
  }
}

// Scheduled function to check for expiry
exports.checkExpiry = functions.pubsub.schedule("every 24 hours").onRun(async (context) => {
  const today = new Date().toISOString().split("T")[0]; // Get today's date in YYYY-MM-DD format

  const usersSnapshot = await db.collection("licenses_data").get();

  usersSnapshot.forEach(async (userDoc) => {
    const userData = userDoc.data();
    const userId = userDoc.id;

    if (userData.licenseDetails && userData.licenseDetails.doe === today) {
      await sendNotification(userId, "License Expiry", "Your license is expiring today. Please renew it.");
    }

    if (userData.PUC && userData.PUC.dateOfExpiry === today) {
      await sendNotification(userId, "PUC Expiry", "Your PUC is expiring today. Please renew it.");
    }
  });

  console.log("Expiry check completed");
});
