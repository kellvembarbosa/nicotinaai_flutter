// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
