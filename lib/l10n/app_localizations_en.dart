// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String homeDaysWithoutSmoking(int days) {
    return '$days days without smoking';
  }

  @override
  String homeGreeting(String name) {
    return 'Hello, $name! 👋';
  }

  @override
  String get homeHealthRecovery => 'Health Recovery';

  @override
  String get homeTaste => 'Taste';

  @override
  String get homeSmell => 'Smell';

  @override
  String get homeCirculation => 'Circulation';

  @override
  String get homeLungs => 'Lungs';

  @override
  String get homeHeart => 'Heart';

  @override
  String get homeMinutesLifeGained => 'minutes of life\ngained';

  @override
  String get homeLungCapacity => 'lung\ncapacity';

  @override
  String get homeNextMilestone => 'Next Milestone';

  @override
  String homeNextMilestoneDescription(int days) {
    return 'In $days days: Blood flow improves';
  }

  @override
  String get homeRecentAchievements => 'Recent Achievements';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeFirstDay => 'First Day';

  @override
  String get homeFirstDayDescription => 'You\'ve gone 24 hours without smoking!';

  @override
  String get homeOvercoming => 'Overcoming';

  @override
  String get homeOvercomingDescription => 'Nicotine levels eliminated from body';

  @override
  String get homePersistence => 'Persistence';

  @override
  String get homePersistenceDescription => 'A whole week without cigarettes!';

  @override
  String get homeTodayStats => 'Today\'s Statistics';

  @override
  String get homeCravingsResisted => 'Cravings\nResisted';

  @override
  String get homeMinutesGainedToday => 'Minutes of Life\nGained Today';

  @override
  String get achievementCategoryAll => 'All';

  @override
  String get achievementCategoryHealth => 'Health';

  @override
  String get achievementCategoryTime => 'Time';

  @override
  String get achievementCategorySavings => 'Savings';

  @override
  String get achievementCategoryHabits => 'Habits';

  @override
  String get achievementUnlocked => 'Unlocked';

  @override
  String get achievementInProgress => 'In progress';

  @override
  String get achievementCompleted => 'Completed';

  @override
  String get achievementCurrentProgress => 'Your Current Progress';

  @override
  String achievementLevel(int level) {
    return 'Level $level';
  }

  @override
  String achievementDaysWithoutSmoking(int days) {
    return '$days days without smoking';
  }

  @override
  String achievementNextLevel(String time) {
    return 'Next level: $time';
  }

  @override
  String get achievementBenefitCO2 => 'Normal CO2';

  @override
  String get achievementBenefitTaste => 'Improved Taste';

  @override
  String get achievementBenefitCirculation => 'Circulation +15%';

  @override
  String get achievementFirstDay => 'First Day';

  @override
  String get achievementFirstDayDescription => 'Complete 24 hours without smoking';

  @override
  String get achievementOneWeek => 'One Week';

  @override
  String get achievementOneWeekDescription => 'One week without smoking!';

  @override
  String get achievementImprovedCirculation => 'Improved Circulation';

  @override
  String get achievementImprovedCirculationDescription => 'Oxygen levels normalized';

  @override
  String get achievementInitialSavings => 'Initial Savings';

  @override
  String get achievementInitialSavingsDescription => 'Save the equivalent of 1 pack of cigarettes';

  @override
  String get achievementTwoWeeks => 'Two Weeks';

  @override
  String get achievementTwoWeeksDescription => 'Two complete weeks without smoking!';

  @override
  String get achievementSubstantialSavings => 'Substantial Savings';

  @override
  String get achievementSubstantialSavingsDescription => 'Save the equivalent of 10 packs of cigarettes';

  @override
  String get achievementCleanBreathing => 'Clean Breathing';

  @override
  String get achievementCleanBreathingDescription => 'Lung capacity increased by 30%';

  @override
  String get achievementOneMonth => 'One Month';

  @override
  String get achievementOneMonthDescription => 'A whole month without smoking!';

  @override
  String get achievementNewHabitExercise => 'New Habit: Exercise';

  @override
  String get achievementNewHabitExerciseDescription => 'Record 5 days of exercise';

  @override
  String percentCompleted(int percent) {
    return '$percent% completed';
  }

  @override
  String get appName => 'NicotinaAI';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get loginToContinue => 'Log in to continue';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'example@email.com';

  @override
  String get password => 'Password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot password';

  @override
  String get login => 'Login';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get register => 'Register';

  @override
  String get emailRequired => 'Please enter your email';

  @override
  String get emailInvalid => 'Please enter a valid email';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get settings => 'Settings';

  @override
  String get home => 'Home';

  @override
  String get achievements => 'Achievements';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get appSettings => 'App Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get manageNotifications => 'Manage notifications';

  @override
  String get language => 'Language';

  @override
  String get changeLanguage => 'Change the language of the app';

  @override
  String get theme => 'Theme';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get system => 'System';

  @override
  String get habitTracking => 'Habit Tracking';

  @override
  String get cigarettesPerDay => 'Cigarettes per day before quitting';

  @override
  String get configureHabits => 'Configure your previous habits';

  @override
  String get packPrice => 'Pack price';

  @override
  String get setPriceForCalculations => 'Set the price for savings calculations';

  @override
  String get startDate => 'Start date';

  @override
  String get whenYouQuitSmoking => 'When you quit smoking';

  @override
  String get account => 'Account';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get changePassword => 'Change your access password';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get permanentlyRemoveAccount => 'Permanently remove your account';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get deleteAccountConfirmation => 'Are you sure you want to delete your account? This action is irreversible and all your data will be lost.';

  @override
  String get logout => 'Logout';

  @override
  String get logoutFromAccount => 'Disconnect from your account';

  @override
  String get logoutTitle => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout from your account?';

  @override
  String get about => 'About';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get readPrivacyPolicy => 'Read our privacy policy';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get viewTermsOfUse => 'View the app\'s terms of use';

  @override
  String get aboutApp => 'About the App';

  @override
  String get appInfo => 'Version and app information';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get finish => 'Finish';

  @override
  String get cigarettesPerDayQuestion => 'How many cigarettes do you smoke per day?';

  @override
  String get cigarettesPerDaySubtitle => 'This helps us understand your consumption level';

  @override
  String get exactNumber => 'Exact number: ';

  @override
  String get selectConsumptionLevel => 'Or select your consumption level:';

  @override
  String get low => 'Low';

  @override
  String get moderate => 'Moderate';

  @override
  String get high => 'High';

  @override
  String get veryHigh => 'Very High';

  @override
  String get upTo5 => 'Up to 5 cigarettes per day';

  @override
  String get sixTo15 => '6 to 15 cigarettes per day';

  @override
  String get sixteenTo25 => '16 to 25 cigarettes per day';

  @override
  String get moreThan25 => 'More than 25 cigarettes per day';

  @override
  String get selectConsumptionLevelError => 'Please select your consumption level';
}
