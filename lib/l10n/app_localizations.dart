import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt')
  ];

  /// Separator for text items in UI (like between terms and privacy policy)
  ///
  /// In en, this message translates to:
  /// **' | '**
  String get textSeparator;

  /// URL for Terms of Service
  ///
  /// In en, this message translates to:
  /// **'https://nicotina.ai/legal/terms-of-service'**
  String get termsOfServiceUrl;

  /// URL for Privacy Policy
  ///
  /// In en, this message translates to:
  /// **'https://nicotina.ai/legal/privacy-policy'**
  String get privacyPolicyUrl;

  /// Title for dialog when onboarding is incomplete
  ///
  /// In en, this message translates to:
  /// **'Incomplete Onboarding'**
  String get incompleteOnboarding;

  /// Message shown when user tries to complete onboarding without finishing all steps
  ///
  /// In en, this message translates to:
  /// **'Please complete all the onboarding steps before continuing.'**
  String get completeAllStepsMessage;

  /// Generic OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Text representing the plural of day
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// Welcome message on first launch language screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to NicotinaAI'**
  String get welcomeToApp;

  /// Instruction to select language on first launch
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get selectLanguage;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// First step achievement
  ///
  /// In en, this message translates to:
  /// **'First Step'**
  String get achievementFirstStep;

  /// First step achievement description
  ///
  /// In en, this message translates to:
  /// **'Complete the onboarding process'**
  String get achievementFirstStepDescription;

  /// One day achievement
  ///
  /// In en, this message translates to:
  /// **'One Day Wonder'**
  String get achievementOneDayWonder;

  /// One day achievement description
  ///
  /// In en, this message translates to:
  /// **'Stay smoke-free for 1 day'**
  String get achievementOneDayWonderDescription;

  /// Week warrior achievement
  ///
  /// In en, this message translates to:
  /// **'Week Warrior'**
  String get achievementWeekWarrior;

  /// Week warrior achievement description
  ///
  /// In en, this message translates to:
  /// **'Stay smoke-free for 7 days'**
  String get achievementWeekWarriorDescription;

  /// Month master achievement
  ///
  /// In en, this message translates to:
  /// **'Month Master'**
  String get achievementMonthMaster;

  /// Month master achievement description
  ///
  /// In en, this message translates to:
  /// **'Stay smoke-free for 30 days'**
  String get achievementMonthMasterDescription;

  /// Money mindful achievement
  ///
  /// In en, this message translates to:
  /// **'Money Mindful'**
  String get achievementMoneyMindful;

  /// Money mindful achievement description
  ///
  /// In en, this message translates to:
  /// **'Save \$50 by not smoking'**
  String get achievementMoneyMindfulDescription;

  /// Centurion achievement
  ///
  /// In en, this message translates to:
  /// **'Centurion'**
  String get achievementCenturion;

  /// Centurion achievement description
  ///
  /// In en, this message translates to:
  /// **'Save \$100 by not smoking'**
  String get achievementCenturionDescription;

  /// Craving crusher achievement
  ///
  /// In en, this message translates to:
  /// **'Craving Crusher'**
  String get achievementCravingCrusher;

  /// Craving crusher achievement description
  ///
  /// In en, this message translates to:
  /// **'Successfully resist 10 cravings'**
  String get achievementCravingCrusherDescription;

  /// Text shown when content is loading
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// The name of the app
  ///
  /// In en, this message translates to:
  /// **'NicotinaAI'**
  String get appName;

  /// Text shown when a page is not found
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// Motivational message for the user
  ///
  /// In en, this message translates to:
  /// **'Keep going! You\'re doing great!'**
  String get motivationalMessage;

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
  /// **'We offer different resources to support your journey. Select everything you think might help.'**
  String get helpScreenExplanation;

  /// Option for daily tips
  ///
  /// In en, this message translates to:
  /// **'Daily tips'**
  String get dailyTips;

  /// Description for daily tips
  ///
  /// In en, this message translates to:
  /// **'Receive practical tips every day to support your journey'**
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
  /// **'Savings Calculator'**
  String get savingsCalculator;

  /// Description for savings calculator
  ///
  /// In en, this message translates to:
  /// **'See how much money you\'re saving by reducing or quitting smoking'**
  String get savingsCalculatorDescription;

  /// Text explaining that preferences can be modified later
  ///
  /// In en, this message translates to:
  /// **'You can modify these preferences at any time in the app settings.'**
  String get modifyPreferencesAnytime;

  /// Title for personalize screen
  ///
  /// In en, this message translates to:
  /// **'When do you usually smoke the most?'**
  String get personalizeScreenTitle;

  /// Subtitle for personalize screen
  ///
  /// In en, this message translates to:
  /// **'Select the times when you feel the most urge to smoke'**
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
  /// **'Hello, {name}!'**
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
  /// **'Next milestone in {days} days'**
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

  /// Title for achievement notification
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked!'**
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
  /// **'Normalized oxygen levels'**
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
  /// **'Two full weeks without smoking!'**
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
  /// **'A full month without smoking!'**
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

  /// Login screen title
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Login to continue'**
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
  /// **'Forgot my password'**
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
  /// **'Change the app language'**
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
  /// **'Change your login password'**
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
  /// **'Log out from your account'**
  String get logoutFromAccount;

  /// Title of logout dialog
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTitle;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account?'**
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
  /// **'App version and information'**
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
  /// **'This information helps us show you how much you\'ll save by reducing or quitting smoking.'**
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
  /// **'Different products contain different amounts of nicotine and may require different strategies for reduction or cessation.'**
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
  /// **'Set a deadline that seems achievable to you'**
  String get establishDeadline;

  /// Explanation about setting a realistic timeline
  ///
  /// In en, this message translates to:
  /// **'A realistic timeline increases your chances of success. Choose a timeframe you\'re comfortable with.'**
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
  /// **'A balanced timeframe for changing habits'**
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
  /// **'No defined deadline'**
  String get noDeadline;

  /// Description for no deadline
  ///
  /// In en, this message translates to:
  /// **'I prefer to go at my own pace'**
  String get noDeadlineDescription;

  /// Help text for timeline selection
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry if you don\'t achieve your goal exactly within the timeframe. What matters is continuous progress.'**
  String get timelineHelp;

  /// Error message when no timeline is selected
  ///
  /// In en, this message translates to:
  /// **'Please select a timeline'**
  String get pleaseSelectTimeline;

  /// Subtitle for challenge question
  ///
  /// In en, this message translates to:
  /// **'Identifying your main challenge helps us provide better support'**
  String get identifyChallenge;

  /// Explanation about importance of identifying challenges
  ///
  /// In en, this message translates to:
  /// **'Understanding what makes quitting cigarettes difficult is the first step to overcoming that obstacle.'**
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
  /// **'I experience physical symptoms when I\'m without smoking'**
  String get dependenceDescription;

  /// Help text for challenge selection
  ///
  /// In en, this message translates to:
  /// **'Your answers help us personalize advice and strategies that are more effective for your specific case.'**
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
  /// **'Knowing your usual places helps us identify patterns and create specific strategies.'**
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
  /// **'In the car/transport'**
  String get inCar;

  /// Details for car location
  ///
  /// In en, this message translates to:
  /// **'During trips'**
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
  /// **'Identifying the most common places helps to avoid triggers and create strategies to change habits.'**
  String get locationsHelp;

  /// Title for completion screen
  ///
  /// In en, this message translates to:
  /// **'All Done!'**
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
  /// **'Error: {error}'**
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
  /// **'List view'**
  String get listView;

  /// Toggle for grid view display
  ///
  /// In en, this message translates to:
  /// **'Grid view'**
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
  /// **'When you feel the urge'**
  String get registerCravingSubtitle;

  /// Button to register a new smoking record
  ///
  /// In en, this message translates to:
  /// **'New Record'**
  String get newRecord;

  /// Subtitle for smoking record button
  ///
  /// In en, this message translates to:
  /// **'When you smoke'**
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
  /// **'After eating'**
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
  /// **'We\'ve preselected your local currency. You can change it if needed.'**
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

  /// Button text to refresh content
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Error message when notifications fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading notifications'**
  String get errorLoadingNotifications;

  /// Message shown when there are no notifications
  ///
  /// In en, this message translates to:
  /// **'No notifications yet!'**
  String get noNotificationsYet;

  /// Description for empty notifications list
  ///
  /// In en, this message translates to:
  /// **'Continue using the app to receive motivational messages and achievements.'**
  String get emptyNotificationsDescription;

  /// Text for claim reward button
  ///
  /// In en, this message translates to:
  /// **'Claim reward: {xp} XP'**
  String claimReward(int xp);

  /// Text shown when reward is claimed
  ///
  /// In en, this message translates to:
  /// **'Reward claimed: {xp} XP'**
  String rewardClaimed(int xp);

  /// Title for daily motivation section
  ///
  /// In en, this message translates to:
  /// **'Daily Motivation'**
  String get dailyMotivation;

  /// Description for daily motivation card
  ///
  /// In en, this message translates to:
  /// **'Your personalized daily motivation is here. Open it to get your XP reward!'**
  String get dailyMotivationDescription;

  /// Retry button text for failed operations
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Success message when a resisted craving is recorded
  ///
  /// In en, this message translates to:
  /// **'Craving resistance successfully recorded!'**
  String get cravingResistedRecorded;

  /// Success message when a craving is recorded
  ///
  /// In en, this message translates to:
  /// **'Craving successfully recorded!'**
  String get cravingRecorded;

  /// Error message when saving craving fails
  ///
  /// In en, this message translates to:
  /// **'Error saving craving. Tap to retry.'**
  String get errorSavingCraving;

  /// Success message when a smoking record is saved
  ///
  /// In en, this message translates to:
  /// **'Record successfully saved!'**
  String get recordSaved;

  /// Tooltip text for retry button
  ///
  /// In en, this message translates to:
  /// **'Tap to retry'**
  String get tapToRetry;

  /// Tooltip text for sync error status
  ///
  /// In en, this message translates to:
  /// **'Sync error'**
  String get syncError;

  /// Button text to try an operation again
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// Message shown when data loading fails
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// Message shown when no health recoveries are found
  ///
  /// In en, this message translates to:
  /// **'No health recoveries found'**
  String get noRecoveriesFound;

  /// Message shown when no recent health recoveries are available
  ///
  /// In en, this message translates to:
  /// **'No recent health recoveries to show'**
  String get noRecentRecoveries;

  /// Button text to view all health recoveries
  ///
  /// In en, this message translates to:
  /// **'View All Health Recoveries'**
  String get viewAllRecoveries;

  /// Title for health recovery section
  ///
  /// In en, this message translates to:
  /// **'Health Recovery'**
  String get healthRecovery;

  /// Button text to see all items
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// Label for achieved status
  ///
  /// In en, this message translates to:
  /// **'Achieved'**
  String get achieved;

  /// Label for progress status
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// Text showing days without smoking
  ///
  /// In en, this message translates to:
  /// **'{days} days smoke free'**
  String daysSmokeFree(int days);

  /// Text showing days required to achieve a recovery
  ///
  /// In en, this message translates to:
  /// **'Days to achieve: {days}'**
  String daysToAchieve(int days);

  /// Text showing days remaining to achieve a recovery
  ///
  /// In en, this message translates to:
  /// **'{days} days remaining'**
  String daysRemaining(int days);

  /// Text showing when a recovery was achieved
  ///
  /// In en, this message translates to:
  /// **'Achieved on {date}'**
  String achievedOn(DateTime date);

  /// Encouragement message
  ///
  /// In en, this message translates to:
  /// **'Keep going!'**
  String get keepGoing;

  /// Detailed encouragement message
  ///
  /// In en, this message translates to:
  /// **'You\'re making great progress. Each day without smoking brings you closer to reaching this health milestone.'**
  String get encouragementMessage;

  /// Message shown when a health recovery is achieved
  ///
  /// In en, this message translates to:
  /// **'Your body has already recovered in this area. Keep up the good work to maintain and further improve your health.'**
  String get recoveryAchievedMessage;

  /// Title for science information section
  ///
  /// In en, this message translates to:
  /// **'The Science Behind It'**
  String get scienceBehindIt;

  /// General scientific information about health recovery
  ///
  /// In en, this message translates to:
  /// **'When you quit smoking, your body begins a series of healing processes. These start minutes after your last cigarette and continue for years, gradually restoring your health to that of a non-smoker.'**
  String get generalHealthScienceInfo;

  /// Scientific information about taste recovery
  ///
  /// In en, this message translates to:
  /// **'When you smoke, chemicals in tobacco damage taste buds and reduce your ability to taste. After just a few days without smoking, these taste receptors begin to heal, allowing you to experience more flavors and enjoy food more.'**
  String get tasteScienceInfo;

  /// Scientific information about smell recovery
  ///
  /// In en, this message translates to:
  /// **'Smoking damages the olfactory nerves that transmit smell information to the brain. Within a few days after quitting, these nerves begin to recover, gradually improving your sense of smell and allowing you to detect more subtle odors.'**
  String get smellScienceInfo;

  /// Scientific information about blood oxygen recovery
  ///
  /// In en, this message translates to:
  /// **'Carbon monoxide from cigarettes binds to hemoglobin in your blood, reducing its ability to carry oxygen. Within 12-24 hours after quitting, carbon monoxide levels drop dramatically, allowing your blood to carry oxygen more effectively.'**
  String get bloodOxygenScienceInfo;

  /// Scientific information about carbon monoxide elimination
  ///
  /// In en, this message translates to:
  /// **'Cigarette smoke contains carbon monoxide, which displaces oxygen in your blood. Within 12 hours after quitting, carbon monoxide levels return to normal, and oxygen levels in your body significantly increase.'**
  String get carbonMonoxideScienceInfo;

  /// Scientific information about nicotine expulsion
  ///
  /// In en, this message translates to:
  /// **'Nicotine has a half-life of approximately 2 hours, meaning it takes about 72 hours (3 days) for all nicotine to be eliminated from your body. Once nicotine is gone, physical withdrawal symptoms begin to diminish.'**
  String get nicotineScienceInfo;

  /// Scientific information about improved breathing
  ///
  /// In en, this message translates to:
  /// **'After 7 days without smoking, lung function begins to improve as inflammation decreases and lungs begin to clear accumulated mucus. You\'ll notice less coughing and easier breathing, especially during physical activity.'**
  String get improvedBreathingScienceInfo;

  /// Scientific information about improved circulation
  ///
  /// In en, this message translates to:
  /// **'After two weeks without smoking, your circulation significantly improves. Blood vessels dilate, blood pressure normalizes, and more oxygen reaches your muscles and organs, making physical activity easier and less strenuous.'**
  String get improvedCirculationScienceInfo;

  /// Scientific information about decreased coughing
  ///
  /// In en, this message translates to:
  /// **'One month after quitting, the cilia (tiny hair-like structures) in your lungs begin to regrow. These help clean your lungs and reduce infections. Your cough and shortness of breath continue to decrease.'**
  String get decreasedCoughingScienceInfo;

  /// Scientific information about lung cilia recovery
  ///
  /// In en, this message translates to:
  /// **'After 3 months without smoking, your lung function can improve by up to 30%. The cilia in your lungs have largely regrown, improving your lungs\' ability to clean themselves, fight infection, and reduce mucus.'**
  String get lungCiliaScienceInfo;

  /// Scientific information about reduced heart disease risk
  ///
  /// In en, this message translates to:
  /// **'After a year without smoking, your risk of coronary heart disease decreases to about half that of a smoker. Your heart function continues to improve as blood vessels heal and circulation improves.'**
  String get reducedHeartDiseaseRiskScienceInfo;

  /// Button text to view health recoveries screen
  ///
  /// In en, this message translates to:
  /// **'View Health Recoveries'**
  String get viewHealthRecoveries;

  /// Message shown when a health recovery is not found
  ///
  /// In en, this message translates to:
  /// **'Health recovery not found'**
  String get recoveryNotFound;

  /// Title for health recovery tracking feature
  ///
  /// In en, this message translates to:
  /// **'Track Your Health Journey'**
  String get trackYourHealthJourney;

  /// Description for health recovery tracking feature
  ///
  /// In en, this message translates to:
  /// **'See how your body recovers after quitting smoking'**
  String get healthRecoveryDescription;

  /// Generic error message when an operation fails
  ///
  /// In en, this message translates to:
  /// **'Something went wrong, please try again'**
  String get somethingWentWrong;

  /// Text displayed for features that are not yet available
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// Message prompting users to register their first cigarette to see health recovery data
  ///
  /// In en, this message translates to:
  /// **'Register your first cigarette to see health recovery'**
  String get registerFirstCigarette;

  /// Generic error message displayed when an unknown error occurs
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// Title for feedback dialog
  ///
  /// In en, this message translates to:
  /// **'We value your feedback'**
  String get feedbackTitle;

  /// Skip button text
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Question about user experience
  ///
  /// In en, this message translates to:
  /// **'How is your experience?'**
  String get howIsYourExperience;

  /// Question if user is enjoying the app
  ///
  /// In en, this message translates to:
  /// **'Are you enjoying the app?'**
  String get enjoyingApp;

  /// Negative response to enjoying app question
  ///
  /// In en, this message translates to:
  /// **'Not really'**
  String get notReally;

  /// Positive response to enjoying app question
  ///
  /// In en, this message translates to:
  /// **'Yes, I\'m enjoying it!'**
  String get yesImEnjoying;

  /// Positive response to liking app question
  ///
  /// In en, this message translates to:
  /// **'Yes, I like it!'**
  String get yesILikeIt;

  /// Question about rating the app
  ///
  /// In en, this message translates to:
  /// **'Would you rate the app?'**
  String get rateApp;

  /// Question about rating the app on scale
  ///
  /// In en, this message translates to:
  /// **'How would you rate our app?'**
  String get howWouldYouRateApp;

  /// Statement about value of user opinion
  ///
  /// In en, this message translates to:
  /// **'Your opinion matters to us'**
  String get yourOpinionMatters;

  /// Statement about app improvement process
  ///
  /// In en, this message translates to:
  /// **'We are constantly improving our app based on user feedback'**
  String get weAreConstantlyImproving;

  /// Later button text
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// Prompt for negative feedback
  ///
  /// In en, this message translates to:
  /// **'Tell us what\'s not right'**
  String get tellUsIssues;

  /// Request for improvement suggestions
  ///
  /// In en, this message translates to:
  /// **'Help us improve by telling us what we can do better:'**
  String get helpUsImprove;

  /// Label for feedback category selection
  ///
  /// In en, this message translates to:
  /// **'Feedback category'**
  String get feedbackCategory;

  /// Feedback category: Interface
  ///
  /// In en, this message translates to:
  /// **'Interface'**
  String get interface;

  /// Feedback category: Features
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// Feedback category: Performance
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// Feedback category: Statistics Accuracy
  ///
  /// In en, this message translates to:
  /// **'Statistics Accuracy'**
  String get statisticsAccuracy;

  /// Feedback category: Accuracy of statistics
  ///
  /// In en, this message translates to:
  /// **'Accuracy of statistics'**
  String get accuracyOfStatistics;

  /// Label for feedback input field
  ///
  /// In en, this message translates to:
  /// **'Your feedback'**
  String get yourFeedback;

  /// Placeholder for feedback description
  ///
  /// In en, this message translates to:
  /// **'Describe what we can improve...'**
  String get describeProblem;

  /// Placeholder for improvement suggestions
  ///
  /// In en, this message translates to:
  /// **'Describe what we could improve...'**
  String get describeWhatToImprove;

  /// Question about potential improvements
  ///
  /// In en, this message translates to:
  /// **'What could be better?'**
  String get whatCouldBeBetter;

  /// Button text to submit feedback
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get sendFeedback;

  /// Acknowledgment message for feedback
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get thankYouForFeedback;

  /// Response to positive feedback
  ///
  /// In en, this message translates to:
  /// **'We\'re glad you like it!'**
  String get gladYouLikeIt;

  /// Request to rate app on store
  ///
  /// In en, this message translates to:
  /// **'Would you rate our app on the store?'**
  String get wouldYouRateOnStore;

  /// Request to rate app on app store
  ///
  /// In en, this message translates to:
  /// **'Would you like to rate the app on the store?'**
  String get rateAppStore;

  /// Response that user has already rated
  ///
  /// In en, this message translates to:
  /// **'I\'ve already rated'**
  String get alreadyRated;

  /// Button to rate app now
  ///
  /// In en, this message translates to:
  /// **'Rate now'**
  String get rateNow;

  /// Error message for feedback submission
  ///
  /// In en, this message translates to:
  /// **'Oops, something went wrong'**
  String get feedbackError;

  /// Error message when feedback cannot be saved
  ///
  /// In en, this message translates to:
  /// **'Could not save your feedback'**
  String get couldNotSaveFeedback;

  /// Acknowledgment button text
  ///
  /// In en, this message translates to:
  /// **'I understand'**
  String get understand;

  /// Error message when onboarding fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading onboarding'**
  String get onboardingLoadError;

  /// Generic message for unknown errors
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownError;

  /// Error message when user is not authenticated
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to perform this action'**
  String get errorUserNotAuthenticated;

  /// Message shown when user is not authenticated
  ///
  /// In en, this message translates to:
  /// **'You are not logged in'**
  String get userNotAuthenticated;

  /// Message shown when registering a resisted craving
  ///
  /// In en, this message translates to:
  /// **'Registering craving resisted...'**
  String get registeringCravingResisted;

  /// Message shown when registering a craving
  ///
  /// In en, this message translates to:
  /// **'Registering craving...'**
  String get registeringCraving;

  /// Question about quitting challenge with goal text placeholder
  ///
  /// In en, this message translates to:
  /// **'What makes it difficult to {goalText}?'**
  String challengeQuestion(String goalText);

  /// Text explaining personalized plan for reducing consumption
  ///
  /// In en, this message translates to:
  /// **'We\'ve created a personalized plan to help you reduce your cigarette consumption {timelineText}. This plan is based on your habits and preferences.'**
  String personalizedPlanReduce(String timelineText);

  /// Text explaining personalized plan for quitting smoking
  ///
  /// In en, this message translates to:
  /// **'We\'ve created a personalized plan to help you quit smoking {timelineText}. This plan is based on your habits and preferences.'**
  String personalizedPlanQuit(String timelineText);

  /// Text for showing today's date with time
  ///
  /// In en, this message translates to:
  /// **'Today at {time}'**
  String todayAt(String time);

  /// Text for showing yesterday's date with time
  ///
  /// In en, this message translates to:
  /// **'Yesterday at {time}'**
  String yesterdayAt(String time);

  /// Text for showing day of week with time
  ///
  /// In en, this message translates to:
  /// **'{weekday} at {time}'**
  String dayOfWeekAt(String weekday, String time);

  /// Format for showing a complete date with time
  ///
  /// In en, this message translates to:
  /// **'{day}/{month}/{year} at {time}'**
  String dateTimeFormat(String day, String month, String year, String time);

  /// Name of the day of the week: Monday
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// Name of the day of the week: Tuesday
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// Name of the day of the week: Wednesday
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// Name of the day of the week: Thursday
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// Name of the day of the week: Friday
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// Name of the day of the week: Saturday
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// Name of the day of the week: Sunday
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// Subtitle for registration screen
  ///
  /// In en, this message translates to:
  /// **'Fill in your information to create an account'**
  String get fillInformation;

  /// Label for name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Error message when name is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get nameRequired;

  /// Error message when password is too short
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// Label for confirm password field
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Error message when confirm password is empty
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// Error message when passwords don't match
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Text for terms and conditions agreement checkbox
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms and Conditions'**
  String get termsConditionsAgree;

  /// Error message when terms not accepted
  ///
  /// In en, this message translates to:
  /// **'Please accept the Terms and Conditions to continue'**
  String get termsConditionsRequired;

  /// Text for users who already have an account
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyAccount;

  /// Title shown after password reset link is sent
  ///
  /// In en, this message translates to:
  /// **'Reset link sent'**
  String get resetLinkSent;

  /// Message shown after password reset link is sent
  ///
  /// In en, this message translates to:
  /// **'Check your email for instructions on how to reset your password'**
  String get checkEmailInstructions;

  /// Instructions on the forgot password screen
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you instructions to reset your password'**
  String get forgotPasswordInstructions;

  /// Button text to send password reset link
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// Link to go back to the login screen
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get backToLogin;

  /// Button text to create a new account
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Title for notification permission screen
  ///
  /// In en, this message translates to:
  /// **'Stay Informed'**
  String get stayInformed;

  /// Subtitle for notification permission screen
  ///
  /// In en, this message translates to:
  /// **'Receive timely cues and reminders to help with your journey'**
  String get receiveTimelyCues;

  /// Title for reminders section in notification permission screen
  ///
  /// In en, this message translates to:
  /// **'Important Reminders'**
  String get importantReminders;

  /// Explanation text about the benefits of notifications
  ///
  /// In en, this message translates to:
  /// **'Notifications help you stay on track with your goals, provide timely support during difficult moments, and celebrate your achievements.'**
  String get notificationsHelp;

  /// Text shown when requesting permissions
  ///
  /// In en, this message translates to:
  /// **'Requesting...'**
  String get requesting;

  /// Button text to allow notifications
  ///
  /// In en, this message translates to:
  /// **'Allow Notifications'**
  String get allowNotifications;

  /// Message shown when notifications are enabled
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled successfully'**
  String get notificationsEnabled;

  /// Text for skipping an optional step
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// Message shown when notification permission request fails
  ///
  /// In en, this message translates to:
  /// **'Notification permission was not granted'**
  String get notificationPermissionFailed;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr', 'it', 'nl', 'pl', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'it': return AppLocalizationsIt();
    case 'nl': return AppLocalizationsNl();
    case 'pl': return AppLocalizationsPl();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
