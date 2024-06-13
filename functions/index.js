const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const firestore = admin.firestore();

exports.updateSubscriptionStatus =
functions.pubsub.schedule("every 24 hours").onRun(async () => {
  const usersRef = firestore.collection("RegisterUsers");
  const snapshot = await usersRef.get();

  snapshot.forEach(async (doc) => {
    const userData = doc.data();
    let counter = userData.counter || "0";

    // Log user data, counter, and status
    console.log(`User Data: ${JSON.stringify(userData)}`);
    console.log(`Counter: ${counter}`);
    console.log(`Status: ${userData.status}`);

    // Increment counter unless it is 0
    if (counter !== "0") {
      counter = (parseInt(counter) + 1).toString();

      // Update counter in Firestore
      await doc.ref.update({
        counter: counter,
      });

      // Check if counter reaches 30
      if (counter >= 30) {
        // Update status to 'unpaid'
        await doc.ref.update({
          subscription: "unpaid",
        });
      }
    }
  });

  return null;
});
