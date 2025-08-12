// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get textSeparator => ' | ';

  @override
  String get termsOfServiceUrl => 'https://nicotina.ai/legal/terms-of-service';

  @override
  String get privacyPolicyUrl => 'https://nicotina.ai/legal/privacy-policy';

  @override
  String get incompleteOnboarding => 'Incorporación Incompleta';

  @override
  String get completeAllStepsMessage => 'Por favor, complete todos los pasos antes de continuar.';

  @override
  String get ok => 'OK';

  @override
  String get days => 'días';

  @override
  String get welcomeToApp => 'Bienvenido a NicotinaAI';

  @override
  String get selectLanguage => 'Selecciona tu idioma preferido';

  @override
  String get continueButton => 'Continuar';

  @override
  String get achievementFirstStep => 'Primer Paso';

  @override
  String get achievementFirstStepDescription => 'Completar el proceso de incorporación';

  @override
  String get achievementOneDayWonder => 'Maravilla de Un Día';

  @override
  String get achievementOneDayWonderDescription => 'Permanecer sin fumar durante 1 día';

  @override
  String get achievementWeekWarrior => 'Guerrero Semanal';

  @override
  String get achievementWeekWarriorDescription => 'Permanecer sin fumar durante 7 días';

  @override
  String get achievementMonthMaster => 'Maestro Mensual';

  @override
  String get achievementMonthMasterDescription => 'Permanecer sin fumar durante 30 días';

  @override
  String get achievementMoneyMindful => 'Consciente del Dinero';

  @override
  String get achievementMoneyMindfulDescription => 'Ahorrar \$50 al no fumar';

  @override
  String get achievementCenturion => 'Centurión';

  @override
  String get achievementCenturionDescription => 'Ahorrar \$100 al no fumar';

  @override
  String get achievementCravingCrusher => 'Aplastador de Antojos';

  @override
  String get achievementCravingCrusherDescription => 'Resistir con éxito 10 antojos';

  @override
  String get loading => 'Cargando...';

  @override
  String get appName => 'NicotinaAI';

  @override
  String get pageNotFound => 'Página no encontrada';

  @override
  String get motivationalMessage => '¡Sigue adelante! ¡Lo estás haciendo genial!';

  @override
  String get helpScreenTitle => '¿Cómo podemos ayudarte?';

  @override
  String get selectAllInterests => 'Seleccione todas las opciones que le interesen';

  @override
  String get helpScreenExplanation => 'Ofrecemos diferentes recursos para apoyar tu viaje. Selecciona todo lo que creas que podría ayudar.';

  @override
  String get dailyTips => 'Consejos diarios';

  @override
  String get dailyTipsDescription => 'Recibe consejos prácticos todos los días para apoyar tu viaje';

  @override
  String get customReminders => 'Recordatorios personalizados';

  @override
  String get customRemindersDescription => 'Notificaciones para mantenerte motivado y en el camino correcto';

  @override
  String get progressMonitoring => 'Monitoreo de progreso';

  @override
  String get progressMonitoringDescription => 'Sigue visualmente tu progreso a lo largo del tiempo';

  @override
  String get supportCommunity => 'Comunidad de apoyo';

  @override
  String get supportCommunityDescription => 'Conéctate con otros en un viaje similar';

  @override
  String get cigaretteAlternatives => 'Alternativas al cigarrillo';

  @override
  String get cigaretteAlternativesDescription => 'Sugerencias de actividades y productos para reemplazar el hábito';

  @override
  String get savingsCalculator => 'Calculadora de Ahorros';

  @override
  String get savingsCalculatorDescription => 'Ve cuánto dinero estás ahorrando al reducir o dejar de fumar';

  @override
  String get modifyPreferencesAnytime => 'Puedes modificar estas preferencias en cualquier momento en la configuración de la aplicación.';

  @override
  String get personalizeScreenTitle => 'When do you usually smoke the most?';

  @override
  String get personalizeScreenSubtitle => 'Select the times when you feel the most urge to smoke';

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
    return '$days días sin fumar';
  }

  @override
  String homeGreeting(String name) {
    return 'Hola, $name';
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
  String get homeMinutesLifeGained => 'Minutos de vida ganados';

  @override
  String get homeLungCapacity => 'Capacidad pulmonar';

  @override
  String get homeNextMilestone => 'Próximo hito';

  @override
  String homeNextMilestoneDescription(int days) {
    return 'A $days días de tu próximo logro de salud';
  }

  @override
  String get homeRecentAchievements => 'Logros recientes';

  @override
  String get homeSeeAll => 'Ver todos';

  @override
  String get homeFirstDay => 'Primer día';

  @override
  String get homeFirstDayDescription => '¡Completaste tu primer día sin fumar!';

  @override
  String get homeOvercoming => 'Superación';

  @override
  String get homeOvercomingDescription => '3 días completos sin cigarrillos';

  @override
  String get homePersistence => 'Persistencia';

  @override
  String get homePersistenceDescription => 'Una semana entera sin fumar';

  @override
  String get homeTodayStats => 'Estadísticas de hoy';

  @override
  String get homeCravingsResisted => 'Antojos resistidos hoy';

  @override
  String get homeMinutesGainedToday => 'Minutos ganados hoy';

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
  String get achievementUnlocked => 'Achievement Unlocked!';

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
  String get achievementImprovedCirculationDescription => 'Normalized oxygen levels';

  @override
  String get achievementInitialSavings => 'Primeros ahorros';

  @override
  String get achievementInitialSavingsDescription => 'Has ahorrado tus primeros 25 al no fumar';

  @override
  String get achievementTwoWeeks => 'Two Weeks';

  @override
  String get achievementTwoWeeksDescription => 'Two full weeks without smoking!';

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
  String get achievementOneMonthDescription => 'A full month without smoking!';

  @override
  String get achievementNewHabitExercise => 'New Habit: Exercise';

  @override
  String get achievementNewHabitExerciseDescription => 'Record 5 days of exercise';

  @override
  String percentCompleted(int percent) {
    return '$percent% completed';
  }

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get loginToContinue => 'Login to continue';

  @override
  String get email => 'Correo electrónico';

  @override
  String get emailHint => 'example@email.com';

  @override
  String get password => 'Contraseña';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot my password';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get register => 'Registro';

  @override
  String get emailRequired => 'El correo electrónico es obligatorio';

  @override
  String get emailInvalid => 'Por favor introduzca un correo electrónico válido';

  @override
  String get passwordRequired => 'La contraseña es obligatoria';

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
  String get changeLanguage => 'Change the app language';

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
  String get changePassword => 'Change your login password';

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
  String get logoutFromAccount => 'Log out from your account';

  @override
  String get logoutTitle => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to log out of your account?';

  @override
  String get about => 'About';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get readPrivacyPolicy => 'Read our privacy policy';

  @override
  String get termsOfUse => 'Términos de uso';

  @override
  String get viewTermsOfUse => 'View the app\'s terms of use';

  @override
  String get aboutApp => 'About the App';

  @override
  String get appInfo => 'App version and information';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Guardar';

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
  String get moderate => 'Moderado';

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
  String get priceHelp => 'This information helps us show you how much you\'ll save by reducing or quitting smoking.';

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
  String get productTypeHelp => 'Different products contain different amounts of nicotine and may require different strategies for reduction or cessation.';

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
  String get establishDeadline => 'Set a deadline that seems achievable to you';

  @override
  String get timelineExplanation => 'A realistic timeline increases your chances of success. Choose a timeframe you\'re comfortable with.';

  @override
  String get sevenDays => '7 days';

  @override
  String get sevenDaysDescription => 'I want quick results and I\'m committed';

  @override
  String get fourteenDays => '14 days';

  @override
  String get fourteenDaysDescription => 'A balanced timeframe for changing habits';

  @override
  String get thirtyDays => '30 days';

  @override
  String get thirtyDaysDescription => 'A month for gradual and sustainable change';

  @override
  String get noDeadline => 'No defined deadline';

  @override
  String get noDeadlineDescription => 'I prefer to go at my own pace';

  @override
  String get timelineHelp => 'Don\'t worry if you don\'t achieve your goal exactly within the timeframe. What matters is continuous progress.';

  @override
  String get pleaseSelectTimeline => 'Please select a timeline';

  @override
  String get identifyChallenge => 'Identifying your main challenge helps us provide better support';

  @override
  String get challengeExplanation => 'Understanding what makes quitting cigarettes difficult is the first step to overcoming that obstacle.';

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
  String get dependenceDescription => 'I experience physical symptoms when I\'m without smoking';

  @override
  String get challengeHelp => 'Your answers help us personalize advice and strategies that are more effective for your specific case.';

  @override
  String get pleaseSelectChallenge => 'Please select a challenge';

  @override
  String get locationsQuestion => 'Where do you usually smoke?';

  @override
  String get selectCommonPlaces => 'Select the places where you most often smoke';

  @override
  String get locationsExplanation => 'Knowing your usual places helps us identify patterns and create specific strategies.';

  @override
  String get atHome => 'At home';

  @override
  String get homeDetails => 'Balcony, living room, office';

  @override
  String get atWork => 'At work/school';

  @override
  String get workDetails => 'During breaks or pauses';

  @override
  String get inCar => 'In the car/transport';

  @override
  String get carDetails => 'During trips';

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
  String get locationsHelp => 'Identifying the most common places helps to avoid triggers and create strategies to change habits.';

  @override
  String get allDone => 'All Done!';

  @override
  String get personalizedJourney => 'Your personalized journey begins now';

  @override
  String get startMyJourney => 'Start My Journey';

  @override
  String get congratulations => '¡Felicidades por tu progreso!';

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
  String get importantAchievements => 'Logros importantes';

  @override
  String get achievementsDescription => 'Cada día sin fumar es un logro. Tu viaje está lleno de pequeñas victorias que van sumando hacia una vida más saludable.';

  @override
  String get supportWhenNeeded => 'Apoyo';

  @override
  String get supportDescription => 'Tips and strategies for difficult moments';

  @override
  String get guaranteedResults => 'Guaranteed results';

  @override
  String get resultsDescription => 'With our science-based technology';

  @override
  String loadingError(String error) {
    return 'Error: $error';
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
  String get listView => 'List view';

  @override
  String get gridView => 'Grid view';

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
  String get registerCraving => 'Registrar antojo';

  @override
  String get registerCravingSubtitle => 'Registro de antojos de fumar';

  @override
  String get newRecord => 'Nuevo registro';

  @override
  String get newRecordSubtitle => 'Registro de episodio de fumar';

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
  String get whatTriggeredCraving => '¿Qué desencadenó tu antojo?';

  @override
  String get stress => 'Estrés';

  @override
  String get boredom => 'Aburrimiento';

  @override
  String get socialSituation => 'Situación social';

  @override
  String get afterMeal => 'Después de comer';

  @override
  String get coffee => 'Café';

  @override
  String get alcohol => 'Alcohol';

  @override
  String get craving => 'Antojo fuerte';

  @override
  String get other => 'Otro';

  @override
  String get intensityLevel => 'Intensity level';

  @override
  String get mild => 'Leve';

  @override
  String get intense => 'Intenso';

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
  String get anxiety => 'Ansiedad';

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
  String get howMuchDidYouSmoke => '¿Cuánto fumaste?';

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
  String get preselectedCurrency => 'We\'ve preselected your local currency. You can change it if needed.';

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
  String claimReward(int xp) {
    return 'Claim reward: $xp XP';
  }

  @override
  String rewardClaimed(int xp) {
    return 'Reward claimed: $xp XP';
  }

  @override
  String get dailyMotivation => 'Daily Motivation';

  @override
  String get dailyMotivationDescription => 'Your personalized daily motivation is here. Open it to get your XP reward!';

  @override
  String get retry => 'Retry';

  @override
  String get cravingResistedRecorded => 'Craving resistance successfully recorded!';

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
  String get tryAgain => 'Try again';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get noRecoveriesFound => 'No health recoveries found';

  @override
  String get noRecentRecoveries => 'No recent health recoveries to show';

  @override
  String get viewAllRecoveries => 'View All Health Recoveries';

  @override
  String get healthRecovery => 'Recuperación de salud';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get achieved => 'Achieved';

  @override
  String get progress => 'Progress';

  @override
  String daysSmokeFree(int days) {
    return '$days days smoke free';
  }

  @override
  String daysToAchieve(int days) {
    return 'Days to achieve: $days';
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
  String get keepGoing => 'Keep going!';

  @override
  String get encouragementMessage => 'You\'re making great progress. Each day without smoking brings you closer to reaching this health milestone.';

  @override
  String get recoveryAchievedMessage => 'Your body has already recovered in this area. Keep up the good work to maintain and further improve your health.';

  @override
  String get scienceBehindIt => 'The Science Behind It';

  @override
  String get generalHealthScienceInfo => 'When you quit smoking, your body begins a series of healing processes. These start minutes after your last cigarette and continue for years, gradually restoring your health to that of a non-smoker.';

  @override
  String get tasteScienceInfo => 'When you smoke, chemicals in tobacco damage taste buds and reduce your ability to taste. After just a few days without smoking, these taste receptors begin to heal, allowing you to experience more flavors and enjoy food more.';

  @override
  String get smellScienceInfo => 'Smoking damages the olfactory nerves that transmit smell information to the brain. Within a few days after quitting, these nerves begin to recover, gradually improving your sense of smell and allowing you to detect more subtle odors.';

  @override
  String get bloodOxygenScienceInfo => 'Carbon monoxide from cigarettes binds to hemoglobin in your blood, reducing its ability to carry oxygen. Within 12-24 hours after quitting, carbon monoxide levels drop dramatically, allowing your blood to carry oxygen more effectively.';

  @override
  String get carbonMonoxideScienceInfo => 'Cigarette smoke contains carbon monoxide, which displaces oxygen in your blood. Within 12 hours after quitting, carbon monoxide levels return to normal, and oxygen levels in your body significantly increase.';

  @override
  String get nicotineScienceInfo => 'Nicotine has a half-life of approximately 2 hours, meaning it takes about 72 hours (3 days) for all nicotine to be eliminated from your body. Once nicotine is gone, physical withdrawal symptoms begin to diminish.';

  @override
  String get improvedBreathingScienceInfo => 'After 7 days without smoking, lung function begins to improve as inflammation decreases and lungs begin to clear accumulated mucus. You\'ll notice less coughing and easier breathing, especially during physical activity.';

  @override
  String get improvedCirculationScienceInfo => 'After two weeks without smoking, your circulation significantly improves. Blood vessels dilate, blood pressure normalizes, and more oxygen reaches your muscles and organs, making physical activity easier and less strenuous.';

  @override
  String get decreasedCoughingScienceInfo => 'One month after quitting, the cilia (tiny hair-like structures) in your lungs begin to regrow. These help clean your lungs and reduce infections. Your cough and shortness of breath continue to decrease.';

  @override
  String get lungCiliaScienceInfo => 'After 3 months without smoking, your lung function can improve by up to 30%. The cilia in your lungs have largely regrown, improving your lungs\' ability to clean themselves, fight infection, and reduce mucus.';

  @override
  String get reducedHeartDiseaseRiskScienceInfo => 'After a year without smoking, your risk of coronary heart disease decreases to about half that of a smoker. Your heart function continues to improve as blood vessels heal and circulation improves.';

  @override
  String get viewHealthRecoveries => 'View Health Recoveries';

  @override
  String get recoveryNotFound => 'Health recovery not found';

  @override
  String get trackYourHealthJourney => 'Track Your Health Journey';

  @override
  String get healthRecoveryDescription => 'See how your body recovers after quitting smoking';

  @override
  String get somethingWentWrong => 'Something went wrong, please try again';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get registerFirstCigarette => 'Registra tu información para comenzar a ver tu progreso';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get feedbackTitle => 'We value your feedback';

  @override
  String get skip => 'Skip';

  @override
  String get howIsYourExperience => 'How is your experience?';

  @override
  String get enjoyingApp => 'Are you enjoying the app?';

  @override
  String get notReally => 'Not really';

  @override
  String get yesImEnjoying => 'Yes, I\'m enjoying it!';

  @override
  String get yesILikeIt => 'Yes, I like it!';

  @override
  String get rateApp => 'Would you rate the app?';

  @override
  String get howWouldYouRateApp => 'How would you rate our app?';

  @override
  String get yourOpinionMatters => 'Your opinion matters to us';

  @override
  String get weAreConstantlyImproving => 'We are constantly improving our app based on user feedback';

  @override
  String get later => 'Later';

  @override
  String get tellUsIssues => 'Tell us what\'s not right';

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
  String get thankYouForFeedback => 'Thank you for your feedback!';

  @override
  String get gladYouLikeIt => 'We\'re glad you like it!';

  @override
  String get wouldYouRateOnStore => 'Would you rate our app on the store?';

  @override
  String get rateAppStore => 'Would you like to rate the app on the store?';

  @override
  String get alreadyRated => 'I\'ve already rated';

  @override
  String get rateNow => 'Rate now';

  @override
  String get feedbackError => 'Oops, something went wrong';

  @override
  String get couldNotSaveFeedback => 'Could not save your feedback';

  @override
  String get understand => 'I understand';

  @override
  String get onboardingLoadError => 'Error loading onboarding';

  @override
  String get unknownError => 'An unknown error occurred';

  @override
  String get errorUserNotAuthenticated => 'You must be logged in to perform this action';

  @override
  String get userNotAuthenticated => 'You are not logged in';

  @override
  String get registeringCravingResisted => 'Registering craving resisted...';

  @override
  String get registeringCraving => 'Registering craving...';

  @override
  String challengeQuestion(String goalText) {
    return 'What makes it difficult to $goalText?';
  }

  @override
  String personalizedPlanReduce(String timelineText) {
    return 'We\'ve created a personalized plan to help you reduce your cigarette consumption $timelineText. This plan is based on your habits and preferences.';
  }

  @override
  String personalizedPlanQuit(String timelineText) {
    return 'We\'ve created a personalized plan to help you quit smoking $timelineText. This plan is based on your habits and preferences.';
  }

  @override
  String todayAt(String time) {
    return 'Hoy a las $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Ayer a las $time';
  }

  @override
  String dayOfWeekAt(String weekday, String time) {
    return '$weekday a las $time';
  }

  @override
  String dateTimeFormat(String day, String month, String year, String time) {
    return '$day/$month/$year $time';
  }

  @override
  String get monday => 'Lunes';

  @override
  String get tuesday => 'Martes';

  @override
  String get wednesday => 'Miércoles';

  @override
  String get thursday => 'Jueves';

  @override
  String get friday => 'Viernes';

  @override
  String get saturday => 'Sábado';

  @override
  String get sunday => 'Domingo';

  @override
  String get fillInformation => 'Complete sus datos para registrarse';

  @override
  String get name => 'Nombre';

  @override
  String get nameRequired => 'El nombre es obligatorio';

  @override
  String get passwordTooShort => 'La contraseña debe tener al menos 6 caracteres';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get confirmPasswordRequired => 'Confirmar contraseña es obligatorio';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get termsConditionsAgree => 'Acepto los términos y condiciones';

  @override
  String get termsConditionsRequired => 'Debe aceptar los términos y condiciones para continuar';

  @override
  String get alreadyAccount => '¿Ya tienes una cuenta?';

  @override
  String get resetLinkSent => 'Reset link sent';

  @override
  String get checkEmailInstructions => 'Check your email for instructions on how to reset your password';

  @override
  String get forgotPasswordInstructions => 'Enter your email and we\'ll send you instructions to reset your password';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get backToLogin => 'Back to login';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get stayInformed => 'Stay Informed';

  @override
  String get receiveTimelyCues => 'Receive timely cues and reminders to help with your journey';

  @override
  String get importantReminders => 'Important Reminders';

  @override
  String get notificationsHelp => 'Notifications help you stay on track with your goals, provide timely support during difficult moments, and celebrate your achievements.';

  @override
  String get requesting => 'Requesting...';

  @override
  String get allowNotifications => 'Allow Notifications';

  @override
  String get notificationsEnabled => 'Notifications enabled successfully';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get notificationPermissionFailed => 'Notification permission was not granted';

  @override
  String get purchaseError => 'Error processing purchase. Please try again.';
}
