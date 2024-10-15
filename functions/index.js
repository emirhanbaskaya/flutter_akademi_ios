// index.js

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.checkUsernameAvailability = functions.https.onCall(
    async (data, context) => {
      const username = data.username;

      if (!username) {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "Username not provided.",
        );
      }

      if (typeof username !== "string" || username.length === 0) {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "Invalid username.",
        );
      }

      try {
        const usersRef = admin.firestore().collection("users");
        const snapshot = await usersRef
            .where("username", "==", username)
            .limit(1)
            .get();

        if (snapshot.empty) {
          return {available: true};
        } else {
          return {available: false};
        }
      } catch (error) {
        console.error("Error checking username:", error);
        throw new functions.https.HttpsError(
            "internal",
            "Error checking username.",
        );
      }
    },
);
