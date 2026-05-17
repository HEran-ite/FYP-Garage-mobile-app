// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appTitle => 'CarCare';

  @override
  String get language => 'ቋንቋ';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageAmharic => 'አማርኛ';

  @override
  String get loading => 'በመጫን ላይ...';

  @override
  String get retry => 'እንደገና ሞክር';

  @override
  String get cancel => 'ይቅር';

  @override
  String get save => 'አስቀምጥ';

  @override
  String get continueButton => 'ቀጥል';

  @override
  String get back => 'ተመለስ';

  @override
  String get skip => 'ዝለል';

  @override
  String get getStarted => 'ጀምር';

  @override
  String get required => 'አስፈላጊ';

  @override
  String get settings => 'ቅንብሮች';

  @override
  String get done => 'ተጠናቀቀ';

  @override
  String get add => 'ጨምር';

  @override
  String get update => 'አዘምን';

  @override
  String get open => 'ክፍት';

  @override
  String get closed => 'ዝግ';

  @override
  String get emDash => '—';

  @override
  String get atGarage => 'በጋራዥ';

  @override
  String get driver => 'አሽከርካሪ';

  @override
  String get customer => 'ደንበኛ';

  @override
  String get garage => 'ጋራዥ';

  @override
  String get myGarage => 'የኔ ጋራዥ';

  @override
  String get justNow => 'አሁን';

  @override
  String get oneMinAgo => 'ከ1 ደቂቃ በፊት';

  @override
  String minsAgo(int count) {
    return 'ከ$count ደቂቃዎች በፊት';
  }

  @override
  String get oneHourAgo => 'ከ1 ሰዓት በፊት';

  @override
  String hoursAgo(int count) {
    return 'ከ$count ሰዓታት በፊት';
  }

  @override
  String get yesterday => 'ትላንት';

  @override
  String daysAgo(int count) {
    return 'ከ$count ቀናት በፊት';
  }

  @override
  String get monthJan => 'ጃን';

  @override
  String get monthFeb => 'ፌብ';

  @override
  String get monthMar => 'ማር';

  @override
  String get monthApr => 'ኤፕሪ';

  @override
  String get monthMay => 'ሜይ';

  @override
  String get monthJun => 'ጁን';

  @override
  String get monthJul => 'ጁላይ';

  @override
  String get monthAug => 'ኦገ';

  @override
  String get monthSep => 'ሴፕ';

  @override
  String get monthOct => 'ኦክ';

  @override
  String get monthNov => 'ኖቬ';

  @override
  String get monthDec => 'ዲሴ';

  @override
  String get am => 'ጠዋት';

  @override
  String get pm => 'ማታ';

  @override
  String get errorGeneric => 'አንድ ነገር ተሳሳተ። እባክዎ እንደገና ይሞክሩ።';

  @override
  String get errorSignInAgain => 'እባክዎ እንደገና ይግቡ።';

  @override
  String get errorInvalidCredentials =>
      'ልክ ያልሆነ ኢሜይል ወይም የይለፍ ቃል። እባክዎ እንደገና ይሞክሩ።';

  @override
  String get errorForbidden => 'ይህን ለማድረግ ፍቃድ የለዎትም።';

  @override
  String get errorNotFound => 'የተጠየቀው ነገር አልተገኘም።';

  @override
  String get errorConnection => 'የኢንተርኔት ችግር። ግንኙነትዎን ይፈትሹ እና እንደገና ይሞክሩ።';

  @override
  String get errorApiUnreachable =>
      'የጋራዥ አገልጋዩን ማግኘት አልተቻለም። API_BASE_URLን በ .env ውስጥ ያስተካክሉ (Android emulator: http://10.0.2.2:4000) እና npm run dev እንደሚሰራ ያረጋግጡ።';

  @override
  String get pleaseSignIn => 'እባክዎ ይግቡ';

  @override
  String get loginWelcome => 'እንኳን ደህና መጡ';

  @override
  String get loginWelcomeSubtitle => 'ወደ መለያዎ ለመቀጠል ይግቡ';

  @override
  String get createAccountLink => 'መለያ ይፍጠሩ';

  @override
  String get email => 'ኢሜይል';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get emailRequired => 'ኢሜይል ያስፈልጋል';

  @override
  String get password => 'የይለፍ ቃል';

  @override
  String get passwordRequired => 'የይለፍ ቃል ያስፈልጋል';

  @override
  String get passwordPlaceholder => 'የይለፍ ቃልዎን ያስገቡ';

  @override
  String get confirmPasswordPlaceholder => 'የይለፍ ቃልዎን ያረጋግጡ';

  @override
  String get signIn => 'ግባ';

  @override
  String get noAccount => 'መለያ የለዎትም? ';

  @override
  String get alreadyHaveAccount => 'መለያ አለዎት? ';

  @override
  String get signInLink => 'ግባ';

  @override
  String get signUp => 'ይመዝገቡ';

  @override
  String get createAccount => 'መለያ ፍጠር';

  @override
  String registrationStep(int current, int total) {
    return 'ደረጃ $current ከ $total';
  }

  @override
  String get basicInformation => 'መሰረታዊ መረጃ';

  @override
  String get tellUsAboutGarage => 'ስለ ጋራዥዎ ይንገሩን';

  @override
  String get garageName => 'የጋራዥ ስም';

  @override
  String get garageNameRequired => 'የጋራዥ ስም ያስፈልጋል';

  @override
  String get phoneNumber => 'ስልክ ቁጥር';

  @override
  String get phonePlaceholder => '+251 9XX XXX XXX, 2519…, ወይም 09XXXXXXXX';

  @override
  String get phoneFormatHint =>
      '+251 9XX XXX XXX (13 ቁጥሮች), 2519XXXXXXXX (12 ቁጥሮች), ወይም 09XXXXXXXX (10 ቁጥሮች) ይጠቀሙ።';

  @override
  String get emailAddress => 'ኢሜይል አድራሻ';

  @override
  String get sendOtp => 'OTP ላክ';

  @override
  String get resendOtp => 'OTP እንደገና ላክ';

  @override
  String get emailOtp => 'የኢሜይል OTP';

  @override
  String get otpHint => '6-አሃዝ ኮድ ያስገቡ';

  @override
  String get otpMustBe6Digits => 'OTP 6 አሃዞች መሆን አለበት';

  @override
  String get verifyOtp => 'OTP አረጋግጥ';

  @override
  String get emailVerified => 'ኢሜይል ተረጋገጠ';

  @override
  String otpExpiresIn(int minutes) {
    return 'OTP በ $minutes ደቂቃዎች ውስጥ ያበቃል';
  }

  @override
  String get confirmPassword => 'የይለፍ ቃል አረጋግጥ';

  @override
  String passwordMinLength(int length) {
    return 'ቢያንስ $length ቁምፊዎች';
  }

  @override
  String get passwordsDoNotMatch => 'የይለፍ ቃሎች አይዛመዱም';

  @override
  String get verifyOtpFirst => 'መጀመሪያ የኢሜይል OTPዎን ያረጋግጡ። OTP ለምዝገባ ብቻ ያስፈልጋል።';

  @override
  String get verifyOtpBeforeContinue => 'እባክዎ ከመቀጠልዎ በፊት የኢሜይል OTPዎን ያረጋግጡ።';

  @override
  String get locationAndServices => 'ቦታ እና አገልግሎቶች';

  @override
  String get locationServicesSubtitle => 'የት ነው የሚገኙት እና ምን ይሰጣሉ?';

  @override
  String get garageAddress => 'የጋራዥ አድራሻ';

  @override
  String get mapSetExactLocationHint => 'ለመቀጠል ትክክለኛውን ቦታ በካርታ ላይ ያስቀምጡ';

  @override
  String get servicesOffered => 'የሚሰጡ አገልግሎቶች';

  @override
  String selectedCount(int count) {
    return '$count ተመርጧል';
  }

  @override
  String get addressRequired => 'አድራሻ ያስፈልጋል';

  @override
  String get locationRequired => 'እባክዎ ትክክለኛውን ቦታ በካርታ ላይ ያስቀምጡ';

  @override
  String get verification => 'ማረጋገጫ';

  @override
  String get uploadBusinessDocuments => 'የንግድ ሰነዶችዎን ይስቀሉ';

  @override
  String get businessLicense => 'የንግድ ፈቃድ';

  @override
  String filePickerError(String error) {
    return 'ፋይል መምረጥ አልተቻለም። $error';
  }

  @override
  String get reviewYourInformation => 'መረጃዎን ይገምግሙ';

  @override
  String get phone => 'ስልክ';

  @override
  String get services => 'አገልግሎቶች';

  @override
  String almostDone(String time) {
    return 'በቅርቡ ይጠናቃል! ማመልከቻዎ በ $time ውስጥ ይገመገማል። እንደተጸድቀ በኢሜይል ይደርስዎታል።';
  }

  @override
  String get uploadLicenseRequired => 'እባክዎ የንግድ ፈቃድዎን ይስቀሉ (PDF, PNG ወይም JPG)';

  @override
  String get submitApplication => 'ማመልከቻ አስገባ';

  @override
  String labelColon(String label) {
    return '$label:';
  }

  @override
  String get applicationSubmitted => 'ማመልከቻ ተላከ!';

  @override
  String applicationSubmittedBody(String garageName) {
    return 'ስለመመዝገብዎ እናመሰግናለን, $garageName! ማመልከቻዎ በግምገማ ላይ ነው። ከአስተዳዳሪ ቡድናችን ከተጸድቀ በኋላ ጋራዥዎ በአሽከርካሪዎች ካርታ ላይ ይታያል እና የአገልግሎት ጥያቄዎችን መቀበል ይችላሉ።';
  }

  @override
  String expectedApproval(String time) {
    return 'የሚጠበቀው የማጽደቅ ጊዜ: $time። መለያዎ ከተጸድቀ በኋላ በኢሜይል ማሳወቂያ ይደርስዎታል።';
  }

  @override
  String get expectedApprovalTime => '24-48 ሰዓታት';

  @override
  String get gotIt => 'ተረድቻለሁ';

  @override
  String get searchAddress => 'አድራሻ ይፈልጉ ወይም በእጅ ያስገቡ';

  @override
  String get mapPreview => 'የካርታ ቅድመ እይታ';

  @override
  String get mapTapToSet => 'ካርታ ለመክፈት ይንኩ';

  @override
  String get uploadDocument => 'ሰነድ ይስቀሉ';

  @override
  String get supportedDocumentFormats => 'PDF, PNG ወይም JPG (ከፍተኛ 5MB)';

  @override
  String get locationOff => 'የቦታ አገልግሎቶች ጠፍተዋል። የአሁኑን ቦታዎን ለመጠቀም ቦታን ያብሩ።';

  @override
  String get locationDenied =>
      'የቦታ ፍቃድ ተከልክሏል። የአሁኑን ቦታዎን ለመጠቀም በመተግበሪያ ቅንብሮች ውስጥ ያንቁ።';

  @override
  String get locationPermanentlyDenied =>
      'የቦታ ፍቃድ ለዘላለም ተከልክሏል። ቦታ መዳረሻ ለመፍቀድ የመተግበሪያ ቅንብሮችን ይክፈቱ።';

  @override
  String get mapLoadingAddress => 'አድራሻ በመጫን ላይ...';

  @override
  String get mapAddressUnavailable => 'አድራሻ ሊጫን አልተቻለም';

  @override
  String get mapConfirmLocationTitle => 'ይህን ቦታ ይጠቀሙ?';

  @override
  String get mapDriverVisibility => 'አሽከርካሪዎች ጋራዥዎን በዚህ አድራሻ ያያሉ።';

  @override
  String get mapSetCarefully => 'እባክዎ ፒኑን በጥንቃቄ ያስቀምጡ።';

  @override
  String get mapChangeLocation => 'ቦታ ቀይር';

  @override
  String get mapConfirm => 'አረጋግጥ';

  @override
  String get mapSelectLocation => 'ቦታ ይምረጡ';

  @override
  String get mapDragOrTap => 'የጋራዥ ቦታዎን ለማስቀመጥ ምልክቱን ይጎትቱ ወይም በካርታ ላይ ይንኩ።';

  @override
  String get customServices => 'ብጁ አገልግሎቶች';

  @override
  String get addCustomService => 'ብጁ አገልግሎት ጨምር';

  @override
  String get customServiceHint => 'ለምሳሌ: የሰውነት ሥራ, ማጽዳት';

  @override
  String get serviceOilChange => 'የዘይት ለውጥ';

  @override
  String get serviceTireService => 'የጎማ አገልግሎት';

  @override
  String get serviceBrakeRepair => 'የብሬክ ጥገና';

  @override
  String get serviceEngineDiagnostics => 'የሞተር ምርመራ';

  @override
  String get serviceBatteryService => 'የባትሪ አገልግሎት';

  @override
  String get serviceAcRepair => 'የኤሲ ጥገና';

  @override
  String get serviceOther => 'ሌላ';

  @override
  String get onboardingTitle1 => 'የቀጠሮ ጥያቄዎችን ያስተዳድሩ';

  @override
  String get onboardingSubtitle1 =>
      'የሚመጡ ቦታ ማስያዣዎችን ይገምግሙ፣ ጥያቄዎችን ያጽድቁ ወይም ውድቅ ያድርጉ፣ እና መርሃግብርዎን ያዘጋጁ።';

  @override
  String get onboardingTitle2 => 'አገልግሎቶችን እና ተገኝነትን ያስተካክሉ';

  @override
  String get onboardingSubtitle2 =>
      'ደንበኞች በትክክለኛው ጊዜ እንዲያስይዙ የሚሰጡ አገልግሎቶችን እና የስራ ሰዓቶችን ያዘምኑ።';

  @override
  String get onboardingTitle3 => 'በማሳወቂያዎች ይዘመኑ';

  @override
  String get onboardingSubtitle3 =>
      'ለአዲስ ጥያቄዎች፣ ለሁኔታ ለውጦች እና ለአስፈላጊ የጋራዥ ዝመናዎች በቅጽበት ማሳወቂያዎችን ይቀበሉ።';

  @override
  String get navDashboard => 'ዳሽቦርድ';

  @override
  String get navAppointments => 'ቀጠሮዎች';

  @override
  String get navServices => 'አገልግሎቶች';

  @override
  String get navProfile => 'መገለጫ';

  @override
  String get dashboard => 'ዳሽቦርድ';

  @override
  String get statusApproved => 'ተጸድቋል';

  @override
  String get statusPendingApproval => 'ማጽደቅ በመጠባበቅ ላይ';

  @override
  String get statusRejected => 'ተቀባይነት አላገኘም';

  @override
  String get statusBlocked => 'ተከልክሏል';

  @override
  String get statusWarned => 'ማስጠንቀቂያ ተሰጠ';

  @override
  String get statsTodayAppointments => 'የዛሬ ቀጠሮዎች';

  @override
  String get statsPendingRequests => 'በመጠባበቅ ላይ ያሉ ጥያቄዎች';

  @override
  String get statsInProgress => 'በሂደት ላይ';

  @override
  String get statsCompletedToday => 'ዛሬ የተጠናቀቁ';

  @override
  String get quickActions => 'ፈጣን እርምጃዎች';

  @override
  String viewAppointmentRequests(int count) {
    return 'የቀጠሮ ጥያቄዎችን ይመልከቱ ($count)';
  }

  @override
  String get updateAvailability => 'ተገኝነት አዘምን';

  @override
  String get upcomingAppointments => 'የሚመጡ ቀጠሮዎች';

  @override
  String get viewAll => 'ሁሉንም ይመልከቱ';

  @override
  String get noUpcomingAppointments => 'የሚመጡ ቀጠሮዎች የሉም';

  @override
  String get appointmentsTitle => 'ቀጠሮዎች';

  @override
  String get appointmentsSubtitle => 'የአገልግሎት ቀጠሮዎችዎን ያስተዳድሩ';

  @override
  String get searchAppointmentsHint => 'በተሽከርካሪ፣ በታርጋ ቁጥር ወይም በአሽከርካሪ ስም ይፈልጉ';

  @override
  String get noAppointmentsMatchSearch => 'ከፍለጋዎ ጋር የሚዛመዱ ቀጠሮዎች የሉም';

  @override
  String get noAppointments => 'ቀጠሮዎች የሉም';

  @override
  String get filterAll => 'ሁሉ';

  @override
  String filterChipCount(String label, int count) {
    return '$label ($count)';
  }

  @override
  String get statusPending => 'በመጠባበቅ ላይ';

  @override
  String get statusApprovedAppt => 'ተጸድቋል';

  @override
  String get statusInProgress => 'በሂደት ላይ';

  @override
  String get statusCompleted => 'ተጠናቋል';

  @override
  String get statusCancelled => 'ተሰርዟል';

  @override
  String get profileAndSettings => 'መገለጫ እና ቅንብሮች';

  @override
  String get manageGarageInfo => 'የጋራዥ መረጃዎን ያስተዳድሩ';

  @override
  String get noReviewsYet => 'ግምገማዎች የሉም';

  @override
  String ratingReviews(String rating, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ግምገማዎች',
      one: '1 ግምገማ',
    );
    return '$rating ($_temp0)';
  }

  @override
  String get viewAllReviews => 'ሁሉንም ግምገማዎች ይመልከቱ';

  @override
  String get tapEditAddress => 'አድራሻ ለማስተካከል ያርትዑን ይንኩ';

  @override
  String get availability => 'ተገኝነት';

  @override
  String get noAvailabilitySet => 'ተገኝነት አልተቀመጠም';

  @override
  String get openOneDayWeek => 'በሳምንት 1 ቀን ክፍት';

  @override
  String openDaysWeek(int count) {
    return 'በሳምንት $count ቀናት ክፍት';
  }

  @override
  String get onsiteService => 'በደንበኛ ቦታ አገልግሎት';

  @override
  String get onsiteServiceSubtitle => 'በደንበኛ ቦታ አገልግሎት ይስጡ';

  @override
  String get notifications => 'ማሳወቂያዎች';

  @override
  String get notificationsSubtitle => 'የቀጠሮ ማሳወቂያዎችን ይቀበሉ';

  @override
  String get changePassword => 'የይለፍ ቃል ቀይር';

  @override
  String get changePasswordSubtitle => 'የመለያ የይለፍ ቃል አዘምን';

  @override
  String get logout => 'ውጣ';

  @override
  String get currentPassword => 'የአሁኑ የይለፍ ቃል';

  @override
  String get newPassword => 'አዲስ የይለፍ ቃል';

  @override
  String get confirmNewPassword => 'አዲሱን የይለፍ ቃል አረጋግጥ';

  @override
  String get fillAllPasswordFields => 'እባክዎ ሁሉንም የይለፍ ቃል መስኮች ይሙሉ።';

  @override
  String get passwordMin6 => 'አዲሱ የይለፍ ቃል ቢያንስ 6 ቁምፊዎች መሆን አለበት።';

  @override
  String get passwordsMismatch => 'አዲሶቹ የይለፍ ቃሎች አይዛመዱም።';

  @override
  String get passwordChangedSuccess => 'የይለፍ ቃል በተሳካ ሁኔታ ተቀይሯል።';

  @override
  String get editProfile => 'መገለጫ አርትዕ';

  @override
  String get garageInformation => 'የጋራዥ መረጃ';

  @override
  String get garageNameHint => 'AutoCare Garage';

  @override
  String get emailHintGarage => 'contact@garage.com';

  @override
  String get location => 'ቦታ';

  @override
  String get garageAddressHint => 'የጋራዥ አድራሻ';

  @override
  String get profileSaved => 'መገለጫ ተቀምጧል';

  @override
  String get setAvailability => 'ተገኝነት አስተካክል';

  @override
  String get configureWorkingHours => 'የስራ ሰዓቶችዎን ያዘጋጁ።';

  @override
  String timeSlot(int number) {
    return 'የጊዜ ክፍተት $number';
  }

  @override
  String get removeTimeSlot => 'የጊዜ ክፍተት አስወግድ';

  @override
  String get opening => 'መክፈቻ';

  @override
  String get closing => 'መዝጊያ';

  @override
  String get addTimeSlot => 'የጊዜ ክፍተት ጨምር';

  @override
  String get dayMonday => 'ሰኞ';

  @override
  String get dayTuesday => 'ማክሰኞ';

  @override
  String get dayWednesday => 'ረቡዕ';

  @override
  String get dayThursday => 'ሐሙስ';

  @override
  String get dayFriday => 'ዓርብ';

  @override
  String get daySaturday => 'ቅዳሜ';

  @override
  String get daySunday => 'እሁድ';

  @override
  String get editServices => 'አገልግሎቶችን አርትዕ';

  @override
  String get servicesYouProvide => 'የሚሰጡ አገልግሎቶች';

  @override
  String get servicesYouProvideSubtitle =>
      'ጋራዥዎ የሚሰጣቸውን አገልግሎቶች ይምረጡ እና ያስተዳድሩ።';

  @override
  String get servicesSaved => 'አገልግሎቶች ተቀምጠዋል';

  @override
  String get notificationsTitle => 'ማሳወቂያዎች';

  @override
  String unreadCount(int count) {
    return '$count ያልተነበቡ';
  }

  @override
  String get markAllRead => 'ሁሉንም እንደተነበቡ ምልክት አድርግ';

  @override
  String get noNotificationsYet => 'ማሳወቂያዎች የሉም';

  @override
  String get newAppointmentRequest => 'አዲስ የቀጠሮ ጥያቄ';

  @override
  String newAppointmentRequestBody(String date) {
    return 'አሽከርካሪ ለ $date ቀጠሮ ጠየቀ።';
  }

  @override
  String get newAppointmentRequestBodyGeneric =>
      'አሽከርካሪ አዲስ ቀጠሮ ጠየቀ። ለመገምገም ቀጠሮዎችን ይክፈቱ።';

  @override
  String get reviewsAndRatings => 'ግምገማዎች እና ደረጃዎች';

  @override
  String get noWrittenReview => 'የተጻፈ ግምገማ አልቀረበም።';

  @override
  String get noComment => 'አስተያየት የለም';

  @override
  String reviewedOn(String date) {
    return 'ተገምገመ: $date';
  }

  @override
  String appointmentOn(String date) {
    return 'ቀጠሮ: $date';
  }

  @override
  String get unknownDate => 'ያልታወቀ ቀን';

  @override
  String reviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ግምገማዎች',
      one: '1 ግምገማ',
    );
    return '$_temp0';
  }
}
