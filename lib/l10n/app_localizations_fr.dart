// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get textSeparator => ' | ';

  @override
  String get termsOfServiceUrl => 'https://nicotina.ai/legal/terms-of-service';

  @override
  String get privacyPolicyUrl => 'https://nicotina.ai/legal/privacy-policy';

  @override
  String get incompleteOnboarding => 'Intégration Incomplète';

  @override
  String get completeAllStepsMessage => 'Veuillez compléter toutes les étapes de l\'intégration avant de continuer.';

  @override
  String get ok => 'OK';

  @override
  String get days => 'jours';

  @override
  String get welcomeToApp => 'Bienvenue sur NicotinaAI';

  @override
  String get selectLanguage => 'Sélectionnez votre langue préférée';

  @override
  String get continueButton => 'Continuer';

  @override
  String get achievementFirstStep => 'Première Étape';

  @override
  String get achievementFirstStepDescription => 'Terminez le processus d\'intégration';

  @override
  String get achievementOneDayWonder => 'Prodige d\'un Jour';

  @override
  String get achievementOneDayWonderDescription => 'Restez sans fumer pendant 1 jour';

  @override
  String get achievementWeekWarrior => 'Guerrier de la Semaine';

  @override
  String get achievementWeekWarriorDescription => 'Restez sans fumer pendant 7 jours';

  @override
  String get achievementMonthMaster => 'Maître du Mois';

  @override
  String get achievementMonthMasterDescription => 'Restez sans fumer pendant 30 jours';

  @override
  String get achievementMoneyMindful => 'Attentif à l\'Argent';

  @override
  String get achievementMoneyMindfulDescription => 'Économisez 50€ en ne fumant pas';

  @override
  String get achievementCenturion => 'Centurion';

  @override
  String get achievementCenturionDescription => 'Économisez 100€ en ne fumant pas';

  @override
  String get achievementCravingCrusher => 'Écraseur de Vogues';

  @override
  String get achievementCravingCrusherDescription => 'Résistez avec succès à 10 vogues';

  @override
  String get loading => 'Chargement...';

  @override
  String get appName => 'NicotinaAI';

  @override
  String get pageNotFound => 'Page non trouvée';

  @override
  String get motivationalMessage => 'Continuez comme ça ! Vous allez très bien !';

  @override
  String get helpScreenTitle => 'Comment pouvons-nous vous aider ?';

  @override
  String get selectAllInterests => 'Sélectionnez toutes les options qui vous intéressent';

  @override
  String get helpScreenExplanation => 'Nous offrons différentes ressources pour soutenir votre parcours. Sélectionnez tout ce qui, selon vous, pourrait vous aider.';

  @override
  String get dailyTips => 'Conseils quotidiens';

  @override
  String get dailyTipsDescription => 'Recevez des conseils pratiques chaque jour pour soutenir votre parcours';

  @override
  String get customReminders => 'Rappels personnalisés';

  @override
  String get customRemindersDescription => 'Notifications pour vous maintenir motivé et sur la bonne voie';

  @override
  String get progressMonitoring => 'Suivi des progrès';

  @override
  String get progressMonitoringDescription => 'Suivez visuellement vos progrès au fil du temps';

  @override
  String get supportCommunity => 'Communauté de soutien';

  @override
  String get supportCommunityDescription => 'Connectez-vous avec d\'autres personnes dans un parcours similaire';

  @override
  String get cigaretteAlternatives => 'Alternatives à la cigarette';

  @override
  String get cigaretteAlternativesDescription => 'Suggestions d\'activités et de produits pour remplacer l\'habitude';

  @override
  String get savingsCalculator => 'Calculateur d\'Économies';

  @override
  String get savingsCalculatorDescription => 'Voyez combien d\'argent vous économisez en réduisant ou en arrêtant de fumer';

  @override
  String get modifyPreferencesAnytime => 'Vous pouvez modifier ces préférences à tout moment dans les paramètres de l\'application.';

  @override
  String get personalizeScreenTitle => 'Quand fumez-vous le plus généralement ?';

  @override
  String get personalizeScreenSubtitle => 'Sélectionnez les moments où vous ressentez le plus l\'envie de fumer';

  @override
  String get afterMeals => 'Après les repas';

  @override
  String get duringWorkBreaks => 'Pendant les pauses de travail';

  @override
  String get inSocialEvents => 'Lors d\'événements sociaux';

  @override
  String get whenStressed => 'Quand je suis stressé';

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
    return 'Bonjour, $name !';
  }

  @override
  String get homeHealthRecovery => 'Rétablissement de la Santé';

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
  String get homeNextMilestone => 'Prochain Jalon';

  @override
  String homeNextMilestoneDescription(int days) {
    return 'Prochain jalon dans $days jours';
  }

  @override
  String get homeRecentAchievements => 'Réalisations Récentes';

  @override
  String get homeSeeAll => 'Voir tout';

  @override
  String get homeFirstDay => 'Premier Jour';

  @override
  String get homeFirstDayDescription => 'Vous avez passé 24 heures sans fumer !';

  @override
  String get homeOvercoming => 'Surmonter';

  @override
  String get homeOvercomingDescription => 'Niveaux de nicotine éliminés du corps';

  @override
  String get homePersistence => 'Persistance';

  @override
  String get homePersistenceDescription => 'Une semaine entière sans cigarettes !';

  @override
  String get homeTodayStats => 'Statistiques d\'Aujourd\'hui';

  @override
  String get homeCravingsResisted => 'Envies\nRésistées';

  @override
  String get homeMinutesGainedToday => 'Minutes de Vie\nGagnées Aujourd\'hui';

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
  String get achievementUnlocked => 'Réalisation Débloquée !';

  @override
  String get achievementInProgress => 'En cours';

  @override
  String get achievementCompleted => 'Terminé';

  @override
  String get achievementCurrentProgress => 'Vos Progrès Actuels';

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
  String get achievementBenefitCO2 => 'CO2 Normal';

  @override
  String get achievementBenefitTaste => 'Goût Amélioré';

  @override
  String get achievementBenefitCirculation => 'Circulation +15%';

  @override
  String get achievementFirstDay => 'Premier Jour';

  @override
  String get achievementFirstDayDescription => 'Terminez 24 heures sans fumer';

  @override
  String get achievementOneWeek => 'Une Semaine';

  @override
  String get achievementOneWeekDescription => 'Une semaine sans fumer !';

  @override
  String get achievementImprovedCirculation => 'Circulation Améliorée';

  @override
  String get achievementImprovedCirculationDescription => 'Niveaux d\'oxygène normalisés';

  @override
  String get achievementInitialSavings => 'Économies Initiales';

  @override
  String get achievementInitialSavingsDescription => 'Économisez l\'équivalent de 1 paquet de cigarettes';

  @override
  String get achievementTwoWeeks => 'Deux Semaines';

  @override
  String get achievementTwoWeeksDescription => 'Deux semaines complètes sans fumer !';

  @override
  String get achievementSubstantialSavings => 'Économies Substantialles';

  @override
  String get achievementSubstantialSavingsDescription => 'Économisez l\'équivalent de 10 paquets de cigarettes';

  @override
  String get achievementCleanBreathing => 'Respiration Propre';

  @override
  String get achievementCleanBreathingDescription => 'Capacité pulmonaire augmentée de 30%';

  @override
  String get achievementOneMonth => 'Un Mois';

  @override
  String get achievementOneMonthDescription => 'Un mois entier sans fumer !';

  @override
  String get achievementNewHabitExercise => 'Nouvelle Habitude : Exercice';

  @override
  String get achievementNewHabitExerciseDescription => 'Enregistrez 5 jours d\'exercice';

  @override
  String percentCompleted(int percent) {
    return '$percent% terminé';
  }

  @override
  String get welcomeBack => 'Bon Retour';

  @override
  String get loginToContinue => 'Connectez-vous pour continuer';

  @override
  String get email => 'Email';

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
  String get noAccount => 'Vous n\'avez pas de compte ?';

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
  String get editProfile => 'Modifier le Profil';

  @override
  String get appSettings => 'Paramètres de l\'App';

  @override
  String get notifications => 'Notifications';

  @override
  String get manageNotifications => 'Gérer les notifications';

  @override
  String get language => 'Langue';

  @override
  String get changeLanguage => 'Changer la langue de l\'app';

  @override
  String get theme => 'Thème';

  @override
  String get dark => 'Sombre';

  @override
  String get light => 'Clair';

  @override
  String get system => 'Système';

  @override
  String get habitTracking => 'Suivi des Habitudes';

  @override
  String get cigarettesPerDay => 'Cigarettes par jour avant d\'arrêter';

  @override
  String get configureHabits => 'Configurez vos habitudes précédentes';

  @override
  String get packPrice => 'Prix du paquet';

  @override
  String get setPriceForCalculations => 'Définissez le prix pour les calculs d\'économies';

  @override
  String get startDate => 'Date de début';

  @override
  String get whenYouQuitSmoking => 'Quand vous avez arrêté de fumer';

  @override
  String get account => 'Compte';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get changePassword => 'Changer votre mot de passe de connexion';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get permanentlyRemoveAccount => 'Supprimer définitivement votre compte';

  @override
  String get deleteAccountTitle => 'Supprimer le Compte';

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
  String get privacyPolicy => 'Politique de Confidentialité';

  @override
  String get readPrivacyPolicy => 'Lire notre politique de confidentialité';

  @override
  String get termsOfUse => 'Conditions d\'Utilisation';

  @override
  String get viewTermsOfUse => 'Afficher les conditions d\'utilisation de l\'app';

  @override
  String get aboutApp => 'À propos de l\'App';

  @override
  String get appInfo => 'Version et informations de l\'app';

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
  String get low => 'Bas';

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
  String get smallPack => 'Petit paquet/paquet compact';

  @override
  String get standardPack => 'Paquet standard/traditionnel';

  @override
  String get otherQuantity => 'Autre quantité';

  @override
  String get selectCustomValue => 'Sélectionnez une valeur personnalisée';

  @override
  String get quantity => 'Quantité : ';

  @override
  String get packSizeHelp => 'Cette information nous aide à calculer précisément votre consommation et les bénéfices de la réduction ou de l\'arrêt du tabac.';

  @override
  String get packPriceQuestion => 'Combien coûte un paquet de cigarettes ?';

  @override
  String get helpCalculateFinancial => 'Cela nous aide à calculer vos économies financières';

  @override
  String get enterAveragePrice => 'Entrez le prix moyen que vous payez pour un paquet de cigarettes.';

  @override
  String get priceHelp => 'Cette information nous aide à vous montrer combien vous économiserez en réduisant ou en arrêtant de fumer.';

  @override
  String get productTypeQuestion => 'Quel type de produit consommez-vous ?';

  @override
  String get selectApplicable => 'Sélectionnez ce qui s\'applique à vous';

  @override
  String get helpPersonalizeStrategy => 'Cela nous aide à personnaliser les stratégies et les recommandations pour votre cas spécifique.';

  @override
  String get cigaretteOnly => 'Seulement cigarettes traditionnelles';

  @override
  String get traditionalCigarettes => 'Cigarettes de tabac conventionnelles';

  @override
  String get vapeOnly => 'Seulement Vape/cigarettes électroniques';

  @override
  String get electronicDevices => 'Dispositifs de vapotage électroniques';

  @override
  String get both => 'Les deux';

  @override
  String get useBoth => 'J\'utilise à la fois des cigarettes traditionnelles et électroniques';

  @override
  String get productTypeHelp => 'Différents produits contiennent des quantités différentes de nicotine et peuvent nécessiter des stratégies différentes pour la réduction ou la cessation.';

  @override
  String get pleaseSelectProductType => 'Veuillez sélectionner un type de produit';

  @override
  String get goalQuestion => 'Quel est votre objectif ?';

  @override
  String get selectGoal => 'Sélectionnez ce que vous voulez atteindre';

  @override
  String get goalExplanation => 'Définir un objectif clair est essentiel pour votre succès. Nous voulons vous aider à atteindre ce que vous désirez.';

  @override
  String get reduceConsumption => 'Réduire la consommation';

  @override
  String get reduceDescription => 'Je veux fumer moins de cigarettes et avoir plus de contrôle sur l\'habitude';

  @override
  String get reduce => 'Réduire';

  @override
  String get quitSmoking => 'Arrêter de fumer';

  @override
  String get quitDescription => 'Je veux arrêter complètement les cigarettes et vivre sans tabac';

  @override
  String get quit => 'Arrêter';

  @override
  String get goalHelp => 'Nous adapterons nos ressources et recommandations en fonction de votre objectif. Vous pourrez le modifier plus tard si vous changez d\'avis.';

  @override
  String get pleaseSelectGoal => 'Veuillez sélectionner un objectif';

  @override
  String get timelineQuestionReduce => 'Quand voulez-vous réduire votre consommation ?';

  @override
  String get timelineQuestionQuit => 'Quand voulez-vous arrêter de fumer ?';

  @override
  String get establishDeadline => 'Fixez une échéance qui vous semble réalisable';

  @override
  String get timelineExplanation => 'Un calendrier réaliste augmente vos chances de succès. Choisissez un laps de temps avec lequel vous êtes à l\'aise.';

  @override
  String get sevenDays => '7 jours';

  @override
  String get sevenDaysDescription => 'Je veux des résultats rapides et je suis engagé';

  @override
  String get fourteenDays => '14 jours';

  @override
  String get fourteenDaysDescription => 'Un délai équilibré pour changer d\'habitudes';

  @override
  String get thirtyDays => '30 jours';

  @override
  String get thirtyDaysDescription => 'Un mois pour un changement progressif et durable';

  @override
  String get noDeadline => 'Pas de délai défini';

  @override
  String get noDeadlineDescription => 'Je préfère aller à mon propre rythme';

  @override
  String get timelineHelp => 'Ne vous inquiétez pas si vous n\'atteignez pas votre objectif exactement dans les délais. Ce qui compte, c\'est le progrès continu.';

  @override
  String get pleaseSelectTimeline => 'Veuillez sélectionner un calendrier';

  @override
  String get identifyChallenge => 'Identifier votre principal défi nous aide à fournir un meilleur soutien';

  @override
  String get challengeExplanation => 'Comprendre ce qui rend l\'arrêt des cigarettes difficile est la première étape pour surmonter cet obstacle.';

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
  String get socialDescription => 'Les gens autour de moi fument ou m\'encouragent à fumer';

  @override
  String get physicalDependence => 'Dépendance physique';

  @override
  String get dependenceDescription => 'Je ressens des symptômes physiques quand je ne fume pas';

  @override
  String get challengeHelp => 'Vos réponses nous aident à personnaliser des conseils et des stratégies plus efficaces pour votre cas spécifique.';

  @override
  String get pleaseSelectChallenge => 'Veuillez sélectionner un défi';

  @override
  String get locationsQuestion => 'Où fumez-vous généralement ?';

  @override
  String get selectCommonPlaces => 'Sélectionnez les endroits où vous fumez le plus souvent';

  @override
  String get locationsExplanation => 'Connaître vos lieux habituels nous aide à identifier les schémas et à créer des stratégies spécifiques.';

  @override
  String get atHome => 'À la maison';

  @override
  String get homeDetails => 'Balcon, salon, bureau';

  @override
  String get atWork => 'Au travail/école';

  @override
  String get workDetails => 'Pendant les pauses';

  @override
  String get inCar => 'Dans la voiture/transport';

  @override
  String get carDetails => 'Pendant les trajets';

  @override
  String get socialEvents => 'Lors d\'événements sociaux';

  @override
  String get socialDetails => 'Bars, fêtes, restaurants';

  @override
  String get outdoors => 'En extérieur';

  @override
  String get outdoorsDetails => 'Parcs, trottoirs, espaces extérieurs';

  @override
  String get otherPlaces => 'Autres endroits';

  @override
  String get otherPlacesDetails => 'Quand je suis anxieux, quel que soit l\'endroit';

  @override
  String get locationsHelp => 'Identifier les endroits les plus courants aide à éviter les déclencheurs et à créer des stratégies pour changer d\'habitudes.';

  @override
  String get allDone => 'Tout est Terminé !';

  @override
  String get personalizedJourney => 'Votre parcours personnalisé commence maintenant';

  @override
  String get startMyJourney => 'Commencer Mon Parcours';

  @override
  String get congratulations => 'Félicitations pour avoir fait le premier pas !';

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
  String get mainChallenge => 'Votre principal défi';

  @override
  String get personalized => 'Suivi personnalisé';

  @override
  String get personalizedDescription => 'Suivez vos progrès en fonction de vos habitudes';

  @override
  String get importantAchievements => 'Réalisations importantes';

  @override
  String get achievementsDescription => 'Célébrez chaque jalon de votre parcours';

  @override
  String get supportWhenNeeded => 'Soutien quand vous en avez besoin';

  @override
  String get supportDescription => 'Conseils et stratégies pour les moments difficiles';

  @override
  String get guaranteedResults => 'Résultats garantis';

  @override
  String get resultsDescription => 'Avec notre technologie basée sur la science';

  @override
  String get developer => 'Développeur';

  @override
  String get developerMode => 'Mode Développeur';

  @override
  String get enableDebugging => 'Activer le débogage et le suivi détaillés';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get viewDetailedTracking => 'Voir le tableau de bord de suivi détaillé';

  @override
  String get currency => 'Devise';

  @override
  String get changeCurrency => 'Changer de devise';

  @override
  String get setCurrencyForCalculations => 'Définissez la devise pour les calculs d\'économies';

  @override
  String get search => 'Rechercher';

  @override
  String get noResults => 'Aucun résultat trouvé';

  @override
  String get listView => 'Vue liste';

  @override
  String get gridView => 'Vue grille';

  @override
  String get atYourOwnPace => 'à votre rythme';

  @override
  String get nextSevenDays => 'dans les 7 prochains jours';

  @override
  String get nextTwoWeeks => 'dans les 2 prochaines semaines';

  @override
  String get nextMonth => 'dans le prochain mois';

  @override
  String get notSpecified => 'Non spécifié';

  @override
  String get registerCraving => 'Enregistrer une Envie';

  @override
  String get registerCravingSubtitle => 'Quand vous sentez l\'envie';

  @override
  String get newRecord => 'Nouvel Enregistrement';

  @override
  String get newRecordSubtitle => 'Quand vous fumez';

  @override
  String get whereAreYou => 'Où êtes-vous ?';

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
  String get howAreYouFeeling => 'Comment vous sentez-vous ?';

  @override
  String get whatTriggeredCraving => 'Qu\'est-ce qui a déclenché votre envie ?';

  @override
  String get stress => 'Stress';

  @override
  String get boredom => 'Ennui';

  @override
  String get socialSituation => 'Situation sociale';

  @override
  String get afterMeal => 'Après le repas';

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
  String get whatsTheReason => 'Quelle est la raison ?';

  @override
  String get anxiety => 'Anxiété';

  @override
  String get pleaseSelectReason => 'Veuillez sélectionner une raison';

  @override
  String get howDoYouFeel => 'Comment vous sentez-vous ? Qu\'auriez-vous pu faire différemment ?';

  @override
  String get didYouResist => 'Avez-vous résisté ?';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get howMuchDidYouSmoke => 'Combien avez-vous fumé ?';

  @override
  String get oneOrLess => '1 ou moins';

  @override
  String get twoToFive => '2-5';

  @override
  String get moreThanFive => 'Plus de 5';

  @override
  String get pleaseSelectAmount => 'Veuillez sélectionner combien vous avez fumé';

  @override
  String get howLongDidItLast => 'Combien de temps cela a-t-il duré ?';

  @override
  String get lessThan5min => 'Moins de 5 min';

  @override
  String get fiveToFifteenMin => '5-15 min';

  @override
  String get moreThan15min => 'Plus de 15 min';

  @override
  String get pleaseSelectDuration => 'Veuillez sélectionner combien de temps cela a duré';

  @override
  String get selectCurrency => 'Sélectionnez votre devise';

  @override
  String get selectCurrencySubtitle => 'Choisissez la devise pour les calculs financiers';

  @override
  String get preselectedCurrency => 'Nous avons présélectionné votre devise locale. Vous pouvez la changer si nécessaire.';

  @override
  String get pleaseCompleteAllFields => 'Veuillez compléter tous les champs requis pour continuer';

  @override
  String get understood => 'Compris';

  @override
  String get commonPrices => 'Prix courants des paquets';

  @override
  String get refresh => 'Actualiser';

  @override
  String get errorLoadingNotifications => 'Erreur lors du chargement des notifications';

  @override
  String get noNotificationsYet => 'Aucune notification pour l\'instant !';

  @override
  String get emptyNotificationsDescription => 'Continuez à utiliser l\'application pour recevoir des messages de motivation et des réalisations.';

  @override
  String get dailyMotivation => 'Motivation Quotidienne';

  @override
  String get dailyMotivationDescription => 'Votre motivation quotidienne personnalisée est ici. Ouvrez-la pour obtenir votre récompense XP !';

  @override
  String get retry => 'Réessayer';

  @override
  String get cravingResistedRecorded => 'Envie résistée enregistrée avec succès !';

  @override
  String get cravingRecorded => 'Envie enregistrée avec succès !';

  @override
  String get errorSavingCraving => 'Erreur lors de l\'enregistrement de l\'envie. Appuyez pour réessayer.';

  @override
  String get recordSaved => 'Enregistrement sauvegardé avec succès !';

  @override
  String get tapToRetry => 'Appuyez pour réessayer';

  @override
  String get syncError => 'Erreur de synchronisation';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get errorLoadingData => 'Erreur lors du chargement des données';

  @override
  String get noRecoveriesFound => 'Aucun rétablissement de la santé trouvé';

  @override
  String get noRecentRecoveries => 'Aucun rétablissement récent de la santé à afficher';

  @override
  String get viewAllRecoveries => 'Voir Tous les Rétablissements de la Santé';

  @override
  String get healthRecovery => 'Rétablissement de la Santé';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get achieved => 'Atteint';

  @override
  String get progress => 'Progrès';

  @override
  String daysSmokeFree(int days) {
    return '$days jours sans fumer';
  }

  @override
  String daysToAchieve(int days) {
    return 'Jours pour atteindre : $days';
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
  String get keepGoing => 'Continuez comme ça !';

  @override
  String get encouragementMessage => 'Vous faites d\'excellents progrès. Chaque jour sans fumer vous rapproche de l\'atteinte de ce jalon de santé.';

  @override
  String get recoveryAchievedMessage => 'Votre corps s\'est déjà rétabli dans ce domaine. Continuez le bon travail pour maintenir et améliorer davantage votre santé.';

  @override
  String get scienceBehindIt => 'La Science Derrière';

  @override
  String get generalHealthScienceInfo => 'Lorsque vous arrêtez de fumer, votre corps entame une série de processus de guérison. Ceux-ci commencent quelques minutes après votre dernière cigarette et se poursuivent pendant des années, rétablissant progressivement votre santé à celle d\'un non-fumeur.';

  @override
  String get tasteScienceInfo => 'Lorsque vous fumez, les produits chimiques du tabac endommagent les papilles gustatives et réduisent votre capacité à goûter. Après seulement quelques jours sans fumer, ces récepteurs gustatifs commencent à guérir, vous permettant d\'expérimenter plus de saveurs et de mieux apprécier la nourriture.';

  @override
  String get smellScienceInfo => 'Fumer endommage les nerfs olfactifs qui transmettent les informations olfactives au cerveau. Quelques jours après avoir arrêté, ces nerfs commencent à se rétablir, améliorant progressivement votre odorat et vous permettant de détecter des odeurs plus subtiles.';

  @override
  String get bloodOxygenScienceInfo => 'Le monoxyde de carbone des cigarettes se lie à l\'hémoglobine dans votre sang, réduisant sa capacité à transporter l\'oxygène. Dans les 12 à 24 heures suivant l\'arrêt, les niveaux de monoxyde de carbone diminuent considérablement, permettant à votre sang de transporter l\'oxygène plus efficacement.';

  @override
  String get carbonMonoxideScienceInfo => 'La fumée de cigarette contient du monoxyde de carbone, qui déplace l\'oxygène dans votre sang. Dans les 12 heures suivant l\'arrêt, les niveaux de monoxyde de carbone reviennent à la normale et les niveaux d\'oxygène dans votre corps augmentent significativement.';

  @override
  String get nicotineScienceInfo => 'La nicotine a une demi-vie d\'environ 2 heures, ce qui signifie qu\'il faut environ 72 heures (3 jours) pour que toute la nicotine soit éliminée de votre corps. Une fois la nicotine partie, les symptômes physiques de sevrage commencent à diminuer.';

  @override
  String get improvedBreathingScienceInfo => 'Après 7 jours sans fumer, la fonction pulmonaire commence à s\'améliorer à mesure que l\'inflammation diminue et que les poumons commencent à éliminer le mucus accumulé. Vous remarquerez moins de toux et une respiration plus facile, surtout pendant l\'activité physique.';

  @override
  String get improvedCirculationScienceInfo => 'Après deux semaines sans fumer, votre circulation s\'améliore significativement. Les vaisseaux sanguins se dilatent, la pression artérielle se normalise, et plus d\'oxygène atteint vos muscles et organes, rendant l\'activité physique plus facile et moins fatigante.';

  @override
  String get decreasedCoughingScienceInfo => 'Un mois après avoir arrêté, les cils (petites structures ressemblant à des cheveux) dans vos poumons commencent à repousser. Ceux-ci aident à nettoyer vos poumons et à réduire les infections. Votre toux et votre essoufflement continuent de diminuer.';

  @override
  String get lungCiliaScienceInfo => 'Après 3 mois sans fumer, votre fonction pulmonaire peut s\'améliorer jusqu\'à 30%. Les cils dans vos poumons ont largement repoussé, améliorant la capacité de vos poumons à se nettoyer, à combattre les infections et à réduire le mucus.';

  @override
  String get reducedHeartDiseaseRiskScienceInfo => 'Après un an sans fumer, votre risque de maladie coronarienne diminue à environ la moitié de celui d\'un fumeur. Votre fonction cardiaque continue de s\'améliorer à mesure que les vaisseaux sanguins guérissent et que la circulation s\'améliore.';

  @override
  String get viewHealthRecoveries => 'Voir les Rétablissements de la Santé';

  @override
  String get recoveryNotFound => 'Rétablissement de la santé non trouvé';

  @override
  String get trackYourHealthJourney => 'Suivez Votre Parcours de Santé';

  @override
  String get healthRecoveryDescription => 'Voyez comment votre corps se rétablit après avoir arrêté de fumer';

  @override
  String get somethingWentWrong => 'Quelque chose s\'est mal passé, veuillez réessayer';

  @override
  String get comingSoon => 'Bientôt Disponible';

  @override
  String get registerFirstCigarette => 'Enregistrez votre première cigarette pour voir le rétablissement de la santé';

  @override
  String get errorOccurred => 'Une erreur s\'est produite';

  @override
  String get feedbackTitle => 'Votre avis nous intéresse';

  @override
  String get skip => 'Passer';

  @override
  String get howIsYourExperience => 'Comment est votre expérience ?';

  @override
  String get enjoyingApp => 'Appréciez-vous l\'application ?';

  @override
  String get notReally => 'Pas vraiment';

  @override
  String get yesImEnjoying => 'Oui, j\'aime bien !';

  @override
  String get yesILikeIt => 'Oui, j\'aime ça !';

  @override
  String get rateApp => 'Voulez-vous évaluer l\'application ?';

  @override
  String get howWouldYouRateApp => 'Comment évalueriez-vous notre application ?';

  @override
  String get yourOpinionMatters => 'Votre opinion compte pour nous';

  @override
  String get weAreConstantlyImproving => 'Nous améliorons constamment notre application en fonction des commentaires des utilisateurs';

  @override
  String get later => 'Plus tard';

  @override
  String get tellUsIssues => 'Dites-nous ce qui ne va pas';

  @override
  String get helpUsImprove => 'Aidez-nous à nous améliorer en nous disant ce que nous pouvons faire de mieux :';

  @override
  String get feedbackCategory => 'Catégorie de feedback';

  @override
  String get interface => 'Interface';

  @override
  String get features => 'Fonctionnalités';

  @override
  String get performance => 'Performance';

  @override
  String get statisticsAccuracy => 'Précision des Statistiques';

  @override
  String get accuracyOfStatistics => 'Précision des statistiques';

  @override
  String get yourFeedback => 'Votre feedback';

  @override
  String get describeProblem => 'Décrivez ce que nous pouvons améliorer...';

  @override
  String get describeWhatToImprove => 'Décrivez ce que nous pourrions améliorer...';

  @override
  String get whatCouldBeBetter => 'Qu\'est-ce qui pourrait être mieux ?';

  @override
  String get sendFeedback => 'Envoyer le feedback';

  @override
  String get thankYouForFeedback => 'Merci pour votre feedback !';

  @override
  String get gladYouLikeIt => 'Nous sommes ravis que vous aimiez !';

  @override
  String get wouldYouRateOnStore => 'Voulez-vous évaluer notre application sur le store ?';

  @override
  String get rateAppStore => 'Souhaitez-vous noter l\'application sur le store ?';

  @override
  String get alreadyRated => 'J\'ai déjà évalué';

  @override
  String get rateNow => 'Évaluer maintenant';

  @override
  String get feedbackError => 'Oups, quelque chose s\'est mal passé';

  @override
  String get couldNotSaveFeedback => 'N\'a pas pu enregistrer votre feedback';

  @override
  String get understand => 'Je comprends';

  @override
  String get onboardingLoadError => 'Erreur lors du chargement de l\'intégration';

  @override
  String get unknownError => 'Une erreur inconnue s\'est produite';

  @override
  String get errorUserNotAuthenticated => 'Vous devez être connecté pour effectuer cette action';

  @override
  String get userNotAuthenticated => 'Vous n\'êtes pas connecté';

  @override
  String get registeringCravingResisted => 'Enregistrement de l\'envie résistée...';

  @override
  String get registeringCraving => 'Enregistrement de l\'envie...';

  @override
  String challengeQuestion(String goalText) {
    return 'Qu\'est-ce qui rend difficile de $goalText ?';
  }

  @override
  String personalizedPlanReduce(String timelineText) {
    return 'Nous avons créé un plan personnalisé pour vous aider à réduire votre consommation de cigarettes $timelineText. Ce plan est basé sur vos habitudes et préférences.';
  }

  @override
  String personalizedPlanQuit(String timelineText) {
    return 'Nous avons créé un plan personnalisé pour vous aider à arrêter de fumer $timelineText. Ce plan est basé sur vos habitudes et préférences.';
  }

  @override
  String todayAt(String time) {
    return 'Aujourd\'hui à $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Hier à $time';
  }

  @override
  String dayOfWeekAt(String weekday, String time) {
    return '$weekday à $time';
  }

  @override
  String dateTimeFormat(String day, String month, String year, String time) {
    return '$day/$month/$year à $time';
  }

  @override
  String get monday => 'Lundi';

  @override
  String get tuesday => 'Mardi';

  @override
  String get wednesday => 'Mercredi';

  @override
  String get thursday => 'Jeudi';

  @override
  String get friday => 'Vendredi';

  @override
  String get saturday => 'Samedi';

  @override
  String get sunday => 'Dimanche';

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
  String get termsConditionsAgree => 'J\'accepte les Termes et Conditions';

  @override
  String get termsConditionsRequired => 'Veuillez accepter les Termes et Conditions pour continuer';

  @override
  String get alreadyAccount => 'Vous avez déjà un compte ?';

  @override
  String get resetLinkSent => 'Lien de réinitialisation envoyé';

  @override
  String get checkEmailInstructions => 'Vérifiez votre email pour les instructions sur la réinitialisation de votre mot de passe';

  @override
  String get forgotPasswordInstructions => 'Entrez votre email et nous vous enverrons les instructions pour réinitialiser votre mot de passe';

  @override
  String get sendResetLink => 'Envoyer le lien de réinitialisation';

  @override
  String get backToLogin => 'Retour à la connexion';

  @override
  String get createAccount => 'Créer un Compte';

  @override
  String get stayInformed => 'Restez Informé';

  @override
  String get receiveTimelyCues => 'Recevez des indications et des rappels opportuns pour vous aider dans votre parcours';

  @override
  String get importantReminders => 'Rappels Importants';

  @override
  String get notificationsHelp => 'Les notifications vous aident à rester sur la bonne voie avec vos objectifs, fournissent un soutien opportun pendant les moments difficiles et célèbrent vos réalisations.';

  @override
  String get requesting => 'Requête en cours...';

  @override
  String get allowNotifications => 'Autoriser les Notifications';

  @override
  String get notificationsEnabled => 'Notifications activées avec succès';

  @override
  String get skipForNow => 'Passer pour l\'instant';

  @override
  String get notificationPermissionFailed => 'L\'autorisation de notification n\'a pas été accordée';
}
