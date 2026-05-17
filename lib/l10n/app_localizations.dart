import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'CarCare'**
  String get appTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageAmharic.
  ///
  /// In en, this message translates to:
  /// **'አማርኛ'**
  String get languageAmharic;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @emDash.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get emDash;

  /// No description provided for @atGarage.
  ///
  /// In en, this message translates to:
  /// **'At Garage'**
  String get atGarage;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @garage.
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get garage;

  /// No description provided for @myGarage.
  ///
  /// In en, this message translates to:
  /// **'My Garage'**
  String get myGarage;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @oneMinAgo.
  ///
  /// In en, this message translates to:
  /// **'1 min ago'**
  String get oneMinAgo;

  /// No description provided for @minsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} mins ago'**
  String minsAgo(int count);

  /// No description provided for @oneHourAgo.
  ///
  /// In en, this message translates to:
  /// **'1 hour ago'**
  String get oneHourAgo;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String hoursAgo(int count);

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @monthJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthDec;

  /// No description provided for @am.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get am;

  /// No description provided for @pm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get pm;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorSignInAgain.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again.'**
  String get errorSignInAgain;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password. Please try again.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to do this.'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'The requested item was not found.'**
  String get errorNotFound;

  /// No description provided for @errorConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection problem. Check your internet and try again.'**
  String get errorConnection;

  /// No description provided for @errorApiUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the garage server. Set API_BASE_URL in .env to your backend (Android emulator: http://10.0.2.2:4000) and ensure npm run dev is running.'**
  String get errorApiUnreachable;

  /// No description provided for @pleaseSignIn.
  ///
  /// In en, this message translates to:
  /// **'Please sign in'**
  String get pleaseSignIn;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get loginWelcome;

  /// No description provided for @loginWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account to continue'**
  String get loginWelcomeSubtitle;

  /// No description provided for @createAccountLink.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccountLink;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordPlaceholder;

  /// No description provided for @confirmPasswordPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmPasswordPlaceholder;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @signInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInLink;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @registrationStep.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String registrationStep(int current, int total);

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @tellUsAboutGarage.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your garage'**
  String get tellUsAboutGarage;

  /// No description provided for @garageName.
  ///
  /// In en, this message translates to:
  /// **'Garage Name'**
  String get garageName;

  /// No description provided for @garageNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Garage name is required'**
  String get garageNameRequired;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phonePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'+251 9XX XXX XXX, 2519…, or 09XXXXXXXX'**
  String get phonePlaceholder;

  /// No description provided for @phoneFormatHint.
  ///
  /// In en, this message translates to:
  /// **'Use +251 9XX XXX XXX (13 characters), 2519XXXXXXXX (12 digits), or 09XXXXXXXX (10 digits).'**
  String get phoneFormatHint;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @emailOtp.
  ///
  /// In en, this message translates to:
  /// **'Email OTP'**
  String get emailOtp;

  /// No description provided for @otpHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit code'**
  String get otpHint;

  /// No description provided for @otpMustBe6Digits.
  ///
  /// In en, this message translates to:
  /// **'OTP must be 6 digits'**
  String get otpMustBe6Digits;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @emailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email Verified'**
  String get emailVerified;

  /// No description provided for @otpExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'OTP expires in {minutes} minutes'**
  String otpExpiresIn(int minutes);

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'At least {length} characters'**
  String passwordMinLength(int length);

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @verifyOtpFirst.
  ///
  /// In en, this message translates to:
  /// **'Verify your email OTP first. OTP is required for signup only.'**
  String get verifyOtpFirst;

  /// No description provided for @verifyOtpBeforeContinue.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email OTP before continuing.'**
  String get verifyOtpBeforeContinue;

  /// No description provided for @locationAndServices.
  ///
  /// In en, this message translates to:
  /// **'Location & Services'**
  String get locationAndServices;

  /// No description provided for @locationServicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Where are you located and what do you offer?'**
  String get locationServicesSubtitle;

  /// No description provided for @garageAddress.
  ///
  /// In en, this message translates to:
  /// **'Garage Address'**
  String get garageAddress;

  /// No description provided for @mapSetExactLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Set your exact location on the map to continue'**
  String get mapSetExactLocationHint;

  /// No description provided for @servicesOffered.
  ///
  /// In en, this message translates to:
  /// **'Services Offered'**
  String get servicesOffered;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @addressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get addressRequired;

  /// No description provided for @locationRequired.
  ///
  /// In en, this message translates to:
  /// **'Please set your exact location on the map'**
  String get locationRequired;

  /// No description provided for @verification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification;

  /// No description provided for @uploadBusinessDocuments.
  ///
  /// In en, this message translates to:
  /// **'Upload your business documents'**
  String get uploadBusinessDocuments;

  /// No description provided for @businessLicense.
  ///
  /// In en, this message translates to:
  /// **'Business License'**
  String get businessLicense;

  /// No description provided for @filePickerError.
  ///
  /// In en, this message translates to:
  /// **'Unable to open file picker. {error}'**
  String filePickerError(String error);

  /// No description provided for @reviewYourInformation.
  ///
  /// In en, this message translates to:
  /// **'Review Your Information'**
  String get reviewYourInformation;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @almostDone.
  ///
  /// In en, this message translates to:
  /// **'Almost done! Your application will be reviewed within {time}. You\'ll receive an email as soon as it\'s approved.'**
  String almostDone(String time);

  /// No description provided for @uploadLicenseRequired.
  ///
  /// In en, this message translates to:
  /// **'Please upload your business license (PDF, PNG or JPG)'**
  String get uploadLicenseRequired;

  /// No description provided for @submitApplication.
  ///
  /// In en, this message translates to:
  /// **'Submit Application'**
  String get submitApplication;

  /// No description provided for @labelColon.
  ///
  /// In en, this message translates to:
  /// **'{label}:'**
  String labelColon(String label);

  /// No description provided for @applicationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Application Submitted!'**
  String get applicationSubmitted;

  /// No description provided for @applicationSubmittedBody.
  ///
  /// In en, this message translates to:
  /// **'Thank you for registering, {garageName}! Your application is now under review. Once approved by our admin team, your garage will appear on the driver\'s map and you can start receiving service requests.'**
  String applicationSubmittedBody(String garageName);

  /// No description provided for @expectedApproval.
  ///
  /// In en, this message translates to:
  /// **'Expected approval time: {time}. You\'ll receive an email as a notification once your account is approved.'**
  String expectedApproval(String time);

  /// No description provided for @expectedApprovalTime.
  ///
  /// In en, this message translates to:
  /// **'24-48 hours'**
  String get expectedApprovalTime;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got It'**
  String get gotIt;

  /// No description provided for @searchAddress.
  ///
  /// In en, this message translates to:
  /// **'Search address or enter manually'**
  String get searchAddress;

  /// No description provided for @mapPreview.
  ///
  /// In en, this message translates to:
  /// **'Map Preview'**
  String get mapPreview;

  /// No description provided for @mapTapToSet.
  ///
  /// In en, this message translates to:
  /// **'Tap to open map'**
  String get mapTapToSet;

  /// No description provided for @uploadDocument.
  ///
  /// In en, this message translates to:
  /// **'Upload Document'**
  String get uploadDocument;

  /// No description provided for @supportedDocumentFormats.
  ///
  /// In en, this message translates to:
  /// **'PDF, PNG or JPG (Max 5MB)'**
  String get supportedDocumentFormats;

  /// No description provided for @locationOff.
  ///
  /// In en, this message translates to:
  /// **'Location services are turned off. Turn on device location to use your current position.'**
  String get locationOff;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied. Enable it in app settings to use your current position.'**
  String get locationDenied;

  /// No description provided for @locationPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is permanently denied. Open app settings to allow location access.'**
  String get locationPermanentlyDenied;

  /// No description provided for @mapLoadingAddress.
  ///
  /// In en, this message translates to:
  /// **'Loading address...'**
  String get mapLoadingAddress;

  /// No description provided for @mapAddressUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Address could not be loaded'**
  String get mapAddressUnavailable;

  /// No description provided for @mapConfirmLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Use this location?'**
  String get mapConfirmLocationTitle;

  /// No description provided for @mapDriverVisibility.
  ///
  /// In en, this message translates to:
  /// **'Drivers will see your garage at this address.'**
  String get mapDriverVisibility;

  /// No description provided for @mapSetCarefully.
  ///
  /// In en, this message translates to:
  /// **'Please set the pin carefully.'**
  String get mapSetCarefully;

  /// No description provided for @mapChangeLocation.
  ///
  /// In en, this message translates to:
  /// **'Change location'**
  String get mapChangeLocation;

  /// No description provided for @mapConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get mapConfirm;

  /// No description provided for @mapSelectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select location'**
  String get mapSelectLocation;

  /// No description provided for @mapDragOrTap.
  ///
  /// In en, this message translates to:
  /// **'Drag the marker or tap on the map to set your garage location.'**
  String get mapDragOrTap;

  /// No description provided for @customServices.
  ///
  /// In en, this message translates to:
  /// **'Custom services'**
  String get customServices;

  /// No description provided for @addCustomService.
  ///
  /// In en, this message translates to:
  /// **'Add custom service'**
  String get addCustomService;

  /// No description provided for @customServiceHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Bodywork, Detailing'**
  String get customServiceHint;

  /// No description provided for @serviceOilChange.
  ///
  /// In en, this message translates to:
  /// **'Oil Change'**
  String get serviceOilChange;

  /// No description provided for @serviceTireService.
  ///
  /// In en, this message translates to:
  /// **'Tire Service'**
  String get serviceTireService;

  /// No description provided for @serviceBrakeRepair.
  ///
  /// In en, this message translates to:
  /// **'Brake Repair'**
  String get serviceBrakeRepair;

  /// No description provided for @serviceEngineDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Engine Diagnostics'**
  String get serviceEngineDiagnostics;

  /// No description provided for @serviceBatteryService.
  ///
  /// In en, this message translates to:
  /// **'Battery Service'**
  String get serviceBatteryService;

  /// No description provided for @serviceAcRepair.
  ///
  /// In en, this message translates to:
  /// **'AC Repair'**
  String get serviceAcRepair;

  /// No description provided for @serviceOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get serviceOther;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Manage Appointment Requests'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Review incoming bookings, approve or reject requests, and keep your schedule organized.'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Set Services and Availability'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Update your offered services and working slots so customers can book at the right time.'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Stay Updated with Notifications'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Get real-time alerts for new requests, status changes, and important garage updates.'**
  String get onboardingSubtitle3;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navAppointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get navAppointments;

  /// No description provided for @navServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get navServices;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending approval'**
  String get statusPendingApproval;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get statusBlocked;

  /// No description provided for @statusWarned.
  ///
  /// In en, this message translates to:
  /// **'Warned'**
  String get statusWarned;

  /// No description provided for @statsTodayAppointments.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Appointments'**
  String get statsTodayAppointments;

  /// No description provided for @statsPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending Requests'**
  String get statsPendingRequests;

  /// No description provided for @statsInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statsInProgress;

  /// No description provided for @statsCompletedToday.
  ///
  /// In en, this message translates to:
  /// **'Completed Today'**
  String get statsCompletedToday;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @viewAppointmentRequests.
  ///
  /// In en, this message translates to:
  /// **'View Appointment Requests ({count})'**
  String viewAppointmentRequests(int count);

  /// No description provided for @updateAvailability.
  ///
  /// In en, this message translates to:
  /// **'Update Availability'**
  String get updateAvailability;

  /// No description provided for @upcomingAppointments.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Appointments'**
  String get upcomingAppointments;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noUpcomingAppointments.
  ///
  /// In en, this message translates to:
  /// **'No upcoming appointments'**
  String get noUpcomingAppointments;

  /// No description provided for @appointmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointmentsTitle;

  /// No description provided for @appointmentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your service appointments'**
  String get appointmentsSubtitle;

  /// No description provided for @searchAppointmentsHint.
  ///
  /// In en, this message translates to:
  /// **'Search by vehicle, plate number or driver name'**
  String get searchAppointmentsHint;

  /// No description provided for @noAppointmentsMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No appointments match your search'**
  String get noAppointmentsMatchSearch;

  /// No description provided for @noAppointments.
  ///
  /// In en, this message translates to:
  /// **'No appointments'**
  String get noAppointments;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterChipCount.
  ///
  /// In en, this message translates to:
  /// **'{label} ({count})'**
  String filterChipCount(String label, int count);

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusApprovedAppt.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApprovedAppt;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @profileAndSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileAndSettings;

  /// No description provided for @manageGarageInfo.
  ///
  /// In en, this message translates to:
  /// **'Manage your garage information'**
  String get manageGarageInfo;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @ratingReviews.
  ///
  /// In en, this message translates to:
  /// **'{rating} ({count, plural, =1{1 review} other{{count} reviews}})'**
  String ratingReviews(String rating, int count);

  /// No description provided for @viewAllReviews.
  ///
  /// In en, this message translates to:
  /// **'View all reviews'**
  String get viewAllReviews;

  /// No description provided for @tapEditAddress.
  ///
  /// In en, this message translates to:
  /// **'Tap edit to set address'**
  String get tapEditAddress;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @noAvailabilitySet.
  ///
  /// In en, this message translates to:
  /// **'No availability set'**
  String get noAvailabilitySet;

  /// No description provided for @openOneDayWeek.
  ///
  /// In en, this message translates to:
  /// **'Open 1 day a week'**
  String get openOneDayWeek;

  /// No description provided for @openDaysWeek.
  ///
  /// In en, this message translates to:
  /// **'Open {count} days a week'**
  String openDaysWeek(int count);

  /// No description provided for @onsiteService.
  ///
  /// In en, this message translates to:
  /// **'Onsite Service'**
  String get onsiteService;

  /// No description provided for @onsiteServiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Offer services at customer location'**
  String get onsiteServiceSubtitle;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive appointment alerts'**
  String get notificationsSubtitle;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update account password'**
  String get changePasswordSubtitle;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @fillAllPasswordFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all password fields.'**
  String get fillAllPasswordFields;

  /// No description provided for @passwordMin6.
  ///
  /// In en, this message translates to:
  /// **'New password must be at least 6 characters.'**
  String get passwordMin6;

  /// No description provided for @passwordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match.'**
  String get passwordsMismatch;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get passwordChangedSuccess;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @garageInformation.
  ///
  /// In en, this message translates to:
  /// **'Garage information'**
  String get garageInformation;

  /// No description provided for @garageNameHint.
  ///
  /// In en, this message translates to:
  /// **'AutoCare Garage'**
  String get garageNameHint;

  /// No description provided for @emailHintGarage.
  ///
  /// In en, this message translates to:
  /// **'contact@garage.com'**
  String get emailHintGarage;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @garageAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Garage address'**
  String get garageAddressHint;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @setAvailability.
  ///
  /// In en, this message translates to:
  /// **'Set Availability'**
  String get setAvailability;

  /// No description provided for @configureWorkingHours.
  ///
  /// In en, this message translates to:
  /// **'Configure your working hours.'**
  String get configureWorkingHours;

  /// No description provided for @timeSlot.
  ///
  /// In en, this message translates to:
  /// **'Time Slot {number}'**
  String timeSlot(int number);

  /// No description provided for @removeTimeSlot.
  ///
  /// In en, this message translates to:
  /// **'Remove time slot'**
  String get removeTimeSlot;

  /// No description provided for @opening.
  ///
  /// In en, this message translates to:
  /// **'Opening'**
  String get opening;

  /// No description provided for @closing.
  ///
  /// In en, this message translates to:
  /// **'Closing'**
  String get closing;

  /// No description provided for @addTimeSlot.
  ///
  /// In en, this message translates to:
  /// **'Add Time Slot'**
  String get addTimeSlot;

  /// No description provided for @dayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get dayFriday;

  /// No description provided for @daySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get daySunday;

  /// No description provided for @editServices.
  ///
  /// In en, this message translates to:
  /// **'Edit Services'**
  String get editServices;

  /// No description provided for @servicesYouProvide.
  ///
  /// In en, this message translates to:
  /// **'Services You Provide'**
  String get servicesYouProvide;

  /// No description provided for @servicesYouProvideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select and manage the services your garage offers.'**
  String get servicesYouProvideSubtitle;

  /// No description provided for @servicesSaved.
  ///
  /// In en, this message translates to:
  /// **'Services saved'**
  String get servicesSaved;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @unreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String unreadCount(int count);

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @newAppointmentRequest.
  ///
  /// In en, this message translates to:
  /// **'New appointment request'**
  String get newAppointmentRequest;

  /// No description provided for @newAppointmentRequestBody.
  ///
  /// In en, this message translates to:
  /// **'A driver requested an appointment for {date}.'**
  String newAppointmentRequestBody(String date);

  /// No description provided for @newAppointmentRequestBodyGeneric.
  ///
  /// In en, this message translates to:
  /// **'A driver requested a new appointment. Open Appointments to review it.'**
  String get newAppointmentRequestBodyGeneric;

  /// No description provided for @reviewsAndRatings.
  ///
  /// In en, this message translates to:
  /// **'Reviews & Ratings'**
  String get reviewsAndRatings;

  /// No description provided for @noWrittenReview.
  ///
  /// In en, this message translates to:
  /// **'No written review provided.'**
  String get noWrittenReview;

  /// No description provided for @noComment.
  ///
  /// In en, this message translates to:
  /// **'No comment'**
  String get noComment;

  /// No description provided for @reviewedOn.
  ///
  /// In en, this message translates to:
  /// **'Reviewed: {date}'**
  String reviewedOn(String date);

  /// No description provided for @appointmentOn.
  ///
  /// In en, this message translates to:
  /// **'Appointment: {date}'**
  String appointmentOn(String date);

  /// No description provided for @unknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get unknownDate;

  /// No description provided for @reviewCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 review} other{{count} reviews}}'**
  String reviewCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['am', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
