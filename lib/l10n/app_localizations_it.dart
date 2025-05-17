// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get incompleteOnboarding => 'Onboarding incompleto';

  @override
  String get completeAllStepsMessage => 'Completa tutti i passaggi dell\'onboarding prima di continuare.';

  @override
  String get ok => 'OK';

  @override
  String get days => 'giorni';

  @override
  String get helpScreenTitle => 'Come possiamo aiutarti?';

  @override
  String get selectAllInterests => 'Seleziona tutte le opzioni che ti interessano';

  @override
  String get helpScreenExplanation => 'Offriamo diverse risorse per supportare il tuo percorso. Seleziona tutto ciò che pensi possa aiutarti.';

  @override
  String get dailyTips => 'Consigli quotidiani';

  @override
  String get dailyTipsDescription => 'Ricevi consigli pratici ogni giorno per supportare il tuo percorso';

  @override
  String get customReminders => 'Promemoria personalizzati';

  @override
  String get customRemindersDescription => 'Notifiche per mantenerti motivato e in linea con i tuoi obiettivi';

  @override
  String get progressMonitoring => 'Monitoraggio dei progressi';

  @override
  String get progressMonitoringDescription => 'Monitora visivamente i tuoi progressi nel tempo';

  @override
  String get supportCommunity => 'Comunità di supporto';

  @override
  String get supportCommunityDescription => 'Connettiti con altre persone in un percorso simile';

  @override
  String get cigaretteAlternatives => 'Alternative alle sigarette';

  @override
  String get cigaretteAlternativesDescription => 'Suggerimenti per attività e prodotti per sostituire l\'abitudine';

  @override
  String get savingsCalculator => 'Calcolatore dei risparmi';

  @override
  String get savingsCalculatorDescription => 'Vedi quanto denaro stai risparmiando riducendo o smettendo di fumare';

  @override
  String get modifyPreferencesAnytime => 'Puoi modificare queste preferenze in qualsiasi momento nelle impostazioni dell\'app.';

  @override
  String get personalizeScreenTitle => 'Quando solitamente fumi di più?';

  @override
  String get personalizeScreenSubtitle => 'Seleziona i momenti in cui ti viene più voglia di fumare';

  @override
  String get afterMeals => 'Dopo i pasti';

  @override
  String get duringWorkBreaks => 'Durante le pause di lavoro';

  @override
  String get inSocialEvents => 'In eventi sociali';

  @override
  String get whenStressed => 'Quando sono stressato';

  @override
  String get withCoffeeOrAlcohol => 'Quando bevo caffè o alcol';

  @override
  String get whenBored => 'Quando mi annoio';

  @override
  String homeDaysWithoutSmoking(int days) {
    return '$days giorni senza fumare';
  }

  @override
  String homeGreeting(String name) {
    return 'Ciao, $name! 👋';
  }

  @override
  String get homeHealthRecovery => 'Recupero della salute';

  @override
  String get homeTaste => 'Gusto';

  @override
  String get homeSmell => 'Olfatto';

  @override
  String get homeCirculation => 'Circolazione';

  @override
  String get homeLungs => 'Polmoni';

  @override
  String get homeHeart => 'Cuore';

  @override
  String get homeMinutesLifeGained => 'minuti di vita\nguadagnati';

  @override
  String get homeLungCapacity => 'capacità\npolmonare';

  @override
  String get homeNextMilestone => 'Prossimo Traguardo';

  @override
  String homeNextMilestoneDescription(int days) {
    return 'Tra $days giorni: La circolazione sanguigna migliorerà';
  }

  @override
  String get homeRecentAchievements => 'Successi recenti';

  @override
  String get homeSeeAll => 'Vedi tutti';

  @override
  String get homeFirstDay => 'Primo Giorno';

  @override
  String get homeFirstDayDescription => 'Hai trascorso 24 ore senza fumare!';

  @override
  String get homeOvercoming => 'Superamento';

  @override
  String get homeOvercomingDescription => 'Livelli di nicotina eliminati dal corpo';

  @override
  String get homePersistence => 'Perseveranza';

  @override
  String get homePersistenceDescription => 'Un\'intera settimana senza sigarette!';

  @override
  String get homeTodayStats => 'Statistiche di oggi';

  @override
  String get homeCravingsResisted => 'Voglie\nresistite';

  @override
  String get homeMinutesGainedToday => 'Minuti di vita\nguadagnati oggi';

  @override
  String get achievementCategoryAll => 'Tutti';

  @override
  String get achievementCategoryHealth => 'Salute';

  @override
  String get achievementCategoryTime => 'Tempo';

  @override
  String get achievementCategorySavings => 'Risparmi';

  @override
  String get achievementCategoryHabits => 'Abitudini';

  @override
  String get achievementUnlocked => 'Sbloccato!';

  @override
  String get achievementInProgress => 'In corso';

  @override
  String get achievementCompleted => 'Completato';

  @override
  String get achievementCurrentProgress => 'Il tuo progresso attuale';

  @override
  String achievementLevel(int level) {
    return 'Livello $level';
  }

  @override
  String achievementDaysWithoutSmoking(int days) {
    return '$days giorni senza fumare';
  }

  @override
  String achievementNextLevel(String time) {
    return 'Prossimo livello: $time';
  }

  @override
  String get achievementBenefitCO2 => 'CO2 normale';

  @override
  String get achievementBenefitTaste => 'Gusto migliorato';

  @override
  String get achievementBenefitCirculation => 'Circolazione +15%';

  @override
  String get achievementFirstDay => 'Primo Giorno';

  @override
  String get achievementFirstDayDescription => 'Completa 24 ore senza fumare';

  @override
  String get achievementOneWeek => 'Una settimana';

  @override
  String get achievementOneWeekDescription => 'Una settimana senza fumare!';

  @override
  String get achievementImprovedCirculation => 'Circolazione migliorata';

  @override
  String get achievementImprovedCirculationDescription => 'Livelli di ossigeno normalizzati';

  @override
  String get achievementInitialSavings => 'Risparmi iniziali';

  @override
  String get achievementInitialSavingsDescription => 'Risparmia l\'equivalente di 1 pacchetto di sigarette';

  @override
  String get achievementTwoWeeks => 'Due settimane';

  @override
  String get achievementTwoWeeksDescription => 'Due settimane complete senza fumare!';

  @override
  String get achievementSubstantialSavings => 'Risparmi sostanziali';

  @override
  String get achievementSubstantialSavingsDescription => 'Risparmia l\'equivalente di 10 pacchetti di sigarette';

  @override
  String get achievementCleanBreathing => 'Respirazione pulita';

  @override
  String get achievementCleanBreathingDescription => 'Capacità polmonare aumentata del 30%';

  @override
  String get achievementOneMonth => 'Un mese';

  @override
  String get achievementOneMonthDescription => 'Un intero mese senza fumare!';

  @override
  String get achievementNewHabitExercise => 'Nuova abitudine: Esercizio';

  @override
  String get achievementNewHabitExerciseDescription => 'Registra 5 giorni di esercizio fisico';

  @override
  String percentCompleted(int percent) {
    return '$percent% completato';
  }

  @override
  String get appName => 'NicotinaAI';

  @override
  String get welcomeBack => 'Bentornato';

  @override
  String get loginToContinue => 'Accedi per continuare';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'esempio@email.com';

  @override
  String get password => 'Password';

  @override
  String get rememberMe => 'Ricordami';

  @override
  String get forgotPassword => 'Password dimenticata';

  @override
  String get login => 'Accedi';

  @override
  String get noAccount => 'Non hai un account?';

  @override
  String get register => 'Registrati';

  @override
  String get emailRequired => 'Inserisci la tua email';

  @override
  String get emailInvalid => 'Inserisci un\'email valida';

  @override
  String get passwordRequired => 'Inserisci la tua password';

  @override
  String get settings => 'Impostazioni';

  @override
  String get home => 'Home';

  @override
  String get achievements => 'Traguardi';

  @override
  String get profile => 'Profilo';

  @override
  String get editProfile => 'Modifica profilo';

  @override
  String get appSettings => 'Impostazioni app';

  @override
  String get notifications => 'Notifiche';

  @override
  String get manageNotifications => 'Gestisci le notifiche';

  @override
  String get language => 'Lingua';

  @override
  String get changeLanguage => 'Cambia la lingua dell\'app';

  @override
  String get theme => 'Tema';

  @override
  String get dark => 'Scuro';

  @override
  String get light => 'Chiaro';

  @override
  String get system => 'Sistema';

  @override
  String get habitTracking => 'Monitoraggio abitudini';

  @override
  String get cigarettesPerDay => 'Sigarette al giorno prima di smettere';

  @override
  String get configureHabits => 'Configura le tue abitudini precedenti';

  @override
  String get packPrice => 'Prezzo del pacchetto';

  @override
  String get setPriceForCalculations => 'Imposta il prezzo per i calcoli del risparmio';

  @override
  String get startDate => 'Data di inizio';

  @override
  String get whenYouQuitSmoking => 'Quando hai smesso di fumare';

  @override
  String get account => 'Account';

  @override
  String get resetPassword => 'Reimposta password';

  @override
  String get changePassword => 'Cambia la tua password di accesso';

  @override
  String get deleteAccount => 'Elimina account';

  @override
  String get permanentlyRemoveAccount => 'Rimuovi definitivamente il tuo account';

  @override
  String get deleteAccountTitle => 'Elimina account';

  @override
  String get deleteAccountConfirmation => 'Sei sicuro di voler eliminare il tuo account? Questa azione è irreversibile e tutti i tuoi dati andranno persi.';

  @override
  String get logout => 'Esci';

  @override
  String get logoutFromAccount => 'Disconnettiti dal tuo account';

  @override
  String get logoutTitle => 'Esci';

  @override
  String get logoutConfirmation => 'Sei sicuro di voler uscire dal tuo account?';

  @override
  String get about => 'Informazioni';

  @override
  String get privacyPolicy => 'Informativa sulla privacy';

  @override
  String get readPrivacyPolicy => 'Leggi la nostra informativa sulla privacy';

  @override
  String get termsOfUse => 'Termini di utilizzo';

  @override
  String get viewTermsOfUse => 'Visualizza i termini di utilizzo dell\'app';

  @override
  String get aboutApp => 'Informazioni sull\'app';

  @override
  String get appInfo => 'Versione e informazioni sull\'app';

  @override
  String version(String version) {
    return 'Versione $version';
  }

  @override
  String get cancel => 'Annulla';

  @override
  String get confirm => 'Conferma';

  @override
  String get save => 'Salva';

  @override
  String get delete => 'Elimina';

  @override
  String get next => 'Avanti';

  @override
  String get back => 'Indietro';

  @override
  String get finish => 'Fine';

  @override
  String get cigarettesPerDayQuestion => 'Quante sigarette fumi al giorno?';

  @override
  String get cigarettesPerDaySubtitle => 'Questo ci aiuta a capire il tuo livello di consumo';

  @override
  String get exactNumber => 'Numero esatto: ';

  @override
  String get selectConsumptionLevel => 'O seleziona il tuo livello di consumo:';

  @override
  String get low => 'Basso';

  @override
  String get moderate => 'Moderato';

  @override
  String get high => 'Alto';

  @override
  String get veryHigh => 'Molto alto';

  @override
  String get upTo5 => 'Fino a 5 sigarette al giorno';

  @override
  String get sixTo15 => 'Da 6 a 15 sigarette al giorno';

  @override
  String get sixteenTo25 => 'Da 16 a 25 sigarette al giorno';

  @override
  String get moreThan25 => 'Più di 25 sigarette al giorno';

  @override
  String get selectConsumptionLevelError => 'Seleziona il tuo livello di consumo';

  @override
  String get welcomeToNicotinaAI => 'Benvenuto in NicotinaAI';

  @override
  String get personalAssistant => 'Il tuo assistente personale per smettere di fumare';

  @override
  String get start => 'Inizia';

  @override
  String get breatheFreedom => 'RESPIRA LIBERTÀ. LA TUA NUOVA VITA INIZIA ORA.';

  @override
  String get personalizeExperience => 'Personalizziamo la tua esperienza per aiutarti a raggiungere i tuoi obiettivi di smettere di fumare. Rispondi ad alcune domande per iniziare.';

  @override
  String get cigarettesPerPackQuestion => 'Quante sigarette ci sono in un pacchetto?';

  @override
  String get selectStandardAmount => 'Seleziona la quantità standard per i tuoi pacchetti di sigarette';

  @override
  String get packSizesInfo => 'I pacchetti di sigarette in genere contengono 10 o 20 unità. Seleziona la quantità che corrisponde ai pacchetti che acquisti.';

  @override
  String get tenCigarettes => '10 sigarette';

  @override
  String get twentyCigarettes => '20 sigarette';

  @override
  String get smallPack => 'Pacchetto piccolo/compatto';

  @override
  String get standardPack => 'Pacchetto standard/tradizionale';

  @override
  String get otherQuantity => 'Altra quantità';

  @override
  String get selectCustomValue => 'Seleziona un valore personalizzato';

  @override
  String get quantity => 'Quantità: ';

  @override
  String get packSizeHelp => 'Questa informazione ci aiuta a calcolare con precisione il tuo consumo e i benefici della riduzione o cessazione del fumo.';

  @override
  String get packPriceQuestion => 'Quanto costa un pacchetto di sigarette?';

  @override
  String get helpCalculateFinancial => 'Questo ci aiuta a calcolare i tuoi risparmi economici';

  @override
  String get enterAveragePrice => 'Inserisci il prezzo medio che paghi per un pacchetto di sigarette.';

  @override
  String get priceHelp => 'Questa informazione ci aiuta a mostrarti quanto risparmierai riducendo o smettendo di fumare.';

  @override
  String get productTypeQuestion => 'Che tipo di prodotto consumi?';

  @override
  String get selectApplicable => 'Seleziona ciò che si applica a te';

  @override
  String get helpPersonalizeStrategy => 'Questo ci aiuta a personalizzare strategie e raccomandazioni per il tuo caso specifico.';

  @override
  String get cigaretteOnly => 'Solo sigarette tradizionali';

  @override
  String get traditionalCigarettes => 'Sigarette di tabacco convenzionali';

  @override
  String get vapeOnly => 'Solo sigarette elettroniche/vape';

  @override
  String get electronicDevices => 'Dispositivi elettronici per svapo';

  @override
  String get both => 'Entrambi';

  @override
  String get useBoth => 'Uso sia sigarette tradizionali che elettroniche';

  @override
  String get productTypeHelp => 'Prodotti diversi contengono quantità diverse di nicotina e potrebbero richiedere strategie distinte per la riduzione o cessazione.';

  @override
  String get pleaseSelectProductType => 'Seleziona un tipo di prodotto';

  @override
  String get goalQuestion => 'Qual è il tuo obiettivo?';

  @override
  String get selectGoal => 'Seleziona ciò che vuoi raggiungere';

  @override
  String get goalExplanation => 'Stabilire un obiettivo chiaro è essenziale per il tuo successo. Vogliamo aiutarti a raggiungere ciò che desideri.';

  @override
  String get reduceConsumption => 'Ridurre il consumo';

  @override
  String get reduceDescription => 'Voglio fumare meno sigarette e avere più controllo sull\'abitudine';

  @override
  String get reduce => 'Ridurre';

  @override
  String get quitSmoking => 'Smettere di fumare';

  @override
  String get quitDescription => 'Voglio smettere completamente con le sigarette e vivere libero dal tabacco';

  @override
  String get quit => 'Smettere';

  @override
  String get goalHelp => 'Adatteremo le nostre risorse e raccomandazioni in base al tuo obiettivo. Puoi modificarlo in seguito se cambi idea.';

  @override
  String get pleaseSelectGoal => 'Seleziona un obiettivo';

  @override
  String get timelineQuestionReduce => 'Quando vuoi ridurre il consumo?';

  @override
  String get timelineQuestionQuit => 'Quando vuoi smettere di fumare?';

  @override
  String get establishDeadline => 'Stabilisci una scadenza che ti sembra raggiungibile';

  @override
  String get timelineExplanation => 'Una timeline realistica aumenta le tue possibilità di successo. Scegli una scadenza con cui ti senti a tuo agio.';

  @override
  String get sevenDays => '7 giorni';

  @override
  String get sevenDaysDescription => 'Voglio risultati rapidi e sono motivato';

  @override
  String get fourteenDays => '14 giorni';

  @override
  String get fourteenDaysDescription => 'Un periodo equilibrato per cambiare abitudine';

  @override
  String get thirtyDays => '30 giorni';

  @override
  String get thirtyDaysDescription => 'Un mese per un cambiamento graduale e sostenibile';

  @override
  String get noDeadline => 'Nessuna scadenza';

  @override
  String get noDeadlineDescription => 'Preferisco procedere al mio ritmo';

  @override
  String get timelineHelp => 'Non preoccuparti se non raggiungi il tuo obiettivo esattamente secondo il programma. Il progresso continuo è ciò che conta.';

  @override
  String get pleaseSelectTimeline => 'Seleziona una timeline';

  @override
  String challengeQuestion(String goalText) {
    return 'Cosa rende difficile $goalText per te?';
  }

  @override
  String get identifyChallenge => 'Identificare la tua sfida principale ci aiuta a fornirti un supporto migliore';

  @override
  String get challengeExplanation => 'Capire cosa rende difficile smettere con le sigarette è il primo passo per superare quell\'ostacolo.';

  @override
  String get stressAnxiety => 'Stress e ansia';

  @override
  String get stressDescription => 'Fumo per affrontare situazioni stressanti e l\'ansia';

  @override
  String get habitStrength => 'Forza dell\'abitudine';

  @override
  String get habitDescription => 'Fumare è già parte della mia routine quotidiana';

  @override
  String get socialInfluence => 'Influenza sociale';

  @override
  String get socialDescription => 'Le persone intorno a me fumano o mi incoraggiano a fumare';

  @override
  String get physicalDependence => 'Dipendenza fisica';

  @override
  String get dependenceDescription => 'Provo sintomi fisici quando resto senza fumare';

  @override
  String get challengeHelp => 'Le tue risposte ci aiutano a personalizzare consigli e strategie più efficaci per il tuo caso specifico.';

  @override
  String get pleaseSelectChallenge => 'Seleziona una sfida';

  @override
  String get locationsQuestion => 'Dove fumi solitamente?';

  @override
  String get selectCommonPlaces => 'Seleziona i luoghi dove fumi più spesso';

  @override
  String get locationsExplanation => 'Conoscere i tuoi luoghi abituali ci aiuta a identificare schemi e creare strategie specifiche.';

  @override
  String get atHome => 'A casa';

  @override
  String get homeDetails => 'Balcone, soggiorno, ufficio';

  @override
  String get atWork => 'Al lavoro/scuola';

  @override
  String get workDetails => 'Durante le pause';

  @override
  String get inCar => 'In auto/trasporto';

  @override
  String get carDetails => 'Durante i viaggi';

  @override
  String get socialEvents => 'In eventi sociali';

  @override
  String get socialDetails => 'Bar, feste, ristoranti';

  @override
  String get outdoors => 'All\'aperto';

  @override
  String get outdoorsDetails => 'Parchi, marciapiedi, aree all\'aperto';

  @override
  String get otherPlaces => 'Altri luoghi';

  @override
  String get otherPlacesDetails => 'Quando sono ansioso, indipendentemente dal luogo';

  @override
  String get locationsHelp => 'Identificare i luoghi più comuni aiuta a evitare i fattori scatenanti e a creare strategie per cambiare abitudine.';

  @override
  String get continueButton => 'Continua';

  @override
  String get allDone => 'Tutto fatto!';

  @override
  String get personalizedJourney => 'Il tuo percorso personalizzato inizia ora';

  @override
  String get startMyJourney => 'Inizia il mio percorso';

  @override
  String get congratulations => 'Congratulazioni per aver fatto il primo passo!';

  @override
  String personalizedPlanReduce(String timelineText) {
    return 'Abbiamo creato un piano personalizzato basato sulle tue risposte per aiutarti a ridurre il consumo $timelineText.';
  }

  @override
  String personalizedPlanQuit(String timelineText) {
    return 'Abbiamo creato un piano personalizzato basato sulle tue risposte per aiutarti a smettere di fumare $timelineText.';
  }

  @override
  String get yourPersonalizedSummary => 'Il tuo riepilogo personalizzato';

  @override
  String get dailyConsumption => 'Consumo giornaliero';

  @override
  String cigarettesPerDayValue(int count) {
    return '$count sigarette al giorno';
  }

  @override
  String get potentialMonthlySavings => 'Potenziali risparmi mensili';

  @override
  String get yourGoal => 'Il tuo obiettivo';

  @override
  String get mainChallenge => 'La tua sfida principale';

  @override
  String get personalized => 'Monitoraggio personalizzato';

  @override
  String get personalizedDescription => 'Monitora i tuoi progressi in base alle tue abitudini';

  @override
  String get importantAchievements => 'Traguardi importanti';

  @override
  String get achievementsDescription => 'Celebra ogni pietra miliare nel tuo percorso';

  @override
  String get supportWhenNeeded => 'Supporto quando ne hai bisogno';

  @override
  String get supportDescription => 'Consigli e strategie per momenti difficili';

  @override
  String get guaranteedResults => 'Risultati garantiti';

  @override
  String get resultsDescription => 'Con la nostra tecnologia basata sulla scienza';

  @override
  String loadingError(String error) {
    return 'Errore di completamento: $error';
  }

  @override
  String get developer => 'Sviluppatore';

  @override
  String get developerMode => 'Modalità sviluppatore';

  @override
  String get enableDebugging => 'Abilita debug e tracciamento dettagliati';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get viewDetailedTracking => 'Visualizza dashboard di tracciamento dettagliata';

  @override
  String get currency => 'Valuta';

  @override
  String get changeCurrency => 'Cambia valuta';

  @override
  String get setCurrencyForCalculations => 'Imposta la valuta per i calcoli del risparmio';

  @override
  String get search => 'Cerca';

  @override
  String get noResults => 'Nessun risultato trovato';

  @override
  String get listView => 'Vista a lista';

  @override
  String get gridView => 'Vista a griglia';

  @override
  String get atYourOwnPace => 'al tuo ritmo';

  @override
  String get nextSevenDays => 'nei prossimi 7 giorni';

  @override
  String get nextTwoWeeks => 'nelle prossime 2 settimane';

  @override
  String get nextMonth => 'nel prossimo mese';

  @override
  String get notSpecified => 'Non specificato';

  @override
  String get registerCraving => 'Registra voglia';

  @override
  String get registerCravingSubtitle => 'Tieni traccia quando senti l\'impulso';

  @override
  String get newRecord => 'Nuovo record';

  @override
  String get newRecordSubtitle => 'Registra quando fumi';

  @override
  String get whereAreYou => 'Dove sei?';

  @override
  String get work => 'Lavoro';

  @override
  String get car => 'Auto';

  @override
  String get restaurant => 'Ristorante';

  @override
  String get bar => 'Bar';

  @override
  String get street => 'Strada';

  @override
  String get park => 'Parco';

  @override
  String get others => 'Altri';

  @override
  String get notes => 'Note (opzionale)';

  @override
  String get howAreYouFeeling => 'Come ti senti?';

  @override
  String get whatTriggeredCraving => 'Cosa ha scatenato la tua voglia?';

  @override
  String get stress => 'Stress';

  @override
  String get boredom => 'Noia';

  @override
  String get socialSituation => 'Situazione sociale';

  @override
  String get afterMeal => 'Dopo un pasto';

  @override
  String get coffee => 'Caffè';

  @override
  String get alcohol => 'Alcol';

  @override
  String get craving => 'Voglia';

  @override
  String get other => 'Altro';

  @override
  String get intensityLevel => 'Livello di intensità';

  @override
  String get mild => 'Lieve';

  @override
  String get intense => 'Intenso';

  @override
  String get veryIntense => 'Molto intenso';

  @override
  String get pleaseSelectLocation => 'Seleziona la tua posizione';

  @override
  String get pleaseSelectTrigger => 'Seleziona cosa ha scatenato la tua voglia';

  @override
  String get pleaseSelectIntensity => 'Seleziona il livello di intensità';

  @override
  String get whatsTheReason => 'Qual è il motivo?';

  @override
  String get anxiety => 'Ansia';

  @override
  String get pleaseSelectReason => 'Seleziona un motivo';

  @override
  String get howDoYouFeel => 'Come ti senti? Cosa avresti potuto fare diversamente?';

  @override
  String get didYouResist => 'Hai resistito?';

  @override
  String get yes => 'Sì';

  @override
  String get no => 'No';

  @override
  String get howMuchDidYouSmoke => 'Quanto hai fumato?';

  @override
  String get oneOrLess => '1 o meno';

  @override
  String get twoToFive => '2-5';

  @override
  String get moreThanFive => 'Più di 5';

  @override
  String get pleaseSelectAmount => 'Seleziona quanto hai fumato';

  @override
  String get howLongDidItLast => 'Quanto è durato?';

  @override
  String get lessThan5min => 'Meno di 5 min';

  @override
  String get fiveToFifteenMin => '5-15 min';

  @override
  String get moreThan15min => 'Più di 15 min';

  @override
  String get pleaseSelectDuration => 'Seleziona quanto è durato';

  @override
  String get selectCurrency => 'Seleziona la tua valuta';

  @override
  String get selectCurrencySubtitle => 'Scegli la valuta per i calcoli finanziari';

  @override
  String get preselectedCurrency => 'Abbiamo preselezionato la tua valuta locale. Puoi cambiarla se necessario.';

  @override
  String get pleaseCompleteAllFields => 'Completa tutti i campi obbligatori per continuare';

  @override
  String get understood => 'Capito';

  @override
  String get commonPrices => 'Prezzi comuni dei pacchetti';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get errorLoadingNotifications => 'Errore nel caricamento delle notifiche';

  @override
  String get noNotificationsYet => 'Ancora nessuna notifica!';

  @override
  String get emptyNotificationsDescription => 'Continua a utilizzare l\'app per ricevere messaggi motivazionali e traguardi.';

  @override
  String get motivationalMessage => 'Messaggio motivazionale';

  @override
  String claimReward(int xp) {
    return 'Riscatta $xp XP';
  }

  @override
  String rewardClaimed(int xp) {
    return 'Ricompensa riscattata: $xp XP';
  }

  @override
  String get dailyMotivation => 'Motivazione quotidiana';

  @override
  String get dailyMotivationDescription => 'La tua motivazione quotidiana personalizzata è qui. Apri per ottenere la tua ricompensa XP!';

  @override
  String get retry => 'Riprova';

  @override
  String get cravingResistedRecorded => 'Voglia resistita registrata con successo!';

  @override
  String get cravingRecorded => 'Voglia registrata con successo!';

  @override
  String get errorSavingCraving => 'Errore nel salvare la voglia. Tocca per riprovare.';

  @override
  String get recordSaved => 'Record salvato con successo!';

  @override
  String get tapToRetry => 'Tocca per riprovare';

  @override
  String get syncError => 'Errore di sincronizzazione';

  @override
  String get loading => 'Caricamento...';

  @override
  String get tryAgain => 'Riprova';

  @override
  String get errorLoadingData => 'Errore nel caricamento dei dati';

  @override
  String get noRecoveriesFound => 'Nessun recupero di salute trovato';

  @override
  String get noRecentRecoveries => 'Nessun recupero di salute recente da visualizzare';

  @override
  String get viewAllRecoveries => 'Visualizza tutti i recuperi di salute';

  @override
  String get healthRecovery => 'Recupero della salute';

  @override
  String get seeAll => 'Vedi tutti';

  @override
  String get achieved => 'Raggiunto';

  @override
  String get progress => 'Progresso';

  @override
  String daysToAchieve(int days) {
    return '$days giorni per raggiungere';
  }

  @override
  String daysRemaining(int days) {
    return '$days giorni rimanenti';
  }

  @override
  String achievedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Raggiunto il $dateString';
  }

  @override
  String daysSmokeFree(int days) {
    return '$days giorni senza fumo';
  }

  @override
  String get keepGoing => 'Continua così!';

  @override
  String get encouragementMessage => 'Stai facendo grandi progressi. Ogni giorno senza fumare ti avvicina al raggiungimento di questo traguardo di salute.';

  @override
  String get recoveryAchievedMessage => 'Il tuo corpo si è già ripreso in quest\'area. Continua così per mantenere e migliorare ulteriormente la tua salute.';

  @override
  String get scienceBehindIt => 'La scienza dietro';

  @override
  String get generalHealthScienceInfo => 'Quando smetti di fumare, il tuo corpo inizia una serie di processi di guarigione. Questi iniziano entro pochi minuti dall\'ultima sigaretta e continuano per anni, ripristinando gradualmente la tua salute a quella di un non fumatore.';

  @override
  String get tasteScienceInfo => 'Quando fumi, le sostanze chimiche nel tabacco danneggiano le papille gustative e riducono la tua capacità di gustare i sapori. Dopo solo pochi giorni senza fumare, questi recettori del gusto iniziano a guarire, permettendoti di sperimentare più sapori e goderti maggiormente il cibo.';

  @override
  String get smellScienceInfo => 'Il fumo danneggia i nervi olfattivi che trasmettono le informazioni sull\'odore al cervello. Entro pochi giorni dall\'interruzione, questi nervi iniziano a riprendersi, migliorando gradualmente il tuo senso dell\'olfatto e permettendoti di percepire odori più sottili.';

  @override
  String get bloodOxygenScienceInfo => 'Il monossido di carbonio delle sigarette si lega all\'emoglobina nel sangue, riducendo la sua capacità di trasportare ossigeno. Entro 12-24 ore dall\'interruzione, i livelli di monossido di carbonio diminuiscono drasticamente, permettendo al sangue di trasportare l\'ossigeno in modo più efficace.';

  @override
  String get carbonMonoxideScienceInfo => 'Il fumo di sigaretta contiene monossido di carbonio, che sostituisce l\'ossigeno nel sangue. Entro 12 ore dall\'interruzione, i livelli di monossido di carbonio tornano alla normalità e i livelli di ossigeno nel corpo aumentano significativamente.';

  @override
  String get nicotineScienceInfo => 'La nicotina ha un\'emivita di circa 2 ore, il che significa che occorrono circa 72 ore (3 giorni) affinché tutta la nicotina venga eliminata dal corpo. Una volta che la nicotina è scomparsa, i sintomi di astinenza fisica iniziano a diminuire.';

  @override
  String get improvedBreathingScienceInfo => 'Dopo 7 giorni senza fumare, la funzione polmonare inizia a migliorare poiché l\'infiammazione diminuisce e i polmoni iniziano a eliminare il muco accumulato. Noterai meno tosse e respirazione più facile, specialmente durante l\'attività fisica.';

  @override
  String get improvedCirculationScienceInfo => 'Dopo due settimane senza fumare, la circolazione migliora significativamente. I vasi sanguigni si dilatano, la pressione sanguigna si normalizza e più ossigeno raggiunge i muscoli e gli organi, rendendo l\'attività fisica più facile e meno faticosa.';

  @override
  String get decreasedCoughingScienceInfo => 'Un mese dopo aver smesso, le cilia (piccole strutture simili a peli) nei polmoni iniziano a ricrescere. Queste aiutano a pulire i polmoni e ridurre le infezioni. La tosse e la mancanza di respiro continuano a diminuire.';

  @override
  String get lungCiliaScienceInfo => 'Dopo 3 mesi senza fumare, la funzione polmonare può migliorare fino al 30%. Le cilia nei polmoni sono in gran parte ricresciute, migliorando la capacità dei polmoni di auto-pulizia, combattere le infezioni e ridurre il muco.';

  @override
  String get reducedHeartDiseaseRiskScienceInfo => 'Dopo un anno senza fumare, il rischio di malattie coronariche diminuisce a circa la metà di quello di un fumatore. La funzione cardiaca continua a migliorare man mano che i vasi sanguigni guariscono e la circolazione migliora.';

  @override
  String get viewHealthRecoveries => 'Visualizza recuperi di salute';

  @override
  String get recoveryNotFound => 'Recupero di salute non trovato';

  @override
  String get trackYourHealthJourney => 'Monitora il tuo percorso di salute';

  @override
  String get healthRecoveryDescription => 'Vedi come il tuo corpo guarisce dopo aver smesso di fumare';

  @override
  String get somethingWentWrong => 'Qualcosa è andato storto, riprova';

  @override
  String get profileInformation => 'Informazioni profilo';

  @override
  String get editProfileDescription => 'Aggiorna le informazioni del tuo profilo qui sotto.';

  @override
  String get enterName => 'Inserisci il tuo nome';

  @override
  String get profileUpdatedSuccessfully => 'Profilo aggiornato con successo';

  @override
  String get comingSoon => 'Prossimamente';

  @override
  String get registerFirstCigarette => 'Registra la tua prima sigaretta per vedere il recupero della salute';

  @override
  String get errorOccurred => 'Si è verificato un errore';

  @override
  String get pageNotFound => 'Pagina non trovata';

  @override
  String get resetLinkSent => 'Link di reset inviato!';

  @override
  String get checkEmailInstructions => 'Controlla la tua email per le istruzioni su come reimpostare la password.';

  @override
  String get backToLogin => 'Torna al login';

  @override
  String get forgotPasswordInstructions => 'Inserisci il tuo indirizzo email e ti invieremo le istruzioni per reimpostare la password.';

  @override
  String get sendResetLink => 'Invia link di reset';

  @override
  String get createAccount => 'Crea account';

  @override
  String get fillInformation => 'Inserisci le tue informazioni per creare un account';

  @override
  String get name => 'Nome';

  @override
  String get nameRequired => 'Inserisci il tuo nome';

  @override
  String get passwordTooShort => 'La password deve contenere almeno 6 caratteri';

  @override
  String get confirmPassword => 'Conferma password';

  @override
  String get confirmPasswordRequired => 'Conferma la tua password';

  @override
  String get passwordsDoNotMatch => 'Le password non corrispondono';

  @override
  String get termsConditionsAgree => 'Accetto i Termini e Condizioni';

  @override
  String get termsConditionsRequired => 'Accetta i Termini e Condizioni per continuare';

  @override
  String get alreadyAccount => 'Hai già un account?';

  @override
  String get currentPassword => 'Password attuale';

  @override
  String get newPassword => 'Nuova password';

  @override
  String get changePasswordDescription => 'Inserisci la tua password attuale e una nuova password per aggiornare le tue credenziali di accesso.';

  @override
  String get passwordChangedSuccessfully => 'Password cambiata con successo';

  @override
  String get forgotPasswordTitle => 'Hai dimenticato la password?';

  @override
  String get forgotPasswordSubtitle => 'Possiamo inviarti un link per reimpostare la password via email.';

  @override
  String get deleteAccountWarningTitle => 'Questa azione non può essere annullata';

  @override
  String get deleteAccountWarning => 'Tutti i tuoi dati, inclusi cronologia di tracciamento, traguardi e impostazioni saranno eliminati definitivamente. Questa azione non può essere annullata.';

  @override
  String get confirmDeleteAccount => 'Capisco che è permanente';

  @override
  String get confirmDeleteAccountSubtitle => 'Capisco che tutti i miei dati saranno eliminati permanentemente e non potranno essere recuperati.';

  @override
  String get confirmDeleteRequired => 'Conferma di aver compreso che questa azione è permanente.';

  @override
  String get accountDeleted => 'Il tuo account è stato eliminato con successo.';

  @override
  String get changeDate => 'Cambia data';

  @override
  String get selectDate => 'Seleziona data';

  @override
  String get clearDate => 'Cancella data';

  @override
  String get suggestedDates => 'Date suggerite';

  @override
  String get today => 'Oggi';

  @override
  String get yesterday => 'Ieri';

  @override
  String get oneWeekAgo => 'Una settimana fa';

  @override
  String get twoWeeksAgo => 'Due settimane fa';

  @override
  String get oneMonthAgo => 'Un mese fa';

  @override
  String get feedbackTitle => 'Apprezziamo il tuo feedback';

  @override
  String get skip => 'Salta';

  @override
  String get howIsYourExperience => 'Com\'è la tua esperienza?';

  @override
  String get enjoyingApp => 'Ti sta piacendo l\'app?';

  @override
  String get notReally => 'Non molto';

  @override
  String get yesImEnjoying => 'Sì, mi piace!';

  @override
  String get yesILikeIt => 'Sì, mi piace!';

  @override
  String get rateApp => 'Come valuti l\'app?';

  @override
  String get howWouldYouRateApp => 'Come valuteresti la nostra app?';

  @override
  String get yourOpinionMatters => 'La tua opinione è importante per noi';

  @override
  String get weAreConstantlyImproving => 'Miglioriamo costantemente la nostra app in base al feedback degli utenti';

  @override
  String get later => 'Più tardi';

  @override
  String get tellUsIssues => 'Dicci cosa non va bene';

  @override
  String get helpUsImprove => 'Aiutaci a migliorare dicendoci cosa possiamo fare meglio:';

  @override
  String get feedbackCategory => 'Categoria di feedback';

  @override
  String get interface => 'Interfaccia';

  @override
  String get features => 'Funzionalità';

  @override
  String get performance => 'Prestazioni';

  @override
  String get statisticsAccuracy => 'Precisione delle statistiche';

  @override
  String get accuracyOfStatistics => 'Precisione delle statistiche';

  @override
  String get yourFeedback => 'Il tuo feedback';

  @override
  String get describeProblem => 'Descrivi cosa possiamo migliorare...';

  @override
  String get describeWhatToImprove => 'Descrivi cosa potremmo migliorare...';

  @override
  String get whatCouldBeBetter => 'Cosa potrebbe essere migliore?';

  @override
  String get sendFeedback => 'Invia feedback';

  @override
  String get thankYouForFeedback => 'Apprezziamo il tuo feedback!';

  @override
  String get gladYouLikeIt => 'Siamo felici che ti piaccia!';

  @override
  String get wouldYouRateOnStore => 'Vorresti valutarci sull\'app store?';

  @override
  String get rateAppStore => 'Vorresti valutare l\'app nello store?';

  @override
  String get alreadyRated => 'Ho già valutato';

  @override
  String get rateNow => 'Valuta ora';

  @override
  String get feedbackError => 'Ops, qualcosa è andato storto';

  @override
  String get couldNotSaveFeedback => 'Impossibile salvare il tuo feedback';

  @override
  String get understand => 'Capisco';

  @override
  String get stayInformed => 'Resta informato';

  @override
  String get receiveTimelyCues => 'Ricevi suggerimenti tempestivi e informazioni importanti';

  @override
  String get importantReminders => 'PROMEMORIA IMPORTANTI PER IL TUO PERCORSO';

  @override
  String get notificationsHelp => 'Le notifiche forniscono promemoria tempestivi, motivazione e avvisi importanti sui traguardi per aiutarti a rimanere in linea con il tuo obiettivo.';

  @override
  String get allowNotifications => 'Consenti notifiche';

  @override
  String get notificationsEnabled => 'Notifiche abilitate con successo!';

  @override
  String get notificationPermissionFailed => 'C\'è stato un problema nell\'abilitare le notifiche';

  @override
  String get requesting => 'Richiedendo...';

  @override
  String get skipForNow => 'Salta per ora';

  @override
  String get onboardingLoadError => 'Errore nel caricamento dell\'onboarding';

  @override
  String get unknownError => 'Errore sconosciuto';
}
