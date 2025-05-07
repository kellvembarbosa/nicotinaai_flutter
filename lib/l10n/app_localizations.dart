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

  /// Text representing the plural of day
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// Title for help screen
  ///
  /// In en, this message translates to:
  /// **'How can we help you?'**
  String get helpScreenTitle;

  /// Subtitle for help screen
  ///
  /// In en, this message translates to:
  /// **'Select all options that interest you'**
  String get selectAllInterests;

  /// Explanation text on help screen
  ///
  /// In en, this message translates to:
  /// **'We offer different resources to support your journey. Select all that you believe can help.'**
  String get helpScreenExplanation;

  /// Option for daily tips
  ///
  /// In en, this message translates to:
  /// **'Daily tips'**
  String get dailyTips;

  /// Description for daily tips
  ///
  /// In en, this message translates to:
  /// **'Receive practical advice every day to support your journey'**
  String get dailyTipsDescription;

  /// Option for custom reminders
  ///
  /// In en, this message translates to:
  /// **'Custom reminders'**
  String get customReminders;

  /// Description for custom reminders
  ///
  /// In en, this message translates to:
  /// **'Notifications to keep you motivated and on track'**
  String get customRemindersDescription;

  /// Option for progress monitoring
  ///
  /// In en, this message translates to:
  /// **'Progress monitoring'**
  String get progressMonitoring;

  /// Description for progress monitoring
  ///
  /// In en, this message translates to:
  /// **'Visually track your progress over time'**
  String get progressMonitoringDescription;

  /// Option for support community
  ///
  /// In en, this message translates to:
  /// **'Support community'**
  String get supportCommunity;

  /// Description for support community
  ///
  /// In en, this message translates to:
  /// **'Connect with others on a similar journey'**
  String get supportCommunityDescription;

  /// Option for cigarette alternatives
  ///
  /// In en, this message translates to:
  /// **'Cigarette alternatives'**
  String get cigaretteAlternatives;

  /// Description for cigarette alternatives
  ///
  /// In en, this message translates to:
  /// **'Suggestions for activities and products to replace the habit'**
  String get cigaretteAlternativesDescription;

  /// Option for savings calculator
  ///
  /// In en, this message translates to:
  /// **'Savings calculator'**
  String get savingsCalculator;

  /// Description for savings calculator
  ///
  /// In en, this message translates to:
  /// **'See how much money you\'re saving by reducing or quitting'**
  String get savingsCalculatorDescription;

  /// Text explaining that preferences can be modified later
  ///
  /// In en, this message translates to:
  /// **'You can modify these preferences at any time in the app settings.'**
  String get modifyPreferencesAnytime;

  /// Title for personalize screen
  ///
  /// In en, this message translates to:
  /// **'When do you usually smoke more?'**
  String get personalizeScreenTitle;

  /// Subtitle for personalize screen
  ///
  /// In en, this message translates to:
  /// **'Select the times when you feel more like smoking'**
  String get personalizeScreenSubtitle;

  /// Option for smoking after meals
  ///
  /// In en, this message translates to:
  /// **'After meals'**
  String get afterMeals;

  /// Option for smoking during work breaks
  ///
  /// In en, this message translates to:
  /// **'During work breaks'**
  String get duringWorkBreaks;

  /// Option for smoking at social events
  ///
  /// In en, this message translates to:
  /// **'At social events'**
  String get inSocialEvents;

  /// Option for smoking when stressed
  ///
  /// In en, this message translates to:
  /// **'When I\'m stressed'**
  String get whenStressed;

  /// Option for smoking with coffee or alcohol
  ///
  /// In en, this message translates to:
  /// **'When drinking coffee or alcohol'**
  String get withCoffeeOrAlcohol;

  /// Option for smoking when bored
  ///
  /// In en, this message translates to:
  /// **'When I\'m bored'**
  String get whenBored;

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

  /// Register button text
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

  /// Location option: Home
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

  /// Save button text
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

  /// Intensity level: Moderate
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

  /// Title of the introduction screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to NicotinaAI'**
  String get welcomeToNicotinaAI;

  /// Subtitle of the introduction screen
  ///
  /// In en, this message translates to:
  /// **'Your personal assistant to quit smoking'**
  String get personalAssistant;

  /// Start button text
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Main slogan on introduction screen
  ///
  /// In en, this message translates to:
  /// **'BREATHE FREEDOM. YOUR NEW LIFE STARTS NOW.'**
  String get breatheFreedom;

  /// Explanation text on introduction screen
  ///
  /// In en, this message translates to:
  /// **'Let\'s personalize your experience to help you achieve your goals of quitting smoking. Answer a few questions to get started.'**
  String get personalizeExperience;

  /// Question about number of cigarettes per pack
  ///
  /// In en, this message translates to:
  /// **'How many cigarettes come in a pack?'**
  String get cigarettesPerPackQuestion;

  /// Subtitle for cigarettes per pack question
  ///
  /// In en, this message translates to:
  /// **'Select the standard amount for your cigarette packs'**
  String get selectStandardAmount;

  /// Information about standard cigarette pack sizes
  ///
  /// In en, this message translates to:
  /// **'Cigarette packs typically come with 10 or 20 units. Select the amount that corresponds to the packs you buy.'**
  String get packSizesInfo;

  /// Option for 10 cigarettes pack
  ///
  /// In en, this message translates to:
  /// **'10 cigarettes'**
  String get tenCigarettes;

  /// Option for 20 cigarettes pack
  ///
  /// In en, this message translates to:
  /// **'20 cigarettes'**
  String get twentyCigarettes;

  /// Description for small pack
  ///
  /// In en, this message translates to:
  /// **'Small/compact pack'**
  String get smallPack;

  /// Description for standard pack
  ///
  /// In en, this message translates to:
  /// **'Standard/traditional pack'**
  String get standardPack;

  /// Option for other pack size
  ///
  /// In en, this message translates to:
  /// **'Other quantity'**
  String get otherQuantity;

  /// Description for custom pack size
  ///
  /// In en, this message translates to:
  /// **'Select a custom value'**
  String get selectCustomValue;

  /// Label for quantity selector
  ///
  /// In en, this message translates to:
  /// **'Quantity: '**
  String get quantity;

  /// Help text for pack size selection
  ///
  /// In en, this message translates to:
  /// **'This information helps us accurately calculate your consumption and the benefits of reducing or quitting smoking.'**
  String get packSizeHelp;

  /// Question about cigarette pack price
  ///
  /// In en, this message translates to:
  /// **'How much does a pack of cigarettes cost?'**
  String get packPriceQuestion;

  /// Subtitle for pack price question
  ///
  /// In en, this message translates to:
  /// **'This helps us calculate your financial savings'**
  String get helpCalculateFinancial;

  /// Instruction for entering pack price
  ///
  /// In en, this message translates to:
  /// **'Enter the average price you pay for a pack of cigarettes.'**
  String get enterAveragePrice;

  /// Help text for price input
  ///
  /// In en, this message translates to:
  /// **'This information helps us show how much you\'ll save by reducing or quitting smoking.'**
  String get priceHelp;

  /// Question about product type
  ///
  /// In en, this message translates to:
  /// **'What type of product do you consume?'**
  String get productTypeQuestion;

  /// Subtitle for product type question
  ///
  /// In en, this message translates to:
  /// **'Select what applies to you'**
  String get selectApplicable;

  /// Help text for product type selection
  ///
  /// In en, this message translates to:
  /// **'This helps us personalize strategies and recommendations for your specific case.'**
  String get helpPersonalizeStrategy;

  /// Option for traditional cigarettes only
  ///
  /// In en, this message translates to:
  /// **'Traditional cigarettes only'**
  String get cigaretteOnly;

  /// Description for traditional cigarettes
  ///
  /// In en, this message translates to:
  /// **'Conventional tobacco cigarettes'**
  String get traditionalCigarettes;

  /// Option for vape/e-cigarettes only
  ///
  /// In en, this message translates to:
  /// **'Vape/e-cigarettes only'**
  String get vapeOnly;

  /// Description for electronic vaping devices
  ///
  /// In en, this message translates to:
  /// **'Electronic vaping devices'**
  String get electronicDevices;

  /// Option for both traditional and electronic cigarettes
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get both;

  /// Description for using both types of products
  ///
  /// In en, this message translates to:
  /// **'I use both traditional and electronic cigarettes'**
  String get useBoth;

  /// Help text explaining importance of product type
  ///
  /// In en, this message translates to:
  /// **'Different products contain different amounts of nicotine and may require distinct strategies for reduction or cessation.'**
  String get productTypeHelp;

  /// Error message when no product type is selected
  ///
  /// In en, this message translates to:
  /// **'Please select a product type'**
  String get pleaseSelectProductType;

  /// Question about user's goal
  ///
  /// In en, this message translates to:
  /// **'What is your goal?'**
  String get goalQuestion;

  /// Subtitle for goal question
  ///
  /// In en, this message translates to:
  /// **'Select what you want to achieve'**
  String get selectGoal;

  /// Explanation about importance of setting a goal
  ///
  /// In en, this message translates to:
  /// **'Setting a clear goal is essential for your success. We want to help you achieve what you desire.'**
  String get goalExplanation;

  /// Option to reduce smoking
  ///
  /// In en, this message translates to:
  /// **'Reduce consumption'**
  String get reduceConsumption;

  /// Description for reducing consumption
  ///
  /// In en, this message translates to:
  /// **'I want to smoke fewer cigarettes and have more control over the habit'**
  String get reduceDescription;

  /// Label for reduce icon
  ///
  /// In en, this message translates to:
  /// **'Reduce'**
  String get reduce;

  /// Option to quit smoking
  ///
  /// In en, this message translates to:
  /// **'Quit smoking'**
  String get quitSmoking;

  /// Description for quitting smoking
  ///
  /// In en, this message translates to:
  /// **'I want to completely quit cigarettes and live tobacco-free'**
  String get quitDescription;

  /// Label for quit icon
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quit;

  /// Help text for goal selection
  ///
  /// In en, this message translates to:
  /// **'We\'ll adapt our resources and recommendations based on your goal. You can modify it later if you change your mind.'**
  String get goalHelp;

  /// Error message when no goal is selected
  ///
  /// In en, this message translates to:
  /// **'Please select a goal'**
  String get pleaseSelectGoal;

  /// Question about timeline for reducing consumption
  ///
  /// In en, this message translates to:
  /// **'When do you want to reduce consumption?'**
  String get timelineQuestionReduce;

  /// Question about timeline for quitting smoking
  ///
  /// In en, this message translates to:
  /// **'When do you want to quit smoking?'**
  String get timelineQuestionQuit;

  /// Subtitle for timeline question
  ///
  /// In en, this message translates to:
  /// **'Establish a deadline that seems achievable to you'**
  String get establishDeadline;

  /// Explanation about setting a realistic timeline
  ///
  /// In en, this message translates to:
  /// **'A realistic timeline increases your chances of success. Choose a deadline that you\'re comfortable with.'**
  String get timelineExplanation;

  /// Option for 7-day timeline
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get sevenDays;

  /// Description for 7-day timeline
  ///
  /// In en, this message translates to:
  /// **'I want quick results and I\'m committed'**
  String get sevenDaysDescription;

  /// Option for 14-day timeline
  ///
  /// In en, this message translates to:
  /// **'14 days'**
  String get fourteenDays;

  /// Description for 14-day timeline
  ///
  /// In en, this message translates to:
  /// **'A balanced timeframe for habit change'**
  String get fourteenDaysDescription;

  /// Option for 30-day timeline
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get thirtyDays;

  /// Description for 30-day timeline
  ///
  /// In en, this message translates to:
  /// **'A month for gradual and sustainable change'**
  String get thirtyDaysDescription;

  /// Option for no deadline
  ///
  /// In en, this message translates to:
  /// **'No set deadline'**
  String get noDeadline;

  /// Description for no deadline
  ///
  /// In en, this message translates to:
  /// **'I prefer to go at my own pace'**
  String get noDeadlineDescription;

  /// Help text for timeline selection
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry if you don\'t achieve your goal exactly on schedule. Continuous progress is what matters.'**
  String get timelineHelp;

  /// Error message when no timeline is selected
  ///
  /// In en, this message translates to:
  /// **'Please select a timeline'**
  String get pleaseSelectTimeline;

  /// Question about quitting challenge with goal text placeholder
  ///
  /// In en, this message translates to:
  /// **'What makes it difficult to {goalText} for you?'**
  String challengeQuestion(String goalText);

  /// Subtitle for challenge question
  ///
  /// In en, this message translates to:
  /// **'Identifying your main challenge helps us provide better support'**
  String get identifyChallenge;

  /// Explanation about importance of identifying challenges
  ///
  /// In en, this message translates to:
  /// **'Understanding what makes cigarettes hard to quit is the first step in overcoming that obstacle.'**
  String get challengeExplanation;

  /// Option for stress/anxiety challenge
  ///
  /// In en, this message translates to:
  /// **'Stress and anxiety'**
  String get stressAnxiety;

  /// Description for stress/anxiety challenge
  ///
  /// In en, this message translates to:
  /// **'I smoke to deal with stressful situations and anxiety'**
  String get stressDescription;

  /// Option for habit strength challenge
  ///
  /// In en, this message translates to:
  /// **'Habit strength'**
  String get habitStrength;

  /// Description for habit strength challenge
  ///
  /// In en, this message translates to:
  /// **'Smoking is already part of my daily routine'**
  String get habitDescription;

  /// Option for social influence challenge
  ///
  /// In en, this message translates to:
  /// **'Social influence'**
  String get socialInfluence;

  /// Description for social influence challenge
  ///
  /// In en, this message translates to:
  /// **'People around me smoke or encourage me to smoke'**
  String get socialDescription;

  /// Option for physical dependence challenge
  ///
  /// In en, this message translates to:
  /// **'Physical dependence'**
  String get physicalDependence;

  /// Description for physical dependence challenge
  ///
  /// In en, this message translates to:
  /// **'I experience physical symptoms when I go without smoking'**
  String get dependenceDescription;

  /// Help text for challenge selection
  ///
  /// In en, this message translates to:
  /// **'Your answers help us personalize more effective tips and strategies for your specific case.'**
  String get challengeHelp;

  /// Error message when no challenge is selected
  ///
  /// In en, this message translates to:
  /// **'Please select a challenge'**
  String get pleaseSelectChallenge;

  /// Question about smoking locations
  ///
  /// In en, this message translates to:
  /// **'Where do you usually smoke?'**
  String get locationsQuestion;

  /// Subtitle for locations question
  ///
  /// In en, this message translates to:
  /// **'Select the places where you most often smoke'**
  String get selectCommonPlaces;

  /// Explanation about importance of identifying locations
  ///
  /// In en, this message translates to:
  /// **'Knowing your usual locations helps us identify patterns and create specific strategies.'**
  String get locationsExplanation;

  /// Option for smoking at home
  ///
  /// In en, this message translates to:
  /// **'At home'**
  String get atHome;

  /// Details for home location
  ///
  /// In en, this message translates to:
  /// **'Balcony, living room, office'**
  String get homeDetails;

  /// Option for smoking at work/school
  ///
  /// In en, this message translates to:
  /// **'At work/school'**
  String get atWork;

  /// Details for work location
  ///
  /// In en, this message translates to:
  /// **'During breaks or pauses'**
  String get workDetails;

  /// Option for smoking in car/transport
  ///
  /// In en, this message translates to:
  /// **'In car/transport'**
  String get inCar;

  /// Details for car location
  ///
  /// In en, this message translates to:
  /// **'During travel'**
  String get carDetails;

  /// Option for smoking at social events
  ///
  /// In en, this message translates to:
  /// **'At social events'**
  String get socialEvents;

  /// Details for social events location
  ///
  /// In en, this message translates to:
  /// **'Bars, parties, restaurants'**
  String get socialDetails;

  /// Option for smoking outdoors
  ///
  /// In en, this message translates to:
  /// **'Outdoors'**
  String get outdoors;

  /// Details for outdoor location
  ///
  /// In en, this message translates to:
  /// **'Parks, sidewalks, outdoor areas'**
  String get outdoorsDetails;

  /// Option for other smoking locations
  ///
  /// In en, this message translates to:
  /// **'Other places'**
  String get otherPlaces;

  /// Details for other locations
  ///
  /// In en, this message translates to:
  /// **'When I\'m anxious, regardless of location'**
  String get otherPlacesDetails;

  /// Help text for locations selection
  ///
  /// In en, this message translates to:
  /// **'Identifying the most common locations helps avoid triggers and create strategies for habit change.'**
  String get locationsHelp;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Title for completion screen
  ///
  /// In en, this message translates to:
  /// **'All done!'**
  String get allDone;

  /// Subtitle for completion screen
  ///
  /// In en, this message translates to:
  /// **'Your personalized journey begins now'**
  String get personalizedJourney;

  /// Button text to start journey
  ///
  /// In en, this message translates to:
  /// **'Start My Journey'**
  String get startMyJourney;

  /// Congratulatory text on completion screen
  ///
  /// In en, this message translates to:
  /// **'Congratulations on taking the first step!'**
  String get congratulations;

  /// Text explaining personalized plan for reducing consumption
  ///
  /// In en, this message translates to:
  /// **'We\'ve created a personalized plan based on your answers to help you reduce consumption {timelineText}.'**
  String personalizedPlanReduce(String timelineText);

  /// Text explaining personalized plan for quitting smoking
  ///
  /// In en, this message translates to:
  /// **'We\'ve created a personalized plan based on your answers to help you quit smoking {timelineText}.'**
  String personalizedPlanQuit(String timelineText);

  /// Title for personalized summary section
  ///
  /// In en, this message translates to:
  /// **'Your personalized summary'**
  String get yourPersonalizedSummary;

  /// Label for daily consumption in summary
  ///
  /// In en, this message translates to:
  /// **'Daily consumption'**
  String get dailyConsumption;

  /// Value for cigarettes per day
  ///
  /// In en, this message translates to:
  /// **'{count} cigarettes per day'**
  String cigarettesPerDayValue(int count);

  /// Label for potential monthly savings
  ///
  /// In en, this message translates to:
  /// **'Potential monthly savings'**
  String get potentialMonthlySavings;

  /// Label for user's goal in summary
  ///
  /// In en, this message translates to:
  /// **'Your goal'**
  String get yourGoal;

  /// Label for main challenge in summary
  ///
  /// In en, this message translates to:
  /// **'Your main challenge'**
  String get mainChallenge;

  /// Title for personalized monitoring benefit
  ///
  /// In en, this message translates to:
  /// **'Personalized monitoring'**
  String get personalized;

  /// Description for personalized monitoring
  ///
  /// In en, this message translates to:
  /// **'Track your progress based on your habits'**
  String get personalizedDescription;

  /// Title for important achievements benefit
  ///
  /// In en, this message translates to:
  /// **'Important achievements'**
  String get importantAchievements;

  /// Description for achievements benefit
  ///
  /// In en, this message translates to:
  /// **'Celebrate each milestone in your journey'**
  String get achievementsDescription;

  /// Title for support benefit
  ///
  /// In en, this message translates to:
  /// **'Support when you need it'**
  String get supportWhenNeeded;

  /// Description for support benefit
  ///
  /// In en, this message translates to:
  /// **'Tips and strategies for difficult moments'**
  String get supportDescription;

  /// Title for guaranteed results benefit
  ///
  /// In en, this message translates to:
  /// **'Guaranteed results'**
  String get guaranteedResults;

  /// Description for guaranteed results
  ///
  /// In en, this message translates to:
  /// **'With our science-based technology'**
  String get resultsDescription;

  /// Error message during completion
  ///
  /// In en, this message translates to:
  /// **'Error completing: {error}'**
  String loadingError(String error);

  /// Developer section title
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// Toggle option for developer mode
  ///
  /// In en, this message translates to:
  /// **'Developer Mode'**
  String get developerMode;

  /// Description of developer mode
  ///
  /// In en, this message translates to:
  /// **'Enable detailed debugging and tracking'**
  String get enableDebugging;

  /// Dashboard screen title
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Description of dashboard option
  ///
  /// In en, this message translates to:
  /// **'View detailed tracking dashboard'**
  String get viewDetailedTracking;

  /// Currency section title
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// Option to change currency
  ///
  /// In en, this message translates to:
  /// **'Change currency'**
  String get changeCurrency;

  /// Description for currency option
  ///
  /// In en, this message translates to:
  /// **'Set the currency for savings calculations'**
  String get setCurrencyForCalculations;

  /// Search field placeholder
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Message shown when search returns no results
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// Toggle for list view display
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get listView;

  /// Toggle for grid view display
  ///
  /// In en, this message translates to:
  /// **'Grid View'**
  String get gridView;

  /// Text for timeline at user's own pace
  ///
  /// In en, this message translates to:
  /// **'at your own pace'**
  String get atYourOwnPace;

  /// Text for timeline of next 7 days
  ///
  /// In en, this message translates to:
  /// **'in the next 7 days'**
  String get nextSevenDays;

  /// Text for timeline of next 2 weeks
  ///
  /// In en, this message translates to:
  /// **'in the next 2 weeks'**
  String get nextTwoWeeks;

  /// Text for timeline of next month
  ///
  /// In en, this message translates to:
  /// **'in the next month'**
  String get nextMonth;

  /// Text for unspecified or default value
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// Button to register a new craving
  ///
  /// In en, this message translates to:
  /// **'Register Craving'**
  String get registerCraving;

  /// Subtitle for craving button
  ///
  /// In en, this message translates to:
  /// **'Track when you feel urges'**
  String get registerCravingSubtitle;

  /// Button to register a new smoking record
  ///
  /// In en, this message translates to:
  /// **'New Record'**
  String get newRecord;

  /// Subtitle for smoking record button
  ///
  /// In en, this message translates to:
  /// **'Record when you smoke'**
  String get newRecordSubtitle;

  /// Question asking user's location when registering a craving
  ///
  /// In en, this message translates to:
  /// **'Where are you?'**
  String get whereAreYou;

  /// Location option: Work
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// Location option: Car
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get car;

  /// Location option: Restaurant
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurant;

  /// Location option: Bar
  ///
  /// In en, this message translates to:
  /// **'Bar'**
  String get bar;

  /// Location option: Street
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get street;

  /// Location option: Park
  ///
  /// In en, this message translates to:
  /// **'Park'**
  String get park;

  /// Location option: Others
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get others;

  /// Label for optional notes field
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notes;

  /// Placeholder text for notes field in craving registration
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get howAreYouFeeling;

  /// Question about what triggered the craving
  ///
  /// In en, this message translates to:
  /// **'What triggered your craving?'**
  String get whatTriggeredCraving;

  /// Trigger option: Stress
  ///
  /// In en, this message translates to:
  /// **'Stress'**
  String get stress;

  /// Trigger option: Boredom
  ///
  /// In en, this message translates to:
  /// **'Boredom'**
  String get boredom;

  /// Trigger option: Social situation
  ///
  /// In en, this message translates to:
  /// **'Social situation'**
  String get socialSituation;

  /// Trigger option: After meal
  ///
  /// In en, this message translates to:
  /// **'After meal'**
  String get afterMeal;

  /// Trigger option: Coffee
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get coffee;

  /// Trigger option: Alcohol
  ///
  /// In en, this message translates to:
  /// **'Alcohol'**
  String get alcohol;

  /// Trigger option: Craving
  ///
  /// In en, this message translates to:
  /// **'Craving'**
  String get craving;

  /// Trigger option: Other
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// Label for craving intensity level selection
  ///
  /// In en, this message translates to:
  /// **'Intensity level'**
  String get intensityLevel;

  /// Intensity level: Mild
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get mild;

  /// Intensity level: Intense
  ///
  /// In en, this message translates to:
  /// **'Intense'**
  String get intense;

  /// Intensity level: Very intense
  ///
  /// In en, this message translates to:
  /// **'Very intense'**
  String get veryIntense;

  /// Validation message for location selection
  ///
  /// In en, this message translates to:
  /// **'Please select your location'**
  String get pleaseSelectLocation;

  /// Validation message for trigger selection
  ///
  /// In en, this message translates to:
  /// **'Please select what triggered your craving'**
  String get pleaseSelectTrigger;

  /// Validation message for intensity selection
  ///
  /// In en, this message translates to:
  /// **'Please select the intensity level'**
  String get pleaseSelectIntensity;

  /// Question asking for the reason for smoking
  ///
  /// In en, this message translates to:
  /// **'What\'s the reason?'**
  String get whatsTheReason;

  /// Reason option: Anxiety
  ///
  /// In en, this message translates to:
  /// **'Anxiety'**
  String get anxiety;

  /// Validation message for reason selection
  ///
  /// In en, this message translates to:
  /// **'Please select a reason'**
  String get pleaseSelectReason;

  /// Placeholder for notes field in smoking record
  ///
  /// In en, this message translates to:
  /// **'How do you feel? What could you have done differently?'**
  String get howDoYouFeel;

  /// Question about whether user resisted the craving
  ///
  /// In en, this message translates to:
  /// **'Did you resist?'**
  String get didYouResist;

  /// Yes option
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No option
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Question about amount smoked
  ///
  /// In en, this message translates to:
  /// **'How much did you smoke?'**
  String get howMuchDidYouSmoke;

  /// Smoking amount option: 1 or less
  ///
  /// In en, this message translates to:
  /// **'1 or less'**
  String get oneOrLess;

  /// Smoking amount option: 2-5 cigarettes
  ///
  /// In en, this message translates to:
  /// **'2-5'**
  String get twoToFive;

  /// Smoking amount option: More than 5 cigarettes
  ///
  /// In en, this message translates to:
  /// **'More than 5'**
  String get moreThanFive;

  /// Validation message for smoking amount selection
  ///
  /// In en, this message translates to:
  /// **'Please select how much you smoked'**
  String get pleaseSelectAmount;

  /// Question about duration of smoking session
  ///
  /// In en, this message translates to:
  /// **'How long did it last?'**
  String get howLongDidItLast;

  /// Duration option: Less than 5 minutes
  ///
  /// In en, this message translates to:
  /// **'Less than 5 min'**
  String get lessThan5min;

  /// Duration option: 5-15 minutes
  ///
  /// In en, this message translates to:
  /// **'5-15 min'**
  String get fiveToFifteenMin;

  /// Duration option: More than 15 minutes
  ///
  /// In en, this message translates to:
  /// **'More than 15 min'**
  String get moreThan15min;

  /// Validation message for duration selection
  ///
  /// In en, this message translates to:
  /// **'Please select how long it lasted'**
  String get pleaseSelectDuration;

  /// Title for currency selection screen
  ///
  /// In en, this message translates to:
  /// **'Select your currency'**
  String get selectCurrency;

  /// Subtitle for currency selection screen
  ///
  /// In en, this message translates to:
  /// **'Choose the currency for financial calculations'**
  String get selectCurrencySubtitle;

  /// Text explaining currency preselection
  ///
  /// In en, this message translates to:
  /// **'We\'ve preselected your local currency. You can change it if necessary.'**
  String get preselectedCurrency;

  /// Message shown when user tries to proceed without completing required fields
  ///
  /// In en, this message translates to:
  /// **'Please complete all required fields to continue'**
  String get pleaseCompleteAllFields;

  /// Button text for dismissing alerts or notifications
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// Label for common cigarette pack prices section
  ///
  /// In en, this message translates to:
  /// **'Common pack prices'**
  String get commonPrices;
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
