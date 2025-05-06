// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

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
