import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// Days without smoking counter
  ///
  /// In en, this message translates to:
  /// **'{days} days without smoking'**
  String homeDaysWithoutSmoking(int days);

  /// Greeting with user name
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}! 👋'**
  String homeGreeting(String name);

  /// Health recovery section title
  ///
  /// In en, this message translates to:
  /// **'Health Recovery'**
  String get homeHealthRecovery;

  /// Taste health indicator
  ///
  /// In en, this message translates to:
  /// **'Taste'**
  String get homeTaste;

  /// Smell health indicator
  ///
  /// In en, this message translates to:
  /// **'Smell'**
  String get homeSmell;

  /// Circulation health indicator
  ///
  /// In en, this message translates to:
  /// **'Circulation'**
  String get homeCirculation;

  /// Lungs health indicator
  ///
  /// In en, this message translates to:
  /// **'Lungs'**
  String get homeLungs;

  /// Heart health indicator
  ///
  /// In en, this message translates to:
  /// **'Heart'**
  String get homeHeart;

  /// Minutes of life gained label
  ///
  /// In en, this message translates to:
  /// **'minutes of life\ngained'**
  String get homeMinutesLifeGained;

  /// Lung capacity label
  ///
  /// In en, this message translates to:
  /// **'lung\ncapacity'**
  String get homeLungCapacity;

  /// Next milestone title
  ///
  /// In en, this message translates to:
  /// **'Next Milestone'**
  String get homeNextMilestone;

  /// Next milestone description
  ///
  /// In en, this message translates to:
  /// **'In {days} days: Blood flow improves'**
  String homeNextMilestoneDescription(int days);

  /// Recent achievements section title
  ///
  /// In en, this message translates to:
  /// **'Recent Achievements'**
  String get homeRecentAchievements;

  /// See all button
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// First day achievement title
  ///
  /// In en, this message translates to:
  /// **'First Day'**
  String get homeFirstDay;

  /// First day achievement description
  ///
  /// In en, this message translates to:
  /// **'You\'ve gone 24 hours without smoking!'**
  String get homeFirstDayDescription;

  /// Overcoming achievement title
  ///
  /// In en, this message translates to:
  /// **'Overcoming'**
  String get homeOvercoming;

  /// Overcoming achievement description
  ///
  /// In en, this message translates to:
  /// **'Nicotine levels eliminated from body'**
  String get homeOvercomingDescription;

  /// Persistence achievement title
  ///
  /// In en, this message translates to:
  /// **'Persistence'**
  String get homePersistence;

  /// Persistence achievement description
  ///
  /// In en, this message translates to:
  /// **'A whole week without cigarettes!'**
  String get homePersistenceDescription;

  /// Today's statistics section title
  ///
  /// In en, this message translates to:
  /// **'Today\'s Statistics'**
  String get homeTodayStats;

  /// Cravings resisted label
  ///
  /// In en, this message translates to:
  /// **'Cravings\nResisted'**
  String get homeCravingsResisted;

  /// Minutes gained today label
  ///
  /// In en, this message translates to:
  /// **'Minutes of Life\nGained Today'**
  String get homeMinutesGainedToday;

  /// All achievements category
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get achievementCategoryAll;

  /// Health achievements category
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get achievementCategoryHealth;

  /// Time achievements category
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get achievementCategoryTime;

  /// Savings achievements category
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get achievementCategorySavings;

  /// Habits achievements category
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get achievementCategoryHabits;

  /// Unlocked achievements label
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get achievementUnlocked;

  /// In progress achievements label
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get achievementInProgress;

  /// Completed achievements percentage
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get achievementCompleted;

  /// Current progress section title
  ///
  /// In en, this message translates to:
  /// **'Your Current Progress'**
  String get achievementCurrentProgress;

  /// Achievement level
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String achievementLevel(int level);

  /// Days without smoking on achievements screen
  ///
  /// In en, this message translates to:
  /// **'{days} days without smoking'**
  String achievementDaysWithoutSmoking(int days);

  /// Next achievement level
  ///
  /// In en, this message translates to:
  /// **'Next level: {time}'**
  String achievementNextLevel(String time);

  /// CO2 benefit label
  ///
  /// In en, this message translates to:
  /// **'Normal CO2'**
  String get achievementBenefitCO2;

  /// Taste benefit label
  ///
  /// In en, this message translates to:
  /// **'Improved Taste'**
  String get achievementBenefitTaste;

  /// Circulation benefit label
  ///
  /// In en, this message translates to:
  /// **'Circulation +15%'**
  String get achievementBenefitCirculation;

  /// First day achievement
  ///
  /// In en, this message translates to:
  /// **'First Day'**
  String get achievementFirstDay;

  /// First day achievement description
  ///
  /// In en, this message translates to:
  /// **'Complete 24 hours without smoking'**
  String get achievementFirstDayDescription;

  /// One week achievement
  ///
  /// In en, this message translates to:
  /// **'One Week'**
  String get achievementOneWeek;

  /// One week achievement description
  ///
  /// In en, this message translates to:
  /// **'One week without smoking!'**
  String get achievementOneWeekDescription;

  /// Improved circulation achievement
  ///
  /// In en, this message translates to:
  /// **'Improved Circulation'**
  String get achievementImprovedCirculation;

  /// Improved circulation achievement description
  ///
  /// In en, this message translates to:
  /// **'Oxygen levels normalized'**
  String get achievementImprovedCirculationDescription;

  /// Initial savings achievement
  ///
  /// In en, this message translates to:
  /// **'Initial Savings'**
  String get achievementInitialSavings;

  /// Initial savings achievement description
  ///
  /// In en, this message translates to:
  /// **'Save the equivalent of 1 pack of cigarettes'**
  String get achievementInitialSavingsDescription;

  /// Two weeks achievement
  ///
  /// In en, this message translates to:
  /// **'Two Weeks'**
  String get achievementTwoWeeks;

  /// Two weeks achievement description
  ///
  /// In en, this message translates to:
  /// **'Two complete weeks without smoking!'**
  String get achievementTwoWeeksDescription;

  /// Substantial savings achievement
  ///
  /// In en, this message translates to:
  /// **'Substantial Savings'**
  String get achievementSubstantialSavings;

  /// Substantial savings achievement description
  ///
  /// In en, this message translates to:
  /// **'Save the equivalent of 10 packs of cigarettes'**
  String get achievementSubstantialSavingsDescription;

  /// Clean breathing achievement
  ///
  /// In en, this message translates to:
  /// **'Clean Breathing'**
  String get achievementCleanBreathing;

  /// Clean breathing achievement description
  ///
  /// In en, this message translates to:
  /// **'Lung capacity increased by 30%'**
  String get achievementCleanBreathingDescription;

  /// One month achievement
  ///
  /// In en, this message translates to:
  /// **'One Month'**
  String get achievementOneMonth;

  /// One month achievement description
  ///
  /// In en, this message translates to:
  /// **'A whole month without smoking!'**
  String get achievementOneMonthDescription;

  /// New exercise habit achievement
  ///
  /// In en, this message translates to:
  /// **'New Habit: Exercise'**
  String get achievementNewHabitExercise;

  /// New exercise habit achievement description
  ///
  /// In en, this message translates to:
  /// **'Record 5 days of exercise'**
  String get achievementNewHabitExerciseDescription;

  /// Percentage completed
  ///
  /// In en, this message translates to:
  /// **'{percent}% completed'**
  String percentCompleted(int percent);

  /// Name of the application
  ///
  /// In en, this message translates to:
  /// **'NicotinaAI'**
  String get appName;

  /// Login screen title
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Log in to continue'**
  String get loginToContinue;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Example text for email field
  ///
  /// In en, this message translates to:
  /// **'example@email.com'**
  String get emailHint;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Remember user option
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// Link for password recovery
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPassword;

  /// Login button
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Text for users without account
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// Link for account registration
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Error message when email is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// Error message when email is invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get emailInvalid;

  /// Error message when password is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Home screen title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Achievements screen title
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// User profile section title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Button to edit profile
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// App settings section title
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// Item to manage notifications
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Description of notifications item
  ///
  /// In en, this message translates to:
  /// **'Manage notifications'**
  String get manageNotifications;

  /// Item to change language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Description of language item
  ///
  /// In en, this message translates to:
  /// **'Change the language of the app'**
  String get changeLanguage;

  /// Item to change theme
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// Habit tracking section title
  ///
  /// In en, this message translates to:
  /// **'Habit Tracking'**
  String get habitTracking;

  /// Item to configure cigarettes per day
  ///
  /// In en, this message translates to:
  /// **'Cigarettes per day before quitting'**
  String get cigarettesPerDay;

  /// Description of cigarettes per day item
  ///
  /// In en, this message translates to:
  /// **'Configure your previous habits'**
  String get configureHabits;

  /// Item to configure pack price
  ///
  /// In en, this message translates to:
  /// **'Pack price'**
  String get packPrice;

  /// Description of pack price item
  ///
  /// In en, this message translates to:
  /// **'Set the price for savings calculations'**
  String get setPriceForCalculations;

  /// Item to configure start date
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// Description of start date item
  ///
  /// In en, this message translates to:
  /// **'When you quit smoking'**
  String get whenYouQuitSmoking;

  /// Account section title
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Item to reset password
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// Description of reset password item
  ///
  /// In en, this message translates to:
  /// **'Change your access password'**
  String get changePassword;

  /// Item to delete account
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// Description of delete account item
  ///
  /// In en, this message translates to:
  /// **'Permanently remove your account'**
  String get permanentlyRemoveAccount;

  /// Title of delete account dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// Delete account confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action is irreversible and all your data will be lost.'**
  String get deleteAccountConfirmation;

  /// Item to logout
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Description of logout item
  ///
  /// In en, this message translates to:
  /// **'Disconnect from your account'**
  String get logoutFromAccount;

  /// Title of logout dialog
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTitle;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout from your account?'**
  String get logoutConfirmation;

  /// About section title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Item for privacy policy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Description of privacy policy item
  ///
  /// In en, this message translates to:
  /// **'Read our privacy policy'**
  String get readPrivacyPolicy;

  /// Item for terms of use
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// Description of terms of use item
  ///
  /// In en, this message translates to:
  /// **'View the app\'s terms of use'**
  String get viewTermsOfUse;

  /// Item for about the app
  ///
  /// In en, this message translates to:
  /// **'About the App'**
  String get aboutApp;

  /// Description of about the app item
  ///
  /// In en, this message translates to:
  /// **'Version and app information'**
  String get appInfo;

  /// App version
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Finish button
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// Question about number of cigarettes per day
  ///
  /// In en, this message translates to:
  /// **'How many cigarettes do you smoke per day?'**
  String get cigarettesPerDayQuestion;

  /// Subtitle for cigarettes per day question
  ///
  /// In en, this message translates to:
  /// **'This helps us understand your consumption level'**
  String get cigarettesPerDaySubtitle;

  /// Label for exact number of cigarettes
  ///
  /// In en, this message translates to:
  /// **'Exact number: '**
  String get exactNumber;

  /// Instruction to select consumption level
  ///
  /// In en, this message translates to:
  /// **'Or select your consumption level:'**
  String get selectConsumptionLevel;

  /// Low consumption level
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// Moderate consumption level
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// High consumption level
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// Very high consumption level
  ///
  /// In en, this message translates to:
  /// **'Very High'**
  String get veryHigh;

  /// Low consumption description
  ///
  /// In en, this message translates to:
  /// **'Up to 5 cigarettes per day'**
  String get upTo5;

  /// Moderate consumption description
  ///
  /// In en, this message translates to:
  /// **'6 to 15 cigarettes per day'**
  String get sixTo15;

  /// High consumption description
  ///
  /// In en, this message translates to:
  /// **'16 to 25 cigarettes per day'**
  String get sixteenTo25;

  /// Very high consumption description
  ///
  /// In en, this message translates to:
  /// **'More than 25 cigarettes per day'**
  String get moreThan25;

  /// Error message for consumption level selection
  ///
  /// In en, this message translates to:
  /// **'Please select your consumption level'**
  String get selectConsumptionLevelError;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
