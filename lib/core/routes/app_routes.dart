/// Enum que define todas as rotas do aplicativo
/// 
/// Usar este enum para manter consistência nas rotas em todo o aplicativo
/// ao invés de usar strings hardcoded.
enum AppRoutes {
  // Rota de splash/loading - ponto de entrada inicial do app
  splash('/splash'),
  
  // Rotas de autenticação
  login('/login'),
  register('/register'),
  forgotPassword('/forgot-password'),
  
  // Rota de onboarding
  onboarding('/onboarding'),
  
  // Rota principal com tabs
  main('/main'),
  
  // Rotas individuais para as tabs
  home('/home'),
  achievements('/achievements'),
  settings('/settings'),
  
  // Rotas de tracking
  developerDashboard('/developer-dashboard'),
  statisticsDashboard('/statistics-dashboard'),
  addSmokingLog('/tracking/add-smoking'),
  addCraving('/tracking/add-craving'),
  smokingLogs('/tracking/smoking-logs'),
  cravingLogs('/tracking/craving-logs'),
  
  // Outras rotas
  profile('/profile'),
  editProfile('/profile/edit'),
  notifications('/notifications'),
  language('/settings/language'),
  currency('/settings/currency'),
  currencyBloc('/settings/currency_bloc'),
  themeBloc('/settings/theme_bloc'),
  languageBloc('/settings/language_bloc'),
  developerModeBloc('/settings/developer_mode_bloc'),
  privacyPolicy('/privacy-policy'),
  termsOfService('/terms-of-service'),
  about('/about'),
  
  // Health recovery routes
  healthRecovery('/health-recovery'),
  healthRecoveryDetail('/health-recovery/:recoveryId'),
  healthRecoveryTest('/health-recovery-test'),
  
  // Achievement routes
  achievementDetail('/achievement/:achievementId');  

  /// Caminho da rota
  final String path;
  
  /// Construtor
  const AppRoutes(this.path);
  
  /// Obtém o caminho com parâmetros opcionais
  String withParams({Map<String, String>? params}) {
    if (params == null || params.isEmpty) {
      return path;
    }
    
    String result = path;
    params.forEach((key, value) {
      result = result.replaceAll(':$key', value);
    });
    
    return result;
  }
  
  @override
  String toString() => path;
}