// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get incompleteOnboarding => 'Incomplete Onboarding';

  @override
  String get completeAllStepsMessage => 'Please complete all the onboarding steps before continuing.';

  @override
  String get ok => 'OK';

  @override
  String get days => 'dagen';

  @override
  String get helpScreenTitle => 'How can we help you?';

  @override
  String get selectAllInterests => 'Select all options that interest you';

  @override
  String get helpScreenExplanation => 'We offer different resources to support your journey. Select all that you believe can help.';

  @override
  String get dailyTips => 'Daily tips';

  @override
  String get dailyTipsDescription => 'Receive practical advice every day to support your journey';

  @override
  String get customReminders => 'Custom reminders';

  @override
  String get customRemindersDescription => 'Notifications to keep you motivated and on track';

  @override
  String get progressMonitoring => 'Progress monitoring';

  @override
  String get progressMonitoringDescription => 'Visually track your progress over time';

  @override
  String get supportCommunity => 'Support community';

  @override
  String get supportCommunityDescription => 'Connect with others on a similar journey';

  @override
  String get cigaretteAlternatives => 'Cigarette alternatives';

  @override
  String get cigaretteAlternativesDescription => 'Suggestions for activities and products to replace the habit';

  @override
  String get savingsCalculator => 'Savings Calculator';

  @override
  String get savingsCalculatorDescription => 'See how much money you\'re saving by reducing or quitting';

  @override
  String get modifyPreferencesAnytime => 'You can modify these preferences at any time in the app settings.';

  @override
  String get personalizeScreenTitle => 'When do you usually smoke more?';

  @override
  String get personalizeScreenSubtitle => 'Select the times when you feel more like smoking';

  @override
  String get afterMeals => 'After meals';

  @override
  String get duringWorkBreaks => 'During work breaks';

  @override
  String get inSocialEvents => 'At social events';

  @override
  String get whenStressed => 'When I\'m stressed';

  @override
  String get withCoffeeOrAlcohol => 'When drinking coffee or alcohol';

  @override
  String get whenBored => 'When I\'m bored';

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
  String get achievementUnlocked => 'Unlocked!';

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
  String get welcomeBack => 'Welkom terug';

  @override
  String get loginToContinue => 'Log in to continue';

  @override
  String get email => 'E-mail';

  @override
  String get emailHint => 'example@email.com';

  @override
  String get password => 'Wachtwoord';

  @override
  String get rememberMe => 'Onthoud mij';

  @override
  String get forgotPassword => 'Wachtwoord vergeten';

  @override
  String get login => 'Inloggen';

  @override
  String get noAccount => 'Nog geen account?';

  @override
  String get register => 'Registreren';

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
  String get cancel => 'Annuleren';

  @override
  String get confirm => 'Bevestigen';

  @override
  String get save => 'Opslaan';

  @override
  String get delete => 'Verwijderen';

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

  @override
  String get welcomeToNicotinaAI => 'Welcome to NicotinaAI';

  @override
  String get personalAssistant => 'Your personal assistant to quit smoking';

  @override
  String get start => 'Start';

  @override
  String get breatheFreedom => 'BREATHE FREEDOM. YOUR NEW LIFE STARTS NOW.';

  @override
  String get personalizeExperience => 'Let\'s personalize your experience to help you achieve your goals of quitting smoking. Answer a few questions to get started.';

  @override
  String get cigarettesPerPackQuestion => 'How many cigarettes come in a pack?';

  @override
  String get selectStandardAmount => 'Select the standard amount for your cigarette packs';

  @override
  String get packSizesInfo => 'Cigarette packs typically come with 10 or 20 units. Select the amount that corresponds to the packs you buy.';

  @override
  String get tenCigarettes => '10 cigarettes';

  @override
  String get twentyCigarettes => '20 cigarettes';

  @override
  String get smallPack => 'Small/compact pack';

  @override
  String get standardPack => 'Standard/traditional pack';

  @override
  String get otherQuantity => 'Other quantity';

  @override
  String get selectCustomValue => 'Select a custom value';

  @override
  String get quantity => 'Quantity: ';

  @override
  String get packSizeHelp => 'This information helps us accurately calculate your consumption and the benefits of reducing or quitting smoking.';

  @override
  String get packPriceQuestion => 'How much does a pack of cigarettes cost?';

  @override
  String get helpCalculateFinancial => 'This helps us calculate your financial savings';

  @override
  String get enterAveragePrice => 'Enter the average price you pay for a pack of cigarettes.';

  @override
  String get priceHelp => 'This information helps us show how much you\'ll save by reducing or quitting smoking.';

  @override
  String get productTypeQuestion => 'What type of product do you consume?';

  @override
  String get selectApplicable => 'Select what applies to you';

  @override
  String get helpPersonalizeStrategy => 'This helps us personalize strategies and recommendations for your specific case.';

  @override
  String get cigaretteOnly => 'Traditional cigarettes only';

  @override
  String get traditionalCigarettes => 'Conventional tobacco cigarettes';

  @override
  String get vapeOnly => 'Vape/e-cigarettes only';

  @override
  String get electronicDevices => 'Electronic vaping devices';

  @override
  String get both => 'Both';

  @override
  String get useBoth => 'I use both traditional and electronic cigarettes';

  @override
  String get productTypeHelp => 'Different products contain different amounts of nicotine and may require distinct strategies for reduction or cessation.';

  @override
  String get pleaseSelectProductType => 'Please select a product type';

  @override
  String get goalQuestion => 'What is your goal?';

  @override
  String get selectGoal => 'Select what you want to achieve';

  @override
  String get goalExplanation => 'Setting a clear goal is essential for your success. We want to help you achieve what you desire.';

  @override
  String get reduceConsumption => 'Reduce consumption';

  @override
  String get reduceDescription => 'I want to smoke fewer cigarettes and have more control over the habit';

  @override
  String get reduce => 'Reduce';

  @override
  String get quitSmoking => 'Quit smoking';

  @override
  String get quitDescription => 'I want to completely quit cigarettes and live tobacco-free';

  @override
  String get quit => 'Quit';

  @override
  String get goalHelp => 'We\'ll adapt our resources and recommendations based on your goal. You can modify it later if you change your mind.';

  @override
  String get pleaseSelectGoal => 'Please select a goal';

  @override
  String get timelineQuestionReduce => 'When do you want to reduce consumption?';

  @override
  String get timelineQuestionQuit => 'When do you want to quit smoking?';

  @override
  String get establishDeadline => 'Establish a deadline that seems achievable to you';

  @override
  String get timelineExplanation => 'A realistic timeline increases your chances of success. Choose a deadline that you\'re comfortable with.';

  @override
  String get sevenDays => '7 days';

  @override
  String get sevenDaysDescription => 'I want quick results and I\'m committed';

  @override
  String get fourteenDays => '14 days';

  @override
  String get fourteenDaysDescription => 'A balanced timeframe for habit change';

  @override
  String get thirtyDays => '30 days';

  @override
  String get thirtyDaysDescription => 'A month for gradual and sustainable change';

  @override
  String get noDeadline => 'No set deadline';

  @override
  String get noDeadlineDescription => 'I prefer to go at my own pace';

  @override
  String get timelineHelp => 'Don\'t worry if you don\'t achieve your goal exactly on schedule. Continuous progress is what matters.';

  @override
  String get pleaseSelectTimeline => 'Please select a timeline';

  @override
  String challengeQuestion(String goalText) {
    return 'What makes it difficult to $goalText for you?';
  }

  @override
  String get identifyChallenge => 'Identifying your main challenge helps us provide better support';

  @override
  String get challengeExplanation => 'Understanding what makes cigarettes hard to quit is the first step in overcoming that obstacle.';

  @override
  String get stressAnxiety => 'Stress and anxiety';

  @override
  String get stressDescription => 'I smoke to deal with stressful situations and anxiety';

  @override
  String get habitStrength => 'Habit strength';

  @override
  String get habitDescription => 'Smoking is already part of my daily routine';

  @override
  String get socialInfluence => 'Social influence';

  @override
  String get socialDescription => 'People around me smoke or encourage me to smoke';

  @override
  String get physicalDependence => 'Physical dependence';

  @override
  String get dependenceDescription => 'I experience physical symptoms when I go without smoking';

  @override
  String get challengeHelp => 'Your answers help us personalize more effective tips and strategies for your specific case.';

  @override
  String get pleaseSelectChallenge => 'Please select a challenge';

  @override
  String get locationsQuestion => 'Where do you usually smoke?';

  @override
  String get selectCommonPlaces => 'Select the places where you most often smoke';

  @override
  String get locationsExplanation => 'Knowing your usual locations helps us identify patterns and create specific strategies.';

  @override
  String get atHome => 'At home';

  @override
  String get homeDetails => 'Balcony, living room, office';

  @override
  String get atWork => 'At work/school';

  @override
  String get workDetails => 'During breaks or pauses';

  @override
  String get inCar => 'In car/transport';

  @override
  String get carDetails => 'During travel';

  @override
  String get socialEvents => 'At social events';

  @override
  String get socialDetails => 'Bars, parties, restaurants';

  @override
  String get outdoors => 'Outdoors';

  @override
  String get outdoorsDetails => 'Parks, sidewalks, outdoor areas';

  @override
  String get otherPlaces => 'Other places';

  @override
  String get otherPlacesDetails => 'When I\'m anxious, regardless of location';

  @override
  String get locationsHelp => 'Identifying the most common locations helps avoid triggers and create strategies for habit change.';

  @override
  String get continueButton => 'Continue';

  @override
  String get allDone => 'All done!';

  @override
  String get personalizedJourney => 'Your personalized journey begins now';

  @override
  String get startMyJourney => 'Start My Journey';

  @override
  String get congratulations => 'Congratulations on taking the first step!';

  @override
  String personalizedPlanReduce(String timelineText) {
    return 'We\'ve created a personalized plan based on your answers to help you reduce consumption $timelineText.';
  }

  @override
  String personalizedPlanQuit(String timelineText) {
    return 'We\'ve created a personalized plan based on your answers to help you quit smoking $timelineText.';
  }

  @override
  String get yourPersonalizedSummary => 'Your personalized summary';

  @override
  String get dailyConsumption => 'Daily consumption';

  @override
  String cigarettesPerDayValue(int count) {
    return '$count cigarettes per day';
  }

  @override
  String get potentialMonthlySavings => 'Potential monthly savings';

  @override
  String get yourGoal => 'Your goal';

  @override
  String get mainChallenge => 'Your main challenge';

  @override
  String get personalized => 'Personalized monitoring';

  @override
  String get personalizedDescription => 'Track your progress based on your habits';

  @override
  String get importantAchievements => 'Important achievements';

  @override
  String get achievementsDescription => 'Celebrate each milestone in your journey';

  @override
  String get supportWhenNeeded => 'Support when you need it';

  @override
  String get supportDescription => 'Tips and strategies for difficult moments';

  @override
  String get guaranteedResults => 'Guaranteed results';

  @override
  String get resultsDescription => 'With our science-based technology';

  @override
  String loadingError(String error) {
    return 'Error completing: $error';
  }

  @override
  String get developer => 'Developer';

  @override
  String get developerMode => 'Developer Mode';

  @override
  String get enableDebugging => 'Enable detailed debugging and tracking';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get viewDetailedTracking => 'View detailed tracking dashboard';

  @override
  String get currency => 'Currency';

  @override
  String get changeCurrency => 'Change currency';

  @override
  String get setCurrencyForCalculations => 'Set the currency for savings calculations';

  @override
  String get search => 'Search';

  @override
  String get noResults => 'No results found';

  @override
  String get listView => 'List View';

  @override
  String get gridView => 'Grid View';

  @override
  String get atYourOwnPace => 'at your own pace';

  @override
  String get nextSevenDays => 'in the next 7 days';

  @override
  String get nextTwoWeeks => 'in the next 2 weeks';

  @override
  String get nextMonth => 'in the next month';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get registerCraving => 'Register Craving';

  @override
  String get registerCravingSubtitle => 'Track when you feel urges';

  @override
  String get newRecord => 'New Record';

  @override
  String get newRecordSubtitle => 'Record when you smoke';

  @override
  String get whereAreYou => 'Where are you?';

  @override
  String get work => 'Work';

  @override
  String get car => 'Car';

  @override
  String get restaurant => 'Restaurant';

  @override
  String get bar => 'Bar';

  @override
  String get street => 'Street';

  @override
  String get park => 'Park';

  @override
  String get others => 'Others';

  @override
  String get notes => 'Notes (optional)';

  @override
  String get howAreYouFeeling => 'How are you feeling?';

  @override
  String get whatTriggeredCraving => 'What triggered your craving?';

  @override
  String get stress => 'Stress';

  @override
  String get boredom => 'Boredom';

  @override
  String get socialSituation => 'Social situation';

  @override
  String get afterMeal => 'After meal';

  @override
  String get coffee => 'Coffee';

  @override
  String get alcohol => 'Alcohol';

  @override
  String get craving => 'Craving';

  @override
  String get other => 'Other';

  @override
  String get intensityLevel => 'Intensity level';

  @override
  String get mild => 'Mild';

  @override
  String get intense => 'Intense';

  @override
  String get veryIntense => 'Very intense';

  @override
  String get pleaseSelectLocation => 'Please select your location';

  @override
  String get pleaseSelectTrigger => 'Please select what triggered your craving';

  @override
  String get pleaseSelectIntensity => 'Please select the intensity level';

  @override
  String get whatsTheReason => 'What\'s the reason?';

  @override
  String get anxiety => 'Anxiety';

  @override
  String get pleaseSelectReason => 'Please select a reason';

  @override
  String get howDoYouFeel => 'How do you feel? What could you have done differently?';

  @override
  String get didYouResist => 'Did you resist?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get howMuchDidYouSmoke => 'How much did you smoke?';

  @override
  String get oneOrLess => '1 or less';

  @override
  String get twoToFive => '2-5';

  @override
  String get moreThanFive => 'More than 5';

  @override
  String get pleaseSelectAmount => 'Please select how much you smoked';

  @override
  String get howLongDidItLast => 'How long did it last?';

  @override
  String get lessThan5min => 'Less than 5 min';

  @override
  String get fiveToFifteenMin => '5-15 min';

  @override
  String get moreThan15min => 'More than 15 min';

  @override
  String get pleaseSelectDuration => 'Please select how long it lasted';

  @override
  String get selectCurrency => 'Select your currency';

  @override
  String get selectCurrencySubtitle => 'Choose the currency for financial calculations';

  @override
  String get preselectedCurrency => 'We\'ve preselected your local currency. You can change it if necessary.';

  @override
  String get pleaseCompleteAllFields => 'Please complete all required fields to continue';

  @override
  String get understood => 'Understood';

  @override
  String get commonPrices => 'Common pack prices';

  @override
  String get refresh => 'Refresh';

  @override
  String get errorLoadingNotifications => 'Error loading notifications';

  @override
  String get noNotificationsYet => 'No notifications yet!';

  @override
  String get emptyNotificationsDescription => 'Continue using the app to receive motivational messages and achievements.';

  @override
  String get motivationalMessage => 'Motivational Message';

  @override
  String claimReward(int xp) {
    return 'Claim $xp XP';
  }

  @override
  String rewardClaimed(int xp) {
    return 'Reward claimed: $xp XP';
  }

  @override
  String get dailyMotivation => 'Daily Motivation';

  @override
  String get dailyMotivationDescription => 'Your personalized daily motivation is here. Open to get your XP reward!';

  @override
  String get retry => 'Retry';

  @override
  String get cravingResistedRecorded => 'Craving resisted successfully recorded!';

  @override
  String get cravingRecorded => 'Craving successfully recorded!';

  @override
  String get errorSavingCraving => 'Error saving craving. Tap to retry.';

  @override
  String get recordSaved => 'Record successfully saved!';

  @override
  String get tapToRetry => 'Tap to retry';

  @override
  String get syncError => 'Sync error';

  @override
  String get loading => 'Laden...';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get noRecoveriesFound => 'No health recoveries found';

  @override
  String get noRecentRecoveries => 'No recent health recoveries to display';

  @override
  String get viewAllRecoveries => 'View All Health Recoveries';

  @override
  String get healthRecovery => 'Health Recovery';

  @override
  String get seeAll => 'See all';

  @override
  String get achieved => 'Achieved';

  @override
  String get progress => 'Progress';

  @override
  String daysToAchieve(int days) {
    return '$days days to achieve';
  }

  @override
  String daysRemaining(int days) {
    return '$days days remaining';
  }

  @override
  String achievedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Achieved on $dateString';
  }

  @override
  String daysSmokeFree(int days) {
    return '$days days smoke-free';
  }

  @override
  String get keepGoing => 'Keep Going!';

  @override
  String get encouragementMessage => 'You\'re making great progress. Each day without smoking brings you closer to achieving this health milestone.';

  @override
  String get recoveryAchievedMessage => 'Your body has already recovered in this area. Keep up the good work to maintain and improve your health even further.';

  @override
  String get scienceBehindIt => 'The Science Behind It';

  @override
  String get generalHealthScienceInfo => 'When you stop smoking, your body begins a series of healing processes. These start within minutes of your last cigarette and continue for years, gradually restoring your health to that of a non-smoker.';

  @override
  String get tasteScienceInfo => 'When you smoke, chemicals in tobacco damage taste buds and reduce your ability to taste flavors. After just a few days without smoking, these taste receptors begin to heal, allowing you to experience more flavors and enjoy food more fully.';

  @override
  String get smellScienceInfo => 'Smoking damages the olfactory nerves that transmit scent information to your brain. Within days of quitting, these nerves begin to recover, gradually improving your sense of smell and allowing you to detect more subtle scents.';

  @override
  String get bloodOxygenScienceInfo => 'Carbon monoxide from cigarettes binds to hemoglobin in your blood, reducing its ability to carry oxygen. Within 12-24 hours after quitting, carbon monoxide levels drop dramatically, allowing your blood to carry oxygen more effectively.';

  @override
  String get carbonMonoxideScienceInfo => 'Cigarette smoke contains carbon monoxide, which displaces oxygen in your blood. Within 12 hours of quitting, carbon monoxide levels return to normal, and your body\'s oxygen levels increase significantly.';

  @override
  String get nicotineScienceInfo => 'Nicotine has a half-life of about 2 hours, meaning it takes approximately 72 hours (3 days) for all nicotine to be eliminated from your body. Once nicotine is gone, physical withdrawal symptoms begin to decrease.';

  @override
  String get improvedBreathingScienceInfo => 'After 7 days without smoking, lung function begins to improve as inflammation decreases and the lungs start to clear accumulated mucus. You\'ll notice less coughing and easier breathing, especially during physical activity.';

  @override
  String get improvedCirculationScienceInfo => 'After two weeks of not smoking, your circulation improves significantly. Blood vessels dilate, blood pressure normalizes, and more oxygen reaches your muscles and organs, making physical activity easier and less strenuous.';

  @override
  String get decreasedCoughingScienceInfo => 'One month after quitting, the cilia (tiny hair-like structures) in your lungs begin to regrow. These help clean your lungs and reduce infections. Your coughing and shortness of breath continue to decrease.';

  @override
  String get lungCiliaScienceInfo => 'After 3 months without smoking, your lung function can improve by up to 30%. The cilia in your lungs have largely regrown, improving your lungs\' ability to clean themselves, fight infection, and reduce mucus.';

  @override
  String get reducedHeartDiseaseRiskScienceInfo => 'After one year without smoking, your risk of coronary heart disease decreases to about half that of a smoker. Your heart function continues to improve as blood vessels heal and circulation enhances.';

  @override
  String get viewHealthRecoveries => 'View Health Recoveries';

  @override
  String get recoveryNotFound => 'Health recovery not found';

  @override
  String get trackYourHealthJourney => 'Track Your Health Journey';

  @override
  String get healthRecoveryDescription => 'See how your body heals after quitting smoking';

  @override
  String get somethingWentWrong => 'Something went wrong, please try again';

  @override
  String get profileInformation => 'Profile Information';

  @override
  String get editProfileDescription => 'Update your profile information below.';

  @override
  String get enterName => 'Enter your name';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get registerFirstCigarette => 'Register your first cigarette to see health recovery';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get resetLinkSent => 'Reset link sent!';

  @override
  String get checkEmailInstructions => 'Check your email for instructions to reset your password.';

  @override
  String get backToLogin => 'Back to login';

  @override
  String get forgotPasswordInstructions => 'Enter your email address and we\'ll send you instructions to reset your password.';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get createAccount => 'Create Account';

  @override
  String get fillInformation => 'Fill in your information to create an account';

  @override
  String get name => 'Name';

  @override
  String get nameRequired => 'Please enter your name';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get termsConditionsAgree => 'I agree to the Terms and Conditions';

  @override
  String get termsConditionsRequired => 'Please accept the Terms and Conditions to continue';

  @override
  String get alreadyAccount => 'Already have an account?';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get changePasswordDescription => 'Enter your current password and a new password to update your access credentials.';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully';

  @override
  String get forgotPasswordTitle => 'Forgot your password?';

  @override
  String get forgotPasswordSubtitle => 'We can send you a link to reset your password via email.';

  @override
  String get deleteAccountWarningTitle => 'This Action Cannot Be Undone';

  @override
  String get deleteAccountWarning => 'All your data, including tracking history, achievements, and settings will be permanently deleted. This action cannot be reversed.';

  @override
  String get confirmDeleteAccount => 'I understand this is permanent';

  @override
  String get confirmDeleteAccountSubtitle => 'I understand that all my data will be permanently deleted and cannot be recovered.';

  @override
  String get confirmDeleteRequired => 'Please confirm that you understand this action is permanent.';

  @override
  String get accountDeleted => 'Your account has been deleted successfully.';

  @override
  String get changeDate => 'Change date';

  @override
  String get selectDate => 'Select date';

  @override
  String get clearDate => 'Clear date';

  @override
  String get suggestedDates => 'Suggested dates';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get oneWeekAgo => 'One week ago';

  @override
  String get twoWeeksAgo => 'Two weeks ago';

  @override
  String get oneMonthAgo => 'One month ago';

  @override
  String get feedbackTitle => 'We value your feedback';

  @override
  String get skip => 'Skip';

  @override
  String get howIsYourExperience => 'How\'s your experience?';

  @override
  String get enjoyingApp => 'Are you enjoying the app?';

  @override
  String get notReally => 'Not really';

  @override
  String get yesImEnjoying => 'Yes, I\'m enjoying it!';

  @override
  String get yesILikeIt => 'Yes, I like it!';

  @override
  String get rateApp => 'How would you rate the app?';

  @override
  String get howWouldYouRateApp => 'How would you rate our app?';

  @override
  String get yourOpinionMatters => 'Your opinion matters to us';

  @override
  String get weAreConstantlyImproving => 'We are constantly improving our app based on user feedback';

  @override
  String get later => 'Later';

  @override
  String get tellUsIssues => 'Tell us what\'s not good';

  @override
  String get helpUsImprove => 'Help us improve by telling us what we can do better:';

  @override
  String get feedbackCategory => 'Feedback category';

  @override
  String get interface => 'Interface';

  @override
  String get features => 'Features';

  @override
  String get performance => 'Performance';

  @override
  String get statisticsAccuracy => 'Statistics Accuracy';

  @override
  String get accuracyOfStatistics => 'Accuracy of statistics';

  @override
  String get yourFeedback => 'Your feedback';

  @override
  String get describeProblem => 'Describe what we can improve...';

  @override
  String get describeWhatToImprove => 'Describe what we could improve...';

  @override
  String get whatCouldBeBetter => 'What could be better?';

  @override
  String get sendFeedback => 'Send feedback';

  @override
  String get thankYouForFeedback => 'We appreciate your feedback!';

  @override
  String get gladYouLikeIt => 'We\'re glad you like it!';

  @override
  String get wouldYouRateOnStore => 'Would you rate us on the app store?';

  @override
  String get rateAppStore => 'Would you like to rate the app in the store?';

  @override
  String get alreadyRated => 'I already rated';

  @override
  String get rateNow => 'Rate now';

  @override
  String get feedbackError => 'Oops, something went wrong';

  @override
  String get couldNotSaveFeedback => 'Could not save your feedback';

  @override
  String get understand => 'I understand';

  @override
  String get stayInformed => 'Stay Informed';

  @override
  String get receiveTimelyCues => 'Receive timely cues and important information';

  @override
  String get importantReminders => 'IMPORTANT REMINDERS FOR YOUR JOURNEY';

  @override
  String get notificationsHelp => 'Notifications provide timely reminders, motivation, and important milestone alerts to help you stay on track with your goal.';

  @override
  String get allowNotifications => 'Allow Notifications';

  @override
  String get notificationsEnabled => 'Notifications enabled successfully!';

  @override
  String get notificationPermissionFailed => 'There was a problem enabling notifications';

  @override
  String get requesting => 'Requesting...';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get onboardingLoadError => 'Error loading onboarding';

  @override
  String get unknownError => 'Unknown error';

  @override
  String todayAt(String time) {
    return 'Today at $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Yesterday at $time';
  }

  @override
  String dayOfWeekAt(String weekday, String time) {
    return '$weekday at $time';
  }

  @override
  String dateTimeFormat(String day, String month, String year, String time) {
    return '$day/$month/$year at $time';
  }

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get errorUserNotAuthenticated => 'Error: User not authenticated';

  @override
  String get registeringCravingResisted => 'Registering resisted craving...';

  @override
  String get registeringCraving => 'Registering craving...';

  @override
  String get userNotAuthenticated => 'Not authenticated';
}
