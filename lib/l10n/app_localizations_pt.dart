// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String homeDaysWithoutSmoking(int days) {
    return '$days dias sem fumar';
  }

  @override
  String homeGreeting(String name) {
    return 'Olá, $name! 👋';
  }

  @override
  String get homeHealthRecovery => 'Recuperação da Saúde';

  @override
  String get homeTaste => 'Paladar';

  @override
  String get homeSmell => 'Olfato';

  @override
  String get homeCirculation => 'Circulação';

  @override
  String get homeLungs => 'Pulmões';

  @override
  String get homeHeart => 'Coração';

  @override
  String get homeMinutesLifeGained => 'minutos de vida\nganhos';

  @override
  String get homeLungCapacity => 'capacidade\npulmonar';

  @override
  String get homeNextMilestone => 'Próximo Marco';

  @override
  String homeNextMilestoneDescription(int days) {
    return 'Em $days dias: Fluxo sanguíneo melhora';
  }

  @override
  String get homeRecentAchievements => 'Conquistas Recentes';

  @override
  String get homeSeeAll => 'Ver todas';

  @override
  String get homeFirstDay => 'Primeiro Dia';

  @override
  String get homeFirstDayDescription => 'Você passou 24 horas sem fumar!';

  @override
  String get homeOvercoming => 'Superando';

  @override
  String get homeOvercomingDescription => 'Níveis de nicotina eliminados do corpo';

  @override
  String get homePersistence => 'Persistência';

  @override
  String get homePersistenceDescription => 'Uma semana inteira sem cigarros!';

  @override
  String get homeTodayStats => 'Estatísticas de Hoje';

  @override
  String get homeCravingsResisted => 'Desejos\nResistidos';

  @override
  String get homeMinutesGainedToday => 'Minutos de Vida\nGanhos Hoje';

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
  String get welcomeBack => 'Bem-vindo de volta';

  @override
  String get loginToContinue => 'Faça login para continuar';

  @override
  String get email => 'E-mail';

  @override
  String get emailHint => 'exemplo@email.com';

  @override
  String get password => 'Senha';

  @override
  String get rememberMe => 'Lembrar-me';

  @override
  String get forgotPassword => 'Esqueci a senha';

  @override
  String get login => 'Entrar';

  @override
  String get noAccount => 'Não tem uma conta?';

  @override
  String get register => 'Registre-se';

  @override
  String get emailRequired => 'Por favor, insira seu e-mail';

  @override
  String get emailInvalid => 'Por favor, insira um e-mail válido';

  @override
  String get passwordRequired => 'Por favor, insira sua senha';

  @override
  String get settings => 'Configurações';

  @override
  String get home => 'Início';

  @override
  String get achievements => 'Conquistas';

  @override
  String get profile => 'Perfil';

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get appSettings => 'Configurações do Aplicativo';

  @override
  String get notifications => 'Notificações';

  @override
  String get manageNotifications => 'Gerenciar notificações';

  @override
  String get language => 'Idioma';

  @override
  String get changeLanguage => 'Alterar o idioma do aplicativo';

  @override
  String get theme => 'Tema';

  @override
  String get dark => 'Escuro';

  @override
  String get light => 'Claro';

  @override
  String get system => 'Sistema';

  @override
  String get habitTracking => 'Rastreamento de Hábitos';

  @override
  String get cigarettesPerDay => 'Cigarros por dia antes de parar';

  @override
  String get configureHabits => 'Configure seus hábitos anteriores';

  @override
  String get packPrice => 'Preço do maço';

  @override
  String get setPriceForCalculations => 'Definir o preço para cálculos de economia';

  @override
  String get startDate => 'Data de início';

  @override
  String get whenYouQuitSmoking => 'Quando você parou de fumar';

  @override
  String get account => 'Conta';

  @override
  String get resetPassword => 'Redefinir senha';

  @override
  String get changePassword => 'Altere sua senha de acesso';

  @override
  String get deleteAccount => 'Excluir conta';

  @override
  String get permanentlyRemoveAccount => 'Remover permanentemente sua conta';

  @override
  String get deleteAccountTitle => 'Excluir Conta';

  @override
  String get deleteAccountConfirmation => 'Tem certeza que deseja excluir sua conta? Esta ação é irreversível e todos os seus dados serão perdidos.';

  @override
  String get logout => 'Sair';

  @override
  String get logoutFromAccount => 'Desconectar da sua conta';

  @override
  String get logoutTitle => 'Sair da conta';

  @override
  String get logoutConfirmation => 'Tem certeza que deseja sair da sua conta?';

  @override
  String get about => 'Sobre';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get readPrivacyPolicy => 'Leia nossa política de privacidade';

  @override
  String get termsOfUse => 'Termos de Uso';

  @override
  String get viewTermsOfUse => 'Veja os termos de uso do aplicativo';

  @override
  String get aboutApp => 'Sobre o App';

  @override
  String get appInfo => 'Versão e informações do aplicativo';

  @override
  String version(String version) {
    return 'Versão $version';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Excluir';

  @override
  String get next => 'Próximo';

  @override
  String get back => 'Voltar';

  @override
  String get finish => 'Finalizar';

  @override
  String get cigarettesPerDayQuestion => 'Quantos cigarros você fuma por dia?';

  @override
  String get cigarettesPerDaySubtitle => 'Isso nos ajuda a entender seu nível de consumo';

  @override
  String get exactNumber => 'Número exato: ';

  @override
  String get selectConsumptionLevel => 'Ou selecione seu nível de consumo:';

  @override
  String get low => 'Baixo';

  @override
  String get moderate => 'Moderado';

  @override
  String get high => 'Alto';

  @override
  String get veryHigh => 'Muito Alto';

  @override
  String get upTo5 => 'Até 5 cigarros por dia';

  @override
  String get sixTo15 => '6 a 15 cigarros por dia';

  @override
  String get sixteenTo25 => '16 a 25 cigarros por dia';

  @override
  String get moreThan25 => 'Mais de 25 cigarros por dia';

  @override
  String get selectConsumptionLevelError => 'Por favor, selecione seu nível de consumo';
}
