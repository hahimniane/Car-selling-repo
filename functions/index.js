const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

const createTransporter = () => {
  // Using simplified config. For production, use Firebase config variables.
  return nodemailer.createTransporter({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL_USER || 'noreply@taaoauto.com',
      pass: process.env.EMAIL_PASSWORD || 'your-app-password',
    },
  });
};

const sendWelcomeEmail = async (email, firstName, lastName, password, userType) => {
  try {
    const transporter = createTransporter();
    const mailOptions = {
      from: process.env.EMAIL_USER || 'noreply@taaoauto.com',
      to: email,
      subject: 'Welcome to TAAO Auto - Your Staff Account Details',
      html: `
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body { font-family: Arial, sans-serif; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #1B365D; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; background-color: #f9f9f9; }
            .credentials { background-color: white; padding: 15px; border-left: 4px solid #1B365D; margin: 20px 0; }
            .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
            .password { font-family: monospace; font-size: 16px; color: #e53e3e; font-weight: bold; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header"><h1>Welcome to TAAO Auto</h1></div>
            <div class="content">
              <h2>Hello ${firstName} ${lastName},</h2>
              <p>Your staff account has been created successfully! You can now access the TAAO Auto management system with the credentials below.</p>
              <div class="credentials">
                <h3>Your Login Credentials:</h3>
                <p><strong>Email:</strong> ${email}</p>
                <p><strong>Temporary Password:</strong> <span class="password">${password}</span></p>
                <p><strong>Role:</strong> ${userType}</p>
              </div>
              <p><strong>Important:</strong> Please change your password after your first login for security.</p>
              <p>Best regards,<br>TAAO Auto Management Team</p>
            </div>
            <div class="footer"><p>This is an automated message. Please do not reply.</p></div>
          </div>
        </body>
        </html>
      `,
    };

    await transporter.sendMail(mailOptions);
    console.log(`Welcome email sent to ${email}`);
    return true;
  } catch (error) {
    console.error('Error sending welcome email:', error);
    return false;
  }
};

exports.createStaffUser = functions.https.onCall(async (data, context) => {
  console.log("--- NEW STAFF CREATION (Unauthenticated v3) ---");
  try {
    if (!data || typeof data !== 'object') {
      throw new functions.https.HttpsError('invalid-argument', 'Data must be an object.');
    }

    // FIX: Unwrap the data payload from the client SDK
    const userData = data.data || data;

    const {
      email,
      firstName,
      lastName,
      phoneNumber,
      role = 'staff',
    } = userData;

    console.log('Creating staff user with data:', { email, firstName, lastName });

    const missingFields = [];
    if (!email) missingFields.push('email');
    if (!firstName) missingFields.push('firstName');
    if (!lastName) missingFields.push('lastName');

    if (missingFields.length > 0) {
      throw new functions.https.HttpsError('invalid-argument', `Missing required fields: ${missingFields.join(', ')}`);
    }

    // Use the fixed default password
    const password = '123456';
    console.log(`Set default password for ${email}`);

    const userRecord = await admin.auth().createUser({
      email: email.toLowerCase().trim(),
      password: password,
      displayName: `${firstName} ${lastName}`,
    });
    console.log(`Auth user created with UID: ${userRecord.uid}`);

    const firestoreData = {
      email: email.toLowerCase().trim(),
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      phoneNumber: phoneNumber || '',
      role: role,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      uid: userRecord.uid,
      passwordResetRequired: true,
    };

    await admin.firestore()
      .collection("users")
      .doc(userRecord.uid)
      .set(firestoreData);
    console.log(`Firestore document created for UID: ${userRecord.uid}`);

    const emailSent = await sendWelcomeEmail(email, firstName, lastName, password, role);

    return {
      success: true,
      uid: userRecord.uid,
      emailSent: emailSent,
    };
  } catch (error) {
    console.error("--- STAFF CREATION ERROR ---");
    console.error("ERROR MESSAGE:", error.message);
    throw new functions.https.HttpsError('internal', error.message);
  }
});
