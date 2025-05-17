// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get incompleteOnboarding => 'Onboarding incomplet';

  @override
  String get completeAllStepsMessage => 'Veuillez compléter toutes les étapes d\'onboarding avant de continuer.';

  @override
  String get ok => 'OK';

  @override
  String get days => 'jours';

  @override
  String get helpScreenTitle => 'Comment pouvons-nous vous aider ?';

  @override
  String get selectAllInterests => 'Sélectionnez toutes les options qui vous intéressent';

  @override
  String get helpScreenExplanation => 'Nous proposons différentes ressources pour soutenir votre parcours. Sélectionnez tout ce que vous pensez pouvoir vous aider.';

  @override
  String get dailyTips => 'Conseils quotidiens';

  @override
  String get dailyTipsDescription => 'Recevez des conseils pratiques chaque jour pour soutenir votre parcours';

  @override
  String get customReminders => 'Rappels personnalisés';

  @override
  String get customRemindersDescription => 'Notifications pour vous garder motivé et sur la bonne voie';

  @override
  String get progressMonitoring => 'Suivi de progression';

  @override
  String get progressMonitoringDescription => 'Suivez visuellement votre progression dans le temps';

  @override
  String get supportCommunity => 'Communauté de soutien';

  @override
  String get supportCommunityDescription => 'Connectez-vous avec d\'autres personnes dans un parcours similaire';

  @override
  String get cigaretteAlternatives => 'Alternatives à la cigarette';

  @override
  String get cigaretteAlternativesDescription => 'Suggestions d\'activités et de produits pour remplacer l\'habitude';

  @override
  String get savingsCalculator => 'Calculateur d\'économies';

  @override
  String get savingsCalculatorDescription => 'Découvrez combien d\'argent vous économisez en réduisant ou en arrêtant';

  @override
  String get modifyPreferencesAnytime => 'Vous pouvez modifier ces préférences à tout moment dans les paramètres de l\'application.';

  @override
  String get personalizeScreenTitle => 'Quand fumez-vous généralement plus ?';

  @override
  String get personalizeScreenSubtitle => 'Sélectionnez les moments où vous avez plus envie de fumer';

  @override
  String get afterMeals => 'Après les repas';

  @override
  String get duringWorkBreaks => 'Pendant les pauses au travail';

  @override
  String get inSocialEvents => 'Lors d\'événements sociaux';

  @override
  String get whenStressed => 'Quand je suis stressé(e)';

  @override
  String get withCoffeeOrAlcohol => 'En buvant du café ou de l\'alcool';

  @override
  String get whenBored => 'Quand je m\'ennuie';

  @override
  String homeDaysWithoutSmoking(int days) {
    return '$days jours sans fumer';
  }

  @override
  String homeGreeting(String name) {
    return 'Bonjour, $name! 👋';
  }

  @override
  String get homeHealthRecovery => 'Récupération de la santé';

  @override
  String get homeTaste => 'Goût';

  @override
  String get homeSmell => 'Odorat';

  @override
  String get homeCirculation => 'Circulation';

  @override
  String get homeLungs => 'Poumons';

  @override
  String get homeHeart => 'Cœur';

  @override
  String get homeMinutesLifeGained => 'minutes de vie\ngagnées';

  @override
  String get homeLungCapacity => 'capacité\npulmonaire';

  @override
  String get homeNextMilestone => 'Prochain objectif';

  @override
  String homeNextMilestoneDescription(int days) {
    return 'Dans $days jours : Amélioration de la circulation sanguine';
  }

  @override
  String get homeRecentAchievements => 'Réalisations récentes';

  @override
  String get homeSeeAll => 'Voir tout';

  @override
  String get homeFirstDay => 'Premier jour';

  @override
  String get homeFirstDayDescription => 'Vous avez passé 24 heures sans fumer !';

  @override
  String get homeOvercoming => 'Dépassement';

  @override
  String get homeOvercomingDescription => 'Niveaux de nicotine éliminés du corps';

  @override
  String get homePersistence => 'Persévérance';

  @override
  String get homePersistenceDescription => 'Une semaine entière sans cigarettes !';

  @override
  String get homeTodayStats => 'Statistiques du jour';

  @override
  String get homeCravingsResisted => 'Envies\nrésistées';

  @override
  String get homeMinutesGainedToday => 'Minutes de vie\ngagnées aujourd\'hui';

  @override
  String get achievementCategoryAll => 'Tous';

  @override
  String get achievementCategoryHealth => 'Santé';

  @override
  String get achievementCategoryTime => 'Temps';

  @override
  String get achievementCategorySavings => 'Économies';

  @override
  String get achievementCategoryHabits => 'Habitudes';

  @override
  String get achievementUnlocked => 'Débloqué !';

  @override
  String get achievementInProgress => 'En cours';

  @override
  String get achievementCompleted => 'Complété';

  @override
  String get achievementCurrentProgress => 'Votre progression actuelle';

  @override
  String achievementLevel(int level) {
    return 'Niveau $level';
  }

  @override
  String achievementDaysWithoutSmoking(int days) {
    return '$days jours sans fumer';
  }

  @override
  String achievementNextLevel(String time) {
    return 'Prochain niveau : $time';
  }

  @override
  String get achievementBenefitCO2 => 'CO2 normal';

  @override
  String get achievementBenefitTaste => 'Goût amélioré';

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
  String get welcomeBack => 'Bienvenue';

  @override
  String get loginToContinue => 'Connectez-vous pour continuer';

  @override
  String get email => 'E-mail';

  @override
  String get emailHint => 'exemple@email.com';

  @override
  String get password => 'Mot de passe';

  @override
  String get rememberMe => 'Se souvenir de moi';

  @override
  String get forgotPassword => 'Mot de passe oublié';

  @override
  String get login => 'Connexion';

  @override
  String get noAccount => 'Vous n\'avez pas de compte?';

  @override
  String get register => 'S\'inscrire';

  @override
  String get emailRequired => 'Veuillez entrer votre email';

  @override
  String get emailInvalid => 'Veuillez entrer un email valide';

  @override
  String get passwordRequired => 'Veuillez entrer votre mot de passe';

  @override
  String get settings => 'Paramètres';

  @override
  String get home => 'Accueil';

  @override
  String get achievements => 'Réalisations';

  @override
  String get profile => 'Profil';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get appSettings => 'Paramètres de l\'application';

  @override
  String get notifications => 'Notifications';

  @override
  String get manageNotifications => 'Gérer les notifications';

  @override
  String get language => 'Langue';

  @override
  String get changeLanguage => 'Changer la langue de l\'application';

  @override
  String get theme => 'Thème';

  @override
  String get dark => 'Sombre';

  @override
  String get light => 'Clair';

  @override
  String get system => 'Système';

  @override
  String get habitTracking => 'Suivi des habitudes';

  @override
  String get cigarettesPerDay => 'Cigarettes par jour avant l\'arrêt';

  @override
  String get configureHabits => 'Configurez vos habitudes précédentes';

  @override
  String get packPrice => 'Prix du paquet';

  @override
  String get setPriceForCalculations => 'Définir le prix pour les calculs d\'économies';

  @override
  String get startDate => 'Date de début';

  @override
  String get whenYouQuitSmoking => 'Quand vous avez arrêté de fumer';

  @override
  String get account => 'Compte';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get changePassword => 'Changer votre mot de passe d\'accès';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get permanentlyRemoveAccount => 'Supprimer définitivement votre compte';

  @override
  String get deleteAccountTitle => 'Supprimer le compte';

  @override
  String get deleteAccountConfirmation => 'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible et toutes vos données seront perdues.';

  @override
  String get logout => 'Déconnexion';

  @override
  String get logoutFromAccount => 'Se déconnecter de votre compte';

  @override
  String get logoutTitle => 'Déconnexion';

  @override
  String get logoutConfirmation => 'Êtes-vous sûr de vouloir vous déconnecter de votre compte ?';

  @override
  String get about => 'À propos';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get readPrivacyPolicy => 'Lire notre politique de confidentialité';

  @override
  String get termsOfUse => 'Conditions d\'utilisation';

  @override
  String get viewTermsOfUse => 'Voir les conditions d\'utilisation de l\'application';

  @override
  String get aboutApp => 'À propos de l\'application';

  @override
  String get appInfo => 'Version et informations sur l\'application';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get next => 'Suivant';

  @override
  String get back => 'Retour';

  @override
  String get finish => 'Terminer';

  @override
  String get cigarettesPerDayQuestion => 'Combien de cigarettes fumez-vous par jour ?';

  @override
  String get cigarettesPerDaySubtitle => 'Cela nous aide à comprendre votre niveau de consommation';

  @override
  String get exactNumber => 'Nombre exact : ';

  @override
  String get selectConsumptionLevel => 'Ou sélectionnez votre niveau de consommation :';

  @override
  String get low => 'Faible';

  @override
  String get moderate => 'Modéré';

  @override
  String get high => 'Élevé';

  @override
  String get veryHigh => 'Très élevé';

  @override
  String get upTo5 => 'Jusqu\'à 5 cigarettes par jour';

  @override
  String get sixTo15 => '6 à 15 cigarettes par jour';

  @override
  String get sixteenTo25 => '16 à 25 cigarettes par jour';

  @override
  String get moreThan25 => 'Plus de 25 cigarettes par jour';

  @override
  String get selectConsumptionLevelError => 'Veuillez sélectionner votre niveau de consommation';

  @override
  String get welcomeToNicotinaAI => 'Bienvenue sur NicotinaAI';

  @override
  String get personalAssistant => 'Votre assistant personnel pour arrêter de fumer';

  @override
  String get start => 'Commencer';

  @override
  String get breatheFreedom => 'RESPIREZ LA LIBERTÉ. VOTRE NOUVELLE VIE COMMENCE MAINTENANT.';

  @override
  String get personalizeExperience => 'Personnalisons votre expérience pour vous aider à atteindre vos objectifs d\'arrêt du tabac. Répondez à quelques questions pour commencer.';

  @override
  String get cigarettesPerPackQuestion => 'Combien de cigarettes y a-t-il dans un paquet ?';

  @override
  String get selectStandardAmount => 'Sélectionnez la quantité standard pour vos paquets de cigarettes';

  @override
  String get packSizesInfo => 'Les paquets de cigarettes contiennent généralement 10 ou 20 unités. Sélectionnez la quantité qui correspond aux paquets que vous achetez.';

  @override
  String get tenCigarettes => '10 cigarettes';

  @override
  String get twentyCigarettes => '20 cigarettes';

  @override
  String get smallPack => 'Petit paquet/compact';

  @override
  String get standardPack => 'Paquet standard/traditionnel';

  @override
  String get otherQuantity => 'Autre quantité';

  @override
  String get selectCustomValue => 'Sélectionnez une valeur personnalisée';

  @override
  String get quantity => 'Quantité : ';

  @override
  String get packSizeHelp => 'This information helps us accurately calculate your consumption and the benefits of reducing or quitting smoking.';

  @override
  String get packPriceQuestion => 'Combien coûte un paquet de cigarettes ?';

  @override
  String get helpCalculateFinancial => 'Cela nous aide à calculer vos économies financières';

  @override
  String get enterAveragePrice => 'Entrez le prix moyen que vous payez pour un paquet de cigarettes.';

  @override
  String get priceHelp => 'This information helps us show how much you\'ll save by reducing or quitting smoking.';

  @override
  String get productTypeQuestion => 'Quel type de produit consommez-vous ?';

  @override
  String get selectApplicable => 'Sélectionnez ce qui s\'applique à vous';

  @override
  String get helpPersonalizeStrategy => 'This helps us personalize strategies and recommendations for your specific case.';

  @override
  String get cigaretteOnly => 'Cigarettes traditionnelles uniquement';

  @override
  String get traditionalCigarettes => 'Cigarettes classiques au tabac';

  @override
  String get vapeOnly => 'Cigarette électronique uniquement';

  @override
  String get electronicDevices => 'Appareils de vapotage électroniques';

  @override
  String get both => 'Les deux';

  @override
  String get useBoth => 'J\'utilise à la fois des cigarettes traditionnelles et électroniques';

  @override
  String get productTypeHelp => 'Different products contain different amounts of nicotine and may require distinct strategies for reduction or cessation.';

  @override
  String get pleaseSelectProductType => 'Please select a product type';

  @override
  String get goalQuestion => 'Quel est votre objectif ?';

  @override
  String get selectGoal => 'Sélectionnez ce que vous voulez accomplir';

  @override
  String get goalExplanation => 'Définir un objectif clair est essentiel pour votre réussite. Nous voulons vous aider à atteindre ce que vous désirez.';

  @override
  String get reduceConsumption => 'Réduire la consommation';

  @override
  String get reduceDescription => 'Je veux fumer moins de cigarettes et avoir plus de contrôle sur cette habitude';

  @override
  String get reduce => 'Réduire';

  @override
  String get quitSmoking => 'Arrêter de fumer';

  @override
  String get quitDescription => 'Je veux complètement arrêter les cigarettes et vivre sans tabac';

  @override
  String get quit => 'Arrêter';

  @override
  String get goalHelp => 'We\'ll adapt our resources and recommendations based on your goal. You can modify it later if you change your mind.';

  @override
  String get pleaseSelectGoal => 'Please select a goal';

  @override
  String get timelineQuestionReduce => 'Quand voulez-vous réduire votre consommation ?';

  @override
  String get timelineQuestionQuit => 'Quand voulez-vous arrêter de fumer ?';

  @override
  String get establishDeadline => 'Établissez une échéance qui vous semble réalisable';

  @override
  String get timelineExplanation => 'A realistic timeline increases your chances of success. Choose a deadline that you\'re comfortable with.';

  @override
  String get sevenDays => '7 jours';

  @override
  String get sevenDaysDescription => 'Je veux des résultats rapides et je suis déterminé(e)';

  @override
  String get fourteenDays => '14 jours';

  @override
  String get fourteenDaysDescription => 'Un délai équilibré pour changer d\'habitude';

  @override
  String get thirtyDays => '30 jours';

  @override
  String get thirtyDaysDescription => 'Un mois pour un changement progressif et durable';

  @override
  String get noDeadline => 'Pas d\'échéance fixe';

  @override
  String get noDeadlineDescription => 'Je préfère avancer à mon propre rythme';

  @override
  String get timelineHelp => 'Don\'t worry if you don\'t achieve your goal exactly on schedule. Continuous progress is what matters.';

  @override
  String get pleaseSelectTimeline => 'Please select a timeline';

  @override
  String challengeQuestion(String goalText) {
    return 'Qu\'est-ce qui rend difficile de $goalText pour vous ?';
  }

  @override
  String get identifyChallenge => 'Identifier votre défi principal nous aide à vous fournir un meilleur soutien';

  @override
  String get challengeExplanation => 'Understanding what makes cigarettes hard to quit is the first step in overcoming that obstacle.';

  @override
  String get stressAnxiety => 'Stress et anxiété';

  @override
  String get stressDescription => 'Je fume pour gérer les situations stressantes et l\'anxiété';

  @override
  String get habitStrength => 'Force de l\'habitude';

  @override
  String get habitDescription => 'Fumer fait déjà partie de ma routine quotidienne';

  @override
  String get socialInfluence => 'Influence sociale';

  @override
  String get socialDescription => 'Les personnes autour de moi fument ou m\'encouragent à fumer';

  @override
  String get physicalDependence => 'Dépendance physique';

  @override
  String get dependenceDescription => 'Je ressens des symptômes physiques quand je ne fume pas';

  @override
  String get challengeHelp => 'Your answers help us personalize more effective tips and strategies for your specific case.';

  @override
  String get pleaseSelectChallenge => 'Please select a challenge';

  @override
  String get locationsQuestion => 'Où fumez-vous habituellement ?';

  @override
  String get selectCommonPlaces => 'Sélectionnez les endroits où vous fumez le plus souvent';

  @override
  String get locationsExplanation => 'Knowing your usual locations helps us identify patterns and create specific strategies.';

  @override
  String get atHome => 'À la maison';

  @override
  String get homeDetails => 'Balcon, salon, bureau';

  @override
  String get atWork => 'Au travail/à l\'école';

  @override
  String get workDetails => 'Pendant les pauses';

  @override
  String get inCar => 'En voiture/transport';

  @override
  String get carDetails => 'Pendant les déplacements';

  @override
  String get socialEvents => 'Lors d\'événements sociaux';

  @override
  String get socialDetails => 'Bars, fêtes, restaurants';

  @override
  String get outdoors => 'À l\'extérieur';

  @override
  String get outdoorsDetails => 'Parcs, trottoirs, espaces extérieurs';

  @override
  String get otherPlaces => 'Autres endroits';

  @override
  String get otherPlacesDetails => 'Quand je suis anxieux(se), peu importe l\'endroit';

  @override
  String get locationsHelp => 'Identifying the most common locations helps avoid triggers and create strategies for habit change.';

  @override
  String get continueButton => 'Continuer';

  @override
  String get allDone => 'Terminé !';

  @override
  String get personalizedJourney => 'Votre parcours personnalisé commence maintenant';

  @override
  String get startMyJourney => 'Commencer mon parcours';

  @override
  String get congratulations => 'Félicitations pour avoir franchi la première étape !';

  @override
  String personalizedPlanReduce(String timelineText) {
    return 'Nous avons créé un plan personnalisé basé sur vos réponses pour vous aider à réduire votre consommation $timelineText.';
  }

  @override
  String personalizedPlanQuit(String timelineText) {
    return 'Nous avons créé un plan personnalisé basé sur vos réponses pour vous aider à arrêter de fumer $timelineText.';
  }

  @override
  String get yourPersonalizedSummary => 'Votre résumé personnalisé';

  @override
  String get dailyConsumption => 'Consommation quotidienne';

  @override
  String cigarettesPerDayValue(int count) {
    return '$count cigarettes par jour';
  }

  @override
  String get potentialMonthlySavings => 'Économies mensuelles potentielles';

  @override
  String get yourGoal => 'Votre objectif';

  @override
  String get mainChallenge => 'Votre défi principal';

  @override
  String get personalized => 'Suivi personnalisé';

  @override
  String get personalizedDescription => 'Suivez votre progression en fonction de vos habitudes';

  @override
  String get importantAchievements => 'Réalisations importantes';

  @override
  String get achievementsDescription => 'Célébrez chaque étape de votre parcours';

  @override
  String get supportWhenNeeded => 'Soutien quand vous en avez besoin';

  @override
  String get supportDescription => 'Conseils et stratégies pour les moments difficiles';

  @override
  String get guaranteedResults => 'Résultats garantis';

  @override
  String get resultsDescription => 'Avec notre technologie basée sur la science';

  @override
  String loadingError(String error) {
    return 'Erreur lors du chargement : $error';
  }

  @override
  String get developer => 'Développeur';

  @override
  String get developerMode => 'Mode développeur';

  @override
  String get enableDebugging => 'Activer le débogage détaillé et le suivi';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get viewDetailedTracking => 'Voir le tableau de bord de suivi détaillé';

  @override
  String get currency => 'Devise';

  @override
  String get changeCurrency => 'Changer de devise';

  @override
  String get setCurrencyForCalculations => 'Définir la devise pour les calculs d\'économies';

  @override
  String get search => 'Rechercher';

  @override
  String get noResults => 'Aucun résultat trouvé';

  @override
  String get listView => 'Vue liste';

  @override
  String get gridView => 'Vue grille';

  @override
  String get atYourOwnPace => 'à votre propre rythme';

  @override
  String get nextSevenDays => 'dans les 7 prochains jours';

  @override
  String get nextTwoWeeks => 'dans les 2 prochaines semaines';

  @override
  String get nextMonth => 'dans le mois à venir';

  @override
  String get notSpecified => 'Non spécifié';

  @override
  String get registerCraving => 'Enregistrer une envie';

  @override
  String get registerCravingSubtitle => 'Suivez quand vous ressentez des pulsions';

  @override
  String get newRecord => 'Nouvel enregistrement';

  @override
  String get newRecordSubtitle => 'Enregistrer quand vous fumez';

  @override
  String get whereAreYou => 'Où êtes-vous?';

  @override
  String get work => 'Travail';

  @override
  String get car => 'Voiture';

  @override
  String get restaurant => 'Restaurant';

  @override
  String get bar => 'Bar';

  @override
  String get street => 'Rue';

  @override
  String get park => 'Parc';

  @override
  String get others => 'Autres';

  @override
  String get notes => 'Notes (optionnel)';

  @override
  String get howAreYouFeeling => 'Comment vous sentez-vous?';

  @override
  String get whatTriggeredCraving => 'Qu\'est-ce qui a déclenché votre envie?';

  @override
  String get stress => 'Stress';

  @override
  String get boredom => 'Ennui';

  @override
  String get socialSituation => 'Situation sociale';

  @override
  String get afterMeal => 'Après un repas';

  @override
  String get coffee => 'Café';

  @override
  String get alcohol => 'Alcool';

  @override
  String get craving => 'Envie';

  @override
  String get other => 'Autre';

  @override
  String get intensityLevel => 'Niveau d\'intensité';

  @override
  String get mild => 'Légère';

  @override
  String get intense => 'Intense';

  @override
  String get veryIntense => 'Très intense';

  @override
  String get pleaseSelectLocation => 'Veuillez sélectionner votre emplacement';

  @override
  String get pleaseSelectTrigger => 'Veuillez sélectionner ce qui a déclenché votre envie';

  @override
  String get pleaseSelectIntensity => 'Veuillez sélectionner le niveau d\'intensité';

  @override
  String get whatsTheReason => 'Quelle est la raison?';

  @override
  String get anxiety => 'Anxiété';

  @override
  String get pleaseSelectReason => 'Veuillez sélectionner une raison';

  @override
  String get howDoYouFeel => 'Comment vous sentez-vous? Qu\'auriez-vous pu faire différemment?';

  @override
  String get didYouResist => 'Avez-vous résisté?';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get howMuchDidYouSmoke => 'Combien avez-vous fumé?';

  @override
  String get oneOrLess => '1 ou moins';

  @override
  String get twoToFive => '2-5';

  @override
  String get moreThanFive => 'Plus de 5';

  @override
  String get pleaseSelectAmount => 'Veuillez sélectionner combien vous avez fumé';

  @override
  String get howLongDidItLast => 'Combien de temps cela a-t-il duré?';

  @override
  String get lessThan5min => 'Moins de 5 min';

  @override
  String get fiveToFifteenMin => '5-15 min';

  @override
  String get moreThan15min => 'Plus de 15 min';

  @override
  String get pleaseSelectDuration => 'Veuillez sélectionner la durée';

  @override
  String get selectCurrency => 'Sélectionnez votre devise';

  @override
  String get selectCurrencySubtitle => 'Choisissez la devise pour les calculs financiers';

  @override
  String get preselectedCurrency => 'Nous avons présélectionné votre devise locale. Vous pouvez la modifier si nécessaire.';

  @override
  String get pleaseCompleteAllFields => 'Veuillez compléter tous les champs obligatoires pour continuer';

  @override
  String get understood => 'Compris';

  @override
  String get commonPrices => 'Prix courants des paquets';

  @override
  String get refresh => 'Actualiser';

  @override
  String get errorLoadingNotifications => 'Erreur lors du chargement des notifications';

  @override
  String get noNotificationsYet => 'Pas encore de notifications!';

  @override
  String get emptyNotificationsDescription => 'Continuez à utiliser l\'application pour recevoir des messages de motivation et des réalisations.';

  @override
  String get motivationalMessage => 'Message motivant';

  @override
  String claimReward(int xp) {
    return 'Réclamer $xp XP';
  }

  @override
  String rewardClaimed(int xp) {
    return 'Récompense réclamée: $xp XP';
  }

  @override
  String get dailyMotivation => 'Motivation quotidienne';

  @override
  String get dailyMotivationDescription => 'Votre motivation quotidienne personnalisée est là. Ouvrez pour obtenir votre récompense XP!';

  @override
  String get retry => 'Réessayer';

  @override
  String get cravingResistedRecorded => 'Envie résistée enregistrée avec succès!';

  @override
  String get cravingRecorded => 'Envie enregistrée avec succès!';

  @override
  String get errorSavingCraving => 'Erreur lors de l\'enregistrement de l\'envie. Appuyez pour réessayer.';

  @override
  String get recordSaved => 'Enregistrement sauvegardé avec succès!';

  @override
  String get tapToRetry => 'Appuyez pour réessayer';

  @override
  String get syncError => 'Erreur de synchronisation';

  @override
  String get loading => 'Chargement...';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get errorLoadingData => 'Erreur lors du chargement des données';

  @override
  String get noRecoveriesFound => 'Aucune récupération de santé trouvée';

  @override
  String get noRecentRecoveries => 'Aucune récupération de santé récente à afficher';

  @override
  String get viewAllRecoveries => 'Voir toutes les récupérations de santé';

  @override
  String get healthRecovery => 'Récupération de la santé';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get achieved => 'Atteint';

  @override
  String get progress => 'Progression';

  @override
  String daysToAchieve(int days) {
    return '$days jours pour atteindre';
  }

  @override
  String daysRemaining(int days) {
    return '$days jours restants';
  }

  @override
  String achievedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Atteint le $dateString';
  }

  @override
  String daysSmokeFree(int days) {
    return '$days jours sans fumer';
  }

  @override
  String get keepGoing => 'Continuez!';

  @override
  String get encouragementMessage => 'Vous faites d\'excellents progrès. Chaque jour sans fumer vous rapproche de l\'atteinte de cet objectif de santé.';

  @override
  String get recoveryAchievedMessage => 'Votre corps s\'est déjà rétabli dans ce domaine. Continuez sur cette voie pour maintenir et améliorer encore plus votre santé.';

  @override
  String get scienceBehindIt => 'La science derrière';

  @override
  String get generalHealthScienceInfo => 'Lorsque vous arrêtez de fumer, votre corps commence une série de processus de guérison. Ceux-ci commencent dans les minutes qui suivent votre dernière cigarette et se poursuivent pendant des années, restaurant progressivement votre santé à celle d\'un non-fumeur.';

  @override
  String get tasteScienceInfo => 'Lorsque vous fumez, les produits chimiques du tabac endommagent les papilles gustatives et réduisent votre capacité à goûter les saveurs. Après quelques jours sans fumer, ces récepteurs gustatifs commencent à guérir, vous permettant de découvrir plus de saveurs et de profiter davantage de la nourriture.';

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
  String get somethingWentWrong => 'Une erreur s\'est produite, veuillez réessayer';

  @override
  String get profileInformation => 'Informations du profil';

  @override
  String get editProfileDescription => 'Mettez à jour vos informations de profil ci-dessous.';

  @override
  String get enterName => 'Entrez votre nom';

  @override
  String get profileUpdatedSuccessfully => 'Profil mis à jour avec succès';

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String get registerFirstCigarette => 'Enregistrez votre première cigarette pour voir la récupération de santé';

  @override
  String get errorOccurred => 'Une erreur s\'est produite';

  @override
  String get pageNotFound => 'Page non trouvée';

  @override
  String get resetLinkSent => 'Lien de réinitialisation envoyé!';

  @override
  String get checkEmailInstructions => 'Vérifiez votre e-mail pour les instructions de réinitialisation de votre mot de passe.';

  @override
  String get backToLogin => 'Retour à la connexion';

  @override
  String get forgotPasswordInstructions => 'Entrez votre adresse e-mail et nous vous enverrons des instructions pour réinitialiser votre mot de passe.';

  @override
  String get sendResetLink => 'Envoyer le lien de réinitialisation';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get fillInformation => 'Remplissez vos informations pour créer un compte';

  @override
  String get name => 'Nom';

  @override
  String get nameRequired => 'Veuillez entrer votre nom';

  @override
  String get passwordTooShort => 'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get confirmPasswordRequired => 'Veuillez confirmer votre mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get termsConditionsAgree => 'J\'accepte les Conditions d\'utilisation';

  @override
  String get termsConditionsRequired => 'Veuillez accepter les Conditions d\'utilisation pour continuer';

  @override
  String get alreadyAccount => 'Vous avez déjà un compte?';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get changePasswordDescription => 'Entrez votre mot de passe actuel et un nouveau mot de passe pour mettre à jour vos identifiants d\'accès.';

  @override
  String get passwordChangedSuccessfully => 'Mot de passe changé avec succès';

  @override
  String get forgotPasswordTitle => 'Mot de passe oublié?';

  @override
  String get forgotPasswordSubtitle => 'Nous pouvons vous envoyer un lien pour réinitialiser votre mot de passe par e-mail.';

  @override
  String get deleteAccountWarningTitle => 'Cette action ne peut pas être annulée';

  @override
  String get deleteAccountWarning => 'Toutes vos données, y compris l\'historique de suivi, les réalisations et les paramètres seront définitivement supprimées. Cette action est irréversible.';

  @override
  String get confirmDeleteAccount => 'Je comprends que c\'est permanent';

  @override
  String get confirmDeleteAccountSubtitle => 'Je comprends que toutes mes données seront définitivement supprimées et ne pourront pas être récupérées.';

  @override
  String get confirmDeleteRequired => 'Veuillez confirmer que vous comprenez que cette action est permanente.';

  @override
  String get accountDeleted => 'Votre compte a été supprimé avec succès.';

  @override
  String get changeDate => 'Changer la date';

  @override
  String get selectDate => 'Sélectionner une date';

  @override
  String get clearDate => 'Effacer la date';

  @override
  String get suggestedDates => 'Dates suggérées';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String get oneWeekAgo => 'Il y a une semaine';

  @override
  String get twoWeeksAgo => 'Il y a deux semaines';

  @override
  String get oneMonthAgo => 'Il y a un mois';

  @override
  String get feedbackTitle => 'Nous valorisons votre opinion';

  @override
  String get skip => 'Passer';

  @override
  String get howIsYourExperience => 'Comment se passe votre expérience?';

  @override
  String get enjoyingApp => 'Appréciez-vous l\'application?';

  @override
  String get notReally => 'Pas vraiment';

  @override
  String get yesImEnjoying => 'Oui, je l\'apprécie!';

  @override
  String get yesILikeIt => 'Oui, je l\'aime bien!';

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
  String get stayInformed => 'Restez informé';

  @override
  String get receiveTimelyCues => 'Recevez des indices opportuns et des informations importantes';

  @override
  String get importantReminders => 'RAPPELS IMPORTANTS POUR VOTRE PARCOURS';

  @override
  String get notificationsHelp => 'Les notifications fournissent des rappels opportuns, de la motivation et des alertes de jalons importantes pour vous aider à rester sur la bonne voie avec votre objectif.';

  @override
  String get allowNotifications => 'Autoriser les notifications';

  @override
  String get notificationsEnabled => 'Notifications activées avec succès!';

  @override
  String get notificationPermissionFailed => 'Un problème est survenu lors de l\'activation des notifications';

  @override
  String get requesting => 'Demande en cours...';

  @override
  String get skipForNow => 'Passer pour l\'instant';

  @override
  String get onboardingLoadError => 'Error loading onboarding';

  @override
  String get unknownError => 'Unknown error';
}
