// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInToAccount => 'Sign in to your account';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get signIn => 'Sign In';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get forgotPasswordTitle => 'Forgot Password?';

  @override
  String get enterEmailToReset => 'Enter your email to reset your password';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get emailSent => 'Email Sent!';

  @override
  String get emailSentMessage => 'We\'ve sent a password reset link to your email address. Please check your inbox and follow the instructions.';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get welcomeToBusinessServices => 'Welcome to Business Services';

  @override
  String get chooseServiceToStart => 'Choose a service to get started';

  @override
  String get parkACar => 'Park a Car';

  @override
  String get sendBarrelsToGuinea => 'Package Shipping';

  @override
  String get transportCarsToGuinea => 'Transport Cars to Guinea';

  @override
  String get sellCars => 'Sell Cars';

  @override
  String get carParkingService => 'Car Parking Service';

  @override
  String get enterCarDetailsToGenerateReceipt => 'Enter car details to generate receipt';

  @override
  String get printReceipt => 'Print Receipt';

  @override
  String get name => 'Name';

  @override
  String get make => 'Make';

  @override
  String get model => 'Model';

  @override
  String get year => 'Year';

  @override
  String get vinNumber => 'VIN Number';

  @override
  String get parkingDate => 'Parking Date';

  @override
  String get parkingDateTime => 'Parking Date & Time';

  @override
  String get selectDateTime => 'Select Date & Time';

  @override
  String get receiptGenerated => 'Receipt generated and sent to printer successfully!';

  @override
  String errorGeneratingReceipt(Object error) {
    return 'Error generating receipt: $error';
  }

  @override
  String get pleaseEnterOwnerName => 'Please enter the owner name';

  @override
  String get pleaseEnterCarMake => 'Please enter the car make';

  @override
  String get pleaseEnterCarModel => 'Please enter the car model';

  @override
  String get pleaseEnterCarYear => 'Please enter the car year';

  @override
  String get pleaseEnterVinNumber => 'Please enter the VIN number';

  @override
  String get done => 'Done';

  @override
  String get account => 'Account';

  @override
  String get role => 'Role';

  @override
  String get logout => 'Logout';

  @override
  String get signOutOfAccount => 'Sign out of your account';

  @override
  String get customer => 'Customer';

  @override
  String get staff => 'Staff';

  @override
  String get barrelShippingService => 'Package Shipping Service';

  @override
  String get enterShippingDetailsForGuinea => 'Enter shipping details and destination';

  @override
  String get submit => 'Submit';

  @override
  String get senderName => 'Sender Name';

  @override
  String get address => 'Address';

  @override
  String get receiverName => 'Receiver Name';

  @override
  String get receiverPhone => 'Receiver Phone';

  @override
  String get price => 'Price';

  @override
  String get carTransportService => 'Car Transport Service';

  @override
  String get enterCarTransportDetailsForGuinea => 'Enter car transport details and destination';

  @override
  String get ownerName => 'Owner Name';

  @override
  String get carMake => 'Car Make';

  @override
  String get carModel => 'Car Model';

  @override
  String get carYear => 'Car Year';

  @override
  String get transportDate => 'Transport Date';

  @override
  String get carSalesService => 'Car Sales Service';

  @override
  String get browseAvailableCarsForSale => 'Browse available cars for sale';

  @override
  String get searchCars => 'Search cars...';

  @override
  String get chatWithSeller => 'Chat with Seller';

  @override
  String get toyotaCamry => 'Toyota Camry';

  @override
  String get hondaAccord => 'Honda Accord';

  @override
  String get fordEscape => 'Ford Escape';

  @override
  String yearLabel(Object year) {
    return 'Year: $year';
  }

  @override
  String mileageLabel(Object mileage) {
    return 'Mileage: $mileage';
  }

  @override
  String get mileage => 'mileage';

  @override
  String get carDetails => 'Car Details';

  @override
  String get contactSeller => 'Contact Seller';

  @override
  String get viewMorePhotos => 'View More Photos';

  @override
  String get carDescription => 'Car Description';

  @override
  String get features => 'Features';

  @override
  String get contactInfo => 'Contact Information';

  @override
  String get sendWhatsAppMessage => 'Send WhatsApp Message';

  @override
  String whatsAppMessage(Object carPrice, Object carTitle, Object carYear) {
    return 'Hi! I\'m interested in the $carTitle ($carYear) for $carPrice. Can you provide more details?';
  }

  @override
  String get noResultsFound => 'No results found';

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get appInformation => 'App Information';

  @override
  String get appVersion => 'App Version';

  @override
  String get companyName => 'Company Name';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get about => 'About';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get manageCars => 'Manage Cars';

  @override
  String get totalCars => 'Total Cars';

  @override
  String get activeCars => 'Active Cars';

  @override
  String get inactiveCars => 'Inactive Cars';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get addNewCar => 'Add New Car';

  @override
  String get carTitle => 'Car Title';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get editCar => 'Edit Car';

  @override
  String get save => 'Save';

  @override
  String get staffAccess => 'Staff Access';

  @override
  String get staffLogin => 'Staff Login';

  @override
  String get accessStaffFeatures => 'Access staff features and management tools';

  @override
  String get invalidCredentials => 'Invalid email or password';

  @override
  String get backToCustomerHome => 'Back to Customer Home';

  @override
  String get trackShipment => 'Track Shipment';

  @override
  String get tracking => 'Tracking';

  @override
  String get userManagement => 'User Management';

  @override
  String get setAsCustomer => 'Set as Customer';

  @override
  String get setAsStaff => 'Set as Staff';

  @override
  String get setAsAdmin => 'Set as Admin';

  @override
  String get addStaffMember => 'Add Staff Member';

  @override
  String get users => 'Users';

  @override
  String get noUsersFound => 'No users found.';

  @override
  String get enterStaffEmail => 'Enter staff email';

  @override
  String get enterTemporaryPassword => 'Enter temporary password';

  @override
  String userRoleUpdated(String newRole) {
    return 'User role updated to $newRole';
  }

  @override
  String failedToUpdateUserRole(String error) {
    return 'Failed to update user role: $error';
  }

  @override
  String get staffMemberAddedSuccessfully => 'Staff member added successfully!';

  @override
  String failedToAddStaffMember(String error) {
    return 'Failed to add staff member: $error';
  }

  @override
  String get admin => 'Admin';

  @override
  String get changePassword => 'Change Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get enterCurrentPassword => 'Enter your current password';

  @override
  String get enterNewPassword => 'Enter your new password';

  @override
  String get confirmNewPasswordField => 'Confirm your new password';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get passwordChanged => 'Password Changed';

  @override
  String get passwordChangedSuccessfully => 'Your password has been changed successfully!';

  @override
  String get passwordsMustMatch => 'Passwords must match';

  @override
  String get newPasswordMinLength => 'New password must be at least 6 characters';

  @override
  String get passwordChangeRequired => 'Password Change Required';

  @override
  String get passwordChangeRequiredMessage => 'For security reasons, you need to change your password from the default one.';

  @override
  String get changePasswordNow => 'Change Password Now';

  @override
  String get skipForNow => 'Skip for Now';

  @override
  String get updateAccountPassword => 'Update your account password';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get enterFirstName => 'Enter first name';

  @override
  String get enterLastName => 'Enter last name';

  @override
  String get addStaffInfo => 'The new staff member will be created with a default password of \"123456\". They will be required to change it upon first login.';

  @override
  String get selectMake => 'Select Make';

  @override
  String get selectModel => 'Select Model';

  @override
  String get selectYear => 'Select Year';

  @override
  String get selectPriceRange => 'Select Price Range';

  @override
  String get selectMileageRange => 'Select Mileage Range';

  @override
  String get description => 'Description';

  @override
  String get fuelType => 'Fuel Type';

  @override
  String get transmission => 'Transmission';

  @override
  String get bodyType => 'Body Type';

  @override
  String get condition => 'Condition';

  @override
  String get selectFuelType => 'Select Fuel Type';

  @override
  String get selectTransmission => 'Select Transmission';

  @override
  String get selectBodyType => 'Select Body Type';

  @override
  String get selectCondition => 'Select Condition';

  @override
  String get gasoline => 'Gasoline';

  @override
  String get diesel => 'Diesel';

  @override
  String get hybrid => 'Hybrid';

  @override
  String get electric => 'Electric';

  @override
  String get manual => 'Manual';

  @override
  String get automatic => 'Automatic';

  @override
  String get sedan => 'Sedan';

  @override
  String get suv => 'SUV';

  @override
  String get hatchback => 'Hatchback';

  @override
  String get coupe => 'Coupe';

  @override
  String get convertible => 'Convertible';

  @override
  String get pickup => 'Pickup';

  @override
  String get wagon => 'Wagon';

  @override
  String get excellent => 'Excellent';

  @override
  String get good => 'Good';

  @override
  String get fair => 'Fair';

  @override
  String get poor => 'Poor';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter phone number';

  @override
  String get viewRecords => 'View Records';

  @override
  String get parkingRecords => 'Parking Records';

  @override
  String get packageRecords => 'Package Records';

  @override
  String get transportRecords => 'Transport Records';

  @override
  String get salesRecords => 'Sales Records';

  @override
  String get manageParkingRecords => 'Manage Parking Records';

  @override
  String get managePackageRecords => 'Manage Package Records';

  @override
  String get manageTransportRecords => 'Manage Transport Records';

  @override
  String get manageSalesRecords => 'Manage Sales Records';

  @override
  String get editRecord => 'Edit Record';

  @override
  String get deleteRecord => 'Delete Record';

  @override
  String get recordDeleted => 'Record deleted successfully';

  @override
  String get recordUpdated => 'Record updated successfully';

  @override
  String get confirmDelete => 'Are you sure you want to delete this record?';

  @override
  String get deleteConfirmation => 'Delete Confirmation';

  @override
  String get status => 'Status';

  @override
  String get createdAt => 'Created At';

  @override
  String get destination => 'Destination';

  @override
  String get packageType => 'Package Type';

  @override
  String get weight => 'Weight';

  @override
  String get dimensions => 'Dimensions';

  @override
  String get transportMethod => 'Transport Method';

  @override
  String get pickupLocation => 'Pickup Location';

  @override
  String get deliveryLocation => 'Delivery Location';

  @override
  String get estimatedDelivery => 'Estimated Delivery';

  @override
  String get markSold => 'Mark Sold';

  @override
  String get sold => 'Sold';

  @override
  String get markCarAsSold => 'Mark Car as Sold';

  @override
  String get customerName => 'Customer Name';

  @override
  String get customerPhone => 'Customer Phone';

  @override
  String get salePrice => 'Sale Price';

  @override
  String get markAsSold => 'Mark as Sold';

  @override
  String get pleaseEnterAllFields => 'Please fill in all fields';

  @override
  String get carMarkedAsSoldSuccess => 'Car marked as sold and sales record created!';

  @override
  String get errorMarkingCarAsSold => 'Error marking car as sold';

  @override
  String get packageRecordCreated => 'Package record created successfully!';

  @override
  String get updatePackageStatus => 'Update Package Status';

  @override
  String get updateTransportStatus => 'Update Transport Status';

  @override
  String get currentStatus => 'Current Status';

  @override
  String get updateStatus => 'Update Status';

  @override
  String get statusUpdatedSuccessfully => 'Status updated successfully!';

  @override
  String get contactStaffForUpdates => 'Contact staff for status updates';
}
