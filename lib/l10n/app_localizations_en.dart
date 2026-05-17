// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CarCare';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageAmharic => 'አማርኛ';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get continueButton => 'Continue';

  @override
  String get back => 'Back';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get Started';

  @override
  String get required => 'Required';

  @override
  String get settings => 'Settings';

  @override
  String get done => 'Done';

  @override
  String get add => 'Add';

  @override
  String get update => 'Update';

  @override
  String get open => 'Open';

  @override
  String get closed => 'Closed';

  @override
  String get emDash => '—';

  @override
  String get atGarage => 'At Garage';

  @override
  String get driver => 'Driver';

  @override
  String get customer => 'Customer';

  @override
  String get garage => 'Garage';

  @override
  String get myGarage => 'My Garage';

  @override
  String get justNow => 'Just now';

  @override
  String get oneMinAgo => '1 min ago';

  @override
  String minsAgo(int count) {
    return '$count mins ago';
  }

  @override
  String get oneHourAgo => '1 hour ago';

  @override
  String hoursAgo(int count) {
    return '$count hours ago';
  }

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Apr';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Aug';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Dec';

  @override
  String get am => 'AM';

  @override
  String get pm => 'PM';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorSignInAgain => 'Please sign in again.';

  @override
  String get errorInvalidCredentials =>
      'Invalid email or password. Please try again.';

  @override
  String get errorForbidden => 'You don\'t have permission to do this.';

  @override
  String get errorNotFound => 'The requested item was not found.';

  @override
  String get errorConnection =>
      'Connection problem. Check your internet and try again.';

  @override
  String get errorApiUnreachable =>
      'Cannot reach the garage server. Set API_BASE_URL in .env to your backend (Android emulator: http://10.0.2.2:4000) and ensure npm run dev is running.';

  @override
  String get pleaseSignIn => 'Please sign in';

  @override
  String get loginWelcome => 'Welcome';

  @override
  String get loginWelcomeSubtitle => 'Sign in to your account to continue';

  @override
  String get createAccountLink => 'Create account';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get password => 'Password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordPlaceholder => 'Enter your password';

  @override
  String get confirmPasswordPlaceholder => 'Confirm your password';

  @override
  String get signIn => 'Sign In';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get signInLink => 'Sign in';

  @override
  String get signUp => 'Sign up';

  @override
  String get createAccount => 'Create Account';

  @override
  String registrationStep(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get tellUsAboutGarage => 'Tell us about your garage';

  @override
  String get garageName => 'Garage Name';

  @override
  String get garageNameRequired => 'Garage name is required';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phonePlaceholder => '+251 9XX XXX XXX, 2519…, or 09XXXXXXXX';

  @override
  String get phoneFormatHint =>
      'Use +251 9XX XXX XXX (13 characters), 2519XXXXXXXX (12 digits), or 09XXXXXXXX (10 digits).';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get emailOtp => 'Email OTP';

  @override
  String get otpHint => 'Enter 6-digit code';

  @override
  String get otpMustBe6Digits => 'OTP must be 6 digits';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get emailVerified => 'Email Verified';

  @override
  String otpExpiresIn(int minutes) {
    return 'OTP expires in $minutes minutes';
  }

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String passwordMinLength(int length) {
    return 'At least $length characters';
  }

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get verifyOtpFirst =>
      'Verify your email OTP first. OTP is required for signup only.';

  @override
  String get verifyOtpBeforeContinue =>
      'Please verify your email OTP before continuing.';

  @override
  String get locationAndServices => 'Location & Services';

  @override
  String get locationServicesSubtitle =>
      'Where are you located and what do you offer?';

  @override
  String get garageAddress => 'Garage Address';

  @override
  String get mapSetExactLocationHint =>
      'Set your exact location on the map to continue';

  @override
  String get servicesOffered => 'Services Offered';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get addressRequired => 'Address is required';

  @override
  String get locationRequired => 'Please set your exact location on the map';

  @override
  String get verification => 'Verification';

  @override
  String get uploadBusinessDocuments => 'Upload your business documents';

  @override
  String get businessLicense => 'Business License';

  @override
  String filePickerError(String error) {
    return 'Unable to open file picker. $error';
  }

  @override
  String get reviewYourInformation => 'Review Your Information';

  @override
  String get phone => 'Phone';

  @override
  String get services => 'Services';

  @override
  String almostDone(String time) {
    return 'Almost done! Your application will be reviewed within $time. You\'ll receive an email as soon as it\'s approved.';
  }

  @override
  String get uploadLicenseRequired =>
      'Please upload your business license (PDF, PNG or JPG)';

  @override
  String get submitApplication => 'Submit Application';

  @override
  String labelColon(String label) {
    return '$label:';
  }

  @override
  String get applicationSubmitted => 'Application Submitted!';

  @override
  String applicationSubmittedBody(String garageName) {
    return 'Thank you for registering, $garageName! Your application is now under review. Once approved by our admin team, your garage will appear on the driver\'s map and you can start receiving service requests.';
  }

  @override
  String expectedApproval(String time) {
    return 'Expected approval time: $time. You\'ll receive an email as a notification once your account is approved.';
  }

  @override
  String get expectedApprovalTime => '24-48 hours';

  @override
  String get gotIt => 'Got It';

  @override
  String get searchAddress => 'Search address or enter manually';

  @override
  String get mapPreview => 'Map Preview';

  @override
  String get mapTapToSet => 'Tap to open map';

  @override
  String get uploadDocument => 'Upload Document';

  @override
  String get supportedDocumentFormats => 'PDF, PNG or JPG (Max 5MB)';

  @override
  String get locationOff =>
      'Location services are turned off. Turn on device location to use your current position.';

  @override
  String get locationDenied =>
      'Location permission was denied. Enable it in app settings to use your current position.';

  @override
  String get locationPermanentlyDenied =>
      'Location permission is permanently denied. Open app settings to allow location access.';

  @override
  String get mapLoadingAddress => 'Loading address...';

  @override
  String get mapAddressUnavailable => 'Address could not be loaded';

  @override
  String get mapConfirmLocationTitle => 'Use this location?';

  @override
  String get mapDriverVisibility =>
      'Drivers will see your garage at this address.';

  @override
  String get mapSetCarefully => 'Please set the pin carefully.';

  @override
  String get mapChangeLocation => 'Change location';

  @override
  String get mapConfirm => 'Confirm';

  @override
  String get mapSelectLocation => 'Select location';

  @override
  String get mapDragOrTap =>
      'Drag the marker or tap on the map to set your garage location.';

  @override
  String get customServices => 'Custom services';

  @override
  String get addCustomService => 'Add custom service';

  @override
  String get customServiceHint => 'e.g. Bodywork, Detailing';

  @override
  String get serviceOilChange => 'Oil Change';

  @override
  String get serviceTireService => 'Tire Service';

  @override
  String get serviceBrakeRepair => 'Brake Repair';

  @override
  String get serviceEngineDiagnostics => 'Engine Diagnostics';

  @override
  String get serviceBatteryService => 'Battery Service';

  @override
  String get serviceAcRepair => 'AC Repair';

  @override
  String get serviceOther => 'Other';

  @override
  String get onboardingTitle1 => 'Manage Appointment Requests';

  @override
  String get onboardingSubtitle1 =>
      'Review incoming bookings, approve or reject requests, and keep your schedule organized.';

  @override
  String get onboardingTitle2 => 'Set Services and Availability';

  @override
  String get onboardingSubtitle2 =>
      'Update your offered services and working slots so customers can book at the right time.';

  @override
  String get onboardingTitle3 => 'Stay Updated with Notifications';

  @override
  String get onboardingSubtitle3 =>
      'Get real-time alerts for new requests, status changes, and important garage updates.';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navAppointments => 'Appointments';

  @override
  String get navServices => 'Services';

  @override
  String get navProfile => 'Profile';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusPendingApproval => 'Pending approval';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusBlocked => 'Blocked';

  @override
  String get statusWarned => 'Warned';

  @override
  String get statsTodayAppointments => 'Today\'s Appointments';

  @override
  String get statsPendingRequests => 'Pending Requests';

  @override
  String get statsInProgress => 'In Progress';

  @override
  String get statsCompletedToday => 'Completed Today';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String viewAppointmentRequests(int count) {
    return 'View Appointment Requests ($count)';
  }

  @override
  String get updateAvailability => 'Update Availability';

  @override
  String get upcomingAppointments => 'Upcoming Appointments';

  @override
  String get viewAll => 'View All';

  @override
  String get noUpcomingAppointments => 'No upcoming appointments';

  @override
  String get appointmentsTitle => 'Appointments';

  @override
  String get appointmentsSubtitle => 'Manage your service appointments';

  @override
  String get searchAppointmentsHint =>
      'Search by vehicle, plate number or driver name';

  @override
  String get noAppointmentsMatchSearch => 'No appointments match your search';

  @override
  String get noAppointments => 'No appointments';

  @override
  String get filterAll => 'All';

  @override
  String filterChipCount(String label, int count) {
    return '$label ($count)';
  }

  @override
  String get statusPending => 'Pending';

  @override
  String get statusApprovedAppt => 'Approved';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get profileAndSettings => 'Profile & Settings';

  @override
  String get manageGarageInfo => 'Manage your garage information';

  @override
  String get noReviewsYet => 'No reviews yet';

  @override
  String ratingReviews(String rating, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
    );
    return '$rating ($_temp0)';
  }

  @override
  String get viewAllReviews => 'View all reviews';

  @override
  String get tapEditAddress => 'Tap edit to set address';

  @override
  String get availability => 'Availability';

  @override
  String get noAvailabilitySet => 'No availability set';

  @override
  String get openOneDayWeek => 'Open 1 day a week';

  @override
  String openDaysWeek(int count) {
    return 'Open $count days a week';
  }

  @override
  String get onsiteService => 'Onsite Service';

  @override
  String get onsiteServiceSubtitle => 'Offer services at customer location';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'Receive appointment alerts';

  @override
  String get changePassword => 'Change Password';

  @override
  String get changePasswordSubtitle => 'Update account password';

  @override
  String get logout => 'Logout';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get fillAllPasswordFields => 'Please fill all password fields.';

  @override
  String get passwordMin6 => 'New password must be at least 6 characters.';

  @override
  String get passwordsMismatch => 'New passwords do not match.';

  @override
  String get passwordChangedSuccess => 'Password changed successfully.';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get garageInformation => 'Garage information';

  @override
  String get garageNameHint => 'AutoCare Garage';

  @override
  String get emailHintGarage => 'contact@garage.com';

  @override
  String get location => 'Location';

  @override
  String get garageAddressHint => 'Garage address';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get setAvailability => 'Set Availability';

  @override
  String get configureWorkingHours => 'Configure your working hours.';

  @override
  String timeSlot(int number) {
    return 'Time Slot $number';
  }

  @override
  String get removeTimeSlot => 'Remove time slot';

  @override
  String get opening => 'Opening';

  @override
  String get closing => 'Closing';

  @override
  String get addTimeSlot => 'Add Time Slot';

  @override
  String get dayMonday => 'Monday';

  @override
  String get dayTuesday => 'Tuesday';

  @override
  String get dayWednesday => 'Wednesday';

  @override
  String get dayThursday => 'Thursday';

  @override
  String get dayFriday => 'Friday';

  @override
  String get daySaturday => 'Saturday';

  @override
  String get daySunday => 'Sunday';

  @override
  String get editServices => 'Edit Services';

  @override
  String get servicesYouProvide => 'Services You Provide';

  @override
  String get servicesYouProvideSubtitle =>
      'Select and manage the services your garage offers.';

  @override
  String get servicesSaved => 'Services saved';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String unreadCount(int count) {
    return '$count unread';
  }

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get newAppointmentRequest => 'New appointment request';

  @override
  String newAppointmentRequestBody(String date) {
    return 'A driver requested an appointment for $date.';
  }

  @override
  String get newAppointmentRequestBodyGeneric =>
      'A driver requested a new appointment. Open Appointments to review it.';

  @override
  String get reviewsAndRatings => 'Reviews & Ratings';

  @override
  String get noWrittenReview => 'No written review provided.';

  @override
  String get noComment => 'No comment';

  @override
  String reviewedOn(String date) {
    return 'Reviewed: $date';
  }

  @override
  String appointmentOn(String date) {
    return 'Appointment: $date';
  }

  @override
  String get unknownDate => 'Unknown date';

  @override
  String reviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
    );
    return '$_temp0';
  }
}
