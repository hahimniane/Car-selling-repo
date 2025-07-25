const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

// Load environment variables from .env file
require('dotenv').config();

admin.initializeApp();

// Configure email transporter using environment variables
const createTransporter = () => {
  return nodemailer.createTransporter({
    service: process.env.EMAIL_SERVICE || 'gmail',
    auth: {
      user: process.env.EMAIL_USER || 'noreply@taaoauto.com',
      pass: process.env.EMAIL_PASSWORD || 'your-app-password'
    }
  });
};

// Generate random password
const generateRandomPassword = (length = 12) => {
  const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*";
  let password = "";
  
  // Ensure at least one of each type
  password += "ABCDEFGHIJKLMNOPQRSTUVWXYZ"[Math.floor(Math.random() * 26)]; // uppercase
  password += "abcdefghijklmnopqrstuvwxyz"[Math.floor(Math.random() * 26)]; // lowercase
  password += "0123456789"[Math.floor(Math.random() * 10)]; // number
  password += "!@#$%^&*"[Math.floor(Math.random() * 8)]; // special char
  
  // Fill the rest randomly
  for (let i = 4; i < length; i++) {
    password += charset[Math.floor(Math.random() * charset.length)];
  }
  
  // Shuffle the password
  return password.split('').sort(() => Math.random() - 0.5).join('');
};

// Send welcome email with credentials
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
            .logo { max-width: 120px; height: auto; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>Welcome to TAAO Auto</h1>
              <p>Car Sales & Transport Services</p>
            </div>
            <div class="content">
              <h2>Hello ${firstName} ${lastName},</h2>
              <p>Your staff account has been created successfully! You can now access the TAAO Auto management system with the credentials below.</p>
              
              <div class="credentials">
                <h3>Your Login Credentials:</h3>
                <p><strong>Email:</strong> ${email}</p>
                <p><strong>Temporary Password:</strong> <span class="password">${password}</span></p>
                <p><strong>Role:</strong> ${userType}</p>
              </div>
              
              <p><strong>What you can do as ${userType}:</strong></p>
              <ul>
                <li>Manage car parking services</li>
                <li>Handle barrel shipping to Guinea</li>
                <li>Process car transport services</li>
                <li>Manage car sales listings</li>
                ${userType === 'admin' ? '<li>Manage other staff members</li><li>Access user management features</li>' : ''}
              </ul>
              
              <p><strong>Important Security Notes:</strong></p>
              <ul>
                <li>Please change your password after your first login</li>
                <li>Keep your credentials secure and do not share them</li>
                <li>Contact the administrator if you have any issues accessing your account</li>
              </ul>
              
              <p>If you have any questions or need assistance, please contact the system administrator.</p>
              
              <p>Best regards,<br>TAAO Auto Management Team</p>
            </div>
            <div class="footer">
              <p>This is an automated message. Please do not reply to this email.</p>
              <p>TAAO Auto - Car Sales & Transport Services</p>
            </div>
          </div>
        </body>
        </html>
      `
    };

    await transporter.sendMail(mailOptions);
    console.log(`Welcome email sent to ${email}`);
    return true;
  } catch (error) {
    console.error('Error sending welcome email:', error);
    return false;
  }
};

// Main function to create staff user with email
exports.createStaffUser = functions.https.onCall(async (data, context) => {
  console.log("--- NEW STAFF CREATION (TAAO AUTO) ---");
  try {
    // Check if the caller is authenticated and has admin privileges
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    // Get the calling user's data to verify admin status
    const callerUid = context.auth.uid;
    const callerDoc = await admin.firestore().collection('users').doc(callerUid).get();
    
    if (!callerDoc.exists || callerDoc.data().role !== 'admin') {
      throw new functions.https.HttpsError('permission-denied', 'Only admins can create staff accounts');
    }

    // Validate input data
    if (!data || typeof data !== 'object') {
      console.error('Invalid data received:', data);
      throw new functions.https.HttpsError('invalid-argument', 'Data must be an object');
    }

    const {
      email,
      firstName,
      lastName,
      phoneNumber,
      role = 'staff' // default to staff, can be 'staff' or 'admin'
    } = data;

    console.log('Creating staff user with data:', {
      email: email || 'MISSING',
      firstName: firstName || 'MISSING', 
      lastName: lastName || 'MISSING',
      phoneNumber: phoneNumber || 'MISSING',
      role: role || 'staff'
    });

    // Validate required fields
    const missingFields = [];
    if (!email || String(email).trim() === '') missingFields.push('email');
    if (!firstName || String(firstName).trim() === '') missingFields.push('firstName');
    if (!lastName || String(lastName).trim() === '') missingFields.push('lastName');

    if (missingFields.length > 0) {
      console.error('Missing required fields:', missingFields);
      throw new functions.https.HttpsError('invalid-argument', `Missing required fields: ${missingFields.join(', ')}`);
    }

    // Validate role
    if (!['staff', 'admin'].includes(role)) {
      throw new functions.https.HttpsError('invalid-argument', 'Role must be either "staff" or "admin"');
    }

    console.log('All required fields validated successfully');

    // Generate random password
    const password = generateRandomPassword();
    console.log(`Generated password for ${email}`);

    // Create Firebase Auth user
    const userRecord = await admin.auth().createUser({
      email: email.toLowerCase().trim(),
      password: password,
      displayName: `${firstName} ${lastName}`,
      emailVerified: false
    });
    console.log(`Auth user created with UID: ${userRecord.uid}`);

    // Prepare Firestore data for TAAO Auto
    const firestoreData = {
      email: email.toLowerCase().trim(),
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      phoneNumber: phoneNumber || '',
      role: role,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      lastLogin: null,
      isActive: true,
      emailVerified: false,
      uid: userRecord.uid,
      createdBy: callerUid,
      passwordResetRequired: true
    };

    // Create Firestore document
    await admin.firestore()
      .collection("users")
      .doc(userRecord.uid)
      .set(firestoreData);
    console.log(`Firestore document created for UID: ${userRecord.uid}`);

    // Send welcome email
    const emailSent = await sendWelcomeEmail(email, firstName, lastName, password, role);

    return {
      success: true,
      uid: userRecord.uid,
      emailSent: emailSent,
      message: `Staff user created successfully. Email ${emailSent ? 'sent' : 'failed'}.`
    };

  } catch (error) {
    console.error("--- STAFF CREATION ERROR ---");
    console.error("ERROR MESSAGE:", error.message);
    console.error("ERROR STACK:", error.stack);
    
    // If it's already an HttpsError, rethrow it
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    // Re-throw a clean error to the client
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// Batch create staff users (for bulk operations)
exports.createMultipleStaff = functions.https.onCall(async (data, context) => {
  console.log("Creating multiple staff users:", JSON.stringify(data, null, 2));
  
  try {
    // Check authentication and admin status
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const callerUid = context.auth.uid;
    const callerDoc = await admin.firestore().collection('users').doc(callerUid).get();
    
    if (!callerDoc.exists || callerDoc.data().role !== 'admin') {
      throw new functions.https.HttpsError('permission-denied', 'Only admins can create staff accounts');
    }

    if (!data || !Array.isArray(data.users)) {
      console.error('Invalid batch data:', data);
      throw new functions.https.HttpsError('invalid-argument', 'Users array is required');
    }

    console.log(`Processing ${data.users.length} users for batch creation`);
    const results = [];
    const errors = [];

    for (let i = 0; i < data.users.length; i++) {
      const userData = data.users[i];
      console.log(`Processing user ${i + 1}:`, JSON.stringify(userData, null, 2));
      
      try {
        const {
          email,
          firstName,
          lastName,
          phoneNumber,
          role = 'staff'
        } = userData;

        // Validate required fields
        const missingFields = [];
        if (!email || email.trim() === '') missingFields.push('email');
        if (!firstName || firstName.trim() === '') missingFields.push('firstName');
        if (!lastName || lastName.trim() === '') missingFields.push('lastName');

        if (missingFields.length > 0) {
          throw new Error(`Missing required fields: ${missingFields.join(', ')}`);
        }

        // Generate random password
        const password = generateRandomPassword();

        // Create Firebase Auth user
        const userRecord = await admin.auth().createUser({
          email: email.toLowerCase().trim(),
          password: password,
          displayName: `${firstName} ${lastName}`,
          emailVerified: false
        });

        // Prepare Firestore data
        const firestoreData = {
          email: email.toLowerCase().trim(),
          firstName: firstName.trim(),
          lastName: lastName.trim(),
          phoneNumber: phoneNumber || '',
          role: role,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          lastLogin: null,
          isActive: true,
          emailVerified: false,
          uid: userRecord.uid,
          createdBy: callerUid,
          passwordResetRequired: true
        };

        // Create Firestore document
        await admin.firestore()
          .collection("users")
          .doc(userRecord.uid)
          .set(firestoreData);

        // Send welcome email
        const emailSent = await sendWelcomeEmail(email, firstName, lastName, password, role);

        const result = {
          success: true,
          uid: userRecord.uid,
          email: email.toLowerCase().trim(),
          emailSent: emailSent,
          message: emailSent 
            ? "User created successfully and welcome email sent"
            : "User created successfully but email sending failed"
        };

        results.push({
          email: userData.email,
          success: true,
          result: result
        });
        console.log(`User ${i + 1} created successfully`);
      } catch (error) {
        console.error(`User ${i + 1} creation failed:`, error.message);
        errors.push({
          email: userData.email || 'unknown',
          success: false,
          error: error.message
        });
      }
    }

    return {
      totalUsers: data.users.length,
      successful: results.length,
      failed: errors.length,
      results: results,
      errors: errors
    };

  } catch (error) {
    console.error('Error in createMultipleStaff:', error);
    throw new functions.https.HttpsError('internal', 'Batch staff creation failed');
  }
});

// Function to update staff user role (admin only)
exports.updateStaffRole = functions.https.onCall(async (data, context) => {
  try {
    // Check authentication and admin status
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const callerUid = context.auth.uid;
    const callerDoc = await admin.firestore().collection('users').doc(callerUid).get();
    
    if (!callerDoc.exists || callerDoc.data().role !== 'admin') {
      throw new functions.https.HttpsError('permission-denied', 'Only admins can update user roles');
    }

    const { uid, newRole } = data;

    if (!uid || !newRole) {
      throw new functions.https.HttpsError('invalid-argument', 'UID and newRole are required');
    }

    if (!['customer', 'staff', 'admin'].includes(newRole)) {
      throw new functions.https.HttpsError('invalid-argument', 'Invalid role specified');
    }

    // Update the user's role in Firestore
    await admin.firestore().collection('users').doc(uid).update({
      role: newRole,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: callerUid
    });

    return {
      success: true,
      message: `User role updated to ${newRole} successfully`
    };

  } catch (error) {
    console.error('Error updating staff role:', error);
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError('internal', 'Failed to update user role');
  }
});