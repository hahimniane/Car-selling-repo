const admin = require("firebase-admin");

// Initialize Firebase Admin
admin.initializeApp();

async function fixAdminRole() {
  try {
    const uid = "lTWdx1S9xQWtz4BtDuL0RLHM0Ph1"; // Your UID from logs
    const email = "admin@gmail.com";

    console.log(`Updating user ${email} (${uid}) to admin role...`);

    await admin.firestore().collection("users").doc(uid).set({
      email: email,
      role: "admin",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      fixedBy: "admin-fix-script",
    }, {merge: true});

    console.log("✅ Admin role updated successfully!");

    // Verify the update
    const doc = await admin.firestore().collection("users").doc(uid).get();
    console.log("📄 Updated document:", doc.data());
  } catch (error) {
    console.error("❌ Error:", error);
  }

  process.exit(0);
}

fixAdminRole();
