// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get days => 'días';

  @override
  String get helpScreenTitle => '¿Cómo podemos ayudarte?';

  @override
  String get selectAllInterests => 'Selecciona todas las opciones que te interesen';

  @override
  String get helpScreenExplanation => 'Ofrecemos diferentes recursos para apoyar tu camino. Selecciona todo lo que creas que puede ayudar.';

  @override
  String get dailyTips => 'Consejos diarios';

  @override
  String get dailyTipsDescription => 'Recibe consejos prácticos todos los días para apoyar tu camino';

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
  String get supportCommunityDescription => 'Conéctate con otros en un camino similar';

  @override
  String get cigaretteAlternatives => 'Alternativas al cigarrillo';

  @override
  String get cigaretteAlternativesDescription => 'Sugerencias de actividades y productos para reemplazar el hábito';

  @override
  String get savingsCalculator => 'Calculadora de ahorro';

  @override
  String get savingsCalculatorDescription => 'Ve cuánto dinero estás ahorrando al reducir o dejar de fumar';

  @override
  String get modifyPreferencesAnytime => 'Puedes modificar estas preferencias en cualquier momento en la configuración de la aplicación.';

  @override
  String get personalizeScreenTitle => '¿Cuándo sueles fumar más?';

  @override
  String get personalizeScreenSubtitle => 'Selecciona los momentos en que sientes más deseos de fumar';

  @override
  String get afterMeals => 'Después de las comidas';

  @override
  String get duringWorkBreaks => 'Durante descansos laborales';

  @override
  String get inSocialEvents => 'En eventos sociales';

  @override
  String get whenStressed => 'Cuando estoy estresado';

  @override
  String get withCoffeeOrAlcohol => 'Cuando bebo café o alcohol';

  @override
  String get whenBored => 'Cuando estoy aburrido';

  @override
  String homeDaysWithoutSmoking(int days) {
    return '$days días sin fumar';
  }

  @override
  String homeGreeting(String name) {
    return '¡Hola, $name! 👋';
  }

  @override
  String get homeHealthRecovery => 'Recuperación de Salud';

  @override
  String get homeTaste => 'Gusto';

  @override
  String get homeSmell => 'Olfato';

  @override
  String get homeCirculation => 'Circulación';

  @override
  String get homeLungs => 'Pulmones';

  @override
  String get homeHeart => 'Corazón';

  @override
  String get homeMinutesLifeGained => 'minutos de vida\nganados';

  @override
  String get homeLungCapacity => 'capacidad\npulmonar';

  @override
  String get homeNextMilestone => 'Próximo Hito';

  @override
  String homeNextMilestoneDescription(int days) {
    return 'En $days días: Mejora el flujo sanguíneo';
  }

  @override
  String get homeRecentAchievements => 'Logros Recientes';

  @override
  String get homeSeeAll => 'Ver todos';

  @override
  String get homeFirstDay => 'Primer Día';

  @override
  String get homeFirstDayDescription => '¡Has pasado 24 horas sin fumar!';

  @override
  String get homeOvercoming => 'Superación';

  @override
  String get homeOvercomingDescription => 'Niveles de nicotina eliminados del cuerpo';

  @override
  String get homePersistence => 'Persistencia';

  @override
  String get homePersistenceDescription => '¡Una semana entera sin cigarrillos!';

  @override
  String get homeTodayStats => 'Estadísticas de Hoy';

  @override
  String get homeCravingsResisted => 'Antojos\nResistidos';

  @override
  String get homeMinutesGainedToday => 'Minutos de Vida\nGanados Hoy';

  @override
  String get achievementCategoryAll => 'Todos';

  @override
  String get achievementCategoryHealth => 'Salud';

  @override
  String get achievementCategoryTime => 'Tiempo';

  @override
  String get achievementCategorySavings => 'Ahorro';

  @override
  String get achievementCategoryHabits => 'Hábitos';

  @override
  String get achievementUnlocked => '¡Logro Desbloqueado!';

  @override
  String get achievementInProgress => 'En progreso';

  @override
  String get achievementCompleted => 'Completado';

  @override
  String get achievementCurrentProgress => 'Tu Progreso Actual';

  @override
  String achievementLevel(int level) {
    return 'Nivel $level';
  }

  @override
  String achievementDaysWithoutSmoking(int days) {
    return '$days días sin fumar';
  }

  @override
  String achievementNextLevel(String time) {
    return 'Próximo nivel: $time';
  }

  @override
  String get achievementBenefitCO2 => 'CO2 Normal';

  @override
  String get achievementBenefitTaste => 'Gusto Mejorado';

  @override
  String get achievementBenefitCirculation => 'Circulación +15%';

  @override
  String get achievementFirstDay => 'Primer Día';

  @override
  String get achievementFirstDayDescription => 'Completa 24 horas sin fumar';

  @override
  String get achievementOneWeek => 'Una Semana';

  @override
  String get achievementOneWeekDescription => '¡Una semana sin fumar!';

  @override
  String get achievementImprovedCirculation => 'Circulación Mejorada';

  @override
  String get achievementImprovedCirculationDescription => 'Niveles de oxígeno normalizados';

  @override
  String get achievementInitialSavings => 'Ahorro Inicial';

  @override
  String get achievementInitialSavingsDescription => 'Ahorra el equivalente a 1 paquete de cigarrillos';

  @override
  String get achievementTwoWeeks => 'Dos Semanas';

  @override
  String get achievementTwoWeeksDescription => '¡Dos semanas completas sin fumar!';

  @override
  String get achievementSubstantialSavings => 'Ahorro Sustancial';

  @override
  String get achievementSubstantialSavingsDescription => 'Ahorra el equivalente a 10 paquetes de cigarrillos';

  @override
  String get achievementCleanBreathing => 'Respiración Limpia';

  @override
  String get achievementCleanBreathingDescription => 'Capacidad pulmonar aumentada en un 30%';

  @override
  String get achievementOneMonth => 'Un Mes';

  @override
  String get achievementOneMonthDescription => '¡Un mes entero sin fumar!';

  @override
  String get achievementNewHabitExercise => 'Nuevo Hábito: Ejercicio';

  @override
  String get achievementNewHabitExerciseDescription => 'Registra 5 días de ejercicio';

  @override
  String percentCompleted(int percent) {
    return '$percent% completado';
  }

  @override
  String get appName => 'NicotinaAI';

  @override
  String get welcomeBack => 'Bienvenido de Nuevo';

  @override
  String get loginToContinue => 'Inicia sesión para continuar';

  @override
  String get email => 'Correo electrónico';

  @override
  String get emailHint => 'ejemplo@correo.com';

  @override
  String get password => 'Contraseña';

  @override
  String get rememberMe => 'Recordarme';

  @override
  String get forgotPassword => 'Olvidé mi contraseña';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get noAccount => '¿No tienes una cuenta?';

  @override
  String get register => 'Registrar';

  @override
  String get emailRequired => 'Por favor, introduce tu correo electrónico';

  @override
  String get emailInvalid => 'Por favor, introduce un correo electrónico válido';

  @override
  String get passwordRequired => 'Por favor, introduce tu contraseña';

  @override
  String get settings => 'Configuración';

  @override
  String get home => 'Casa';

  @override
  String get achievements => 'Logros';

  @override
  String get profile => 'Perfil';

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get appSettings => 'Configuración de la Aplicación';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get manageNotifications => 'Gestionar notificaciones';

  @override
  String get language => 'Idioma';

  @override
  String get changeLanguage => 'Cambiar el idioma de la aplicación';

  @override
  String get theme => 'Tema';

  @override
  String get dark => 'Oscuro';

  @override
  String get light => 'Claro';

  @override
  String get system => 'Sistema';

  @override
  String get habitTracking => 'Seguimiento de Hábitos';

  @override
  String get cigarettesPerDay => 'Cigarrillos por día antes de dejar';

  @override
  String get configureHabits => 'Configura tus hábitos anteriores';

  @override
  String get packPrice => 'Precio del paquete';

  @override
  String get setPriceForCalculations => 'Establecer el precio para cálculos de ahorro';

  @override
  String get startDate => 'Fecha de inicio';

  @override
  String get whenYouQuitSmoking => 'Cuando dejaste de fumar';

  @override
  String get account => 'Cuenta';

  @override
  String get resetPassword => 'Restablecer contraseña';

  @override
  String get changePassword => 'Cambiar tu contraseña de acceso';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get permanentlyRemoveAccount => 'Eliminar permanentemente tu cuenta';

  @override
  String get deleteAccountTitle => 'Eliminar Cuenta';

  @override
  String get deleteAccountConfirmation => '¿Estás seguro de que deseas eliminar tu cuenta? Esta acción es irreversible y todos tus datos se perderán.';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get logoutFromAccount => 'Desconectar de tu cuenta';

  @override
  String get logoutTitle => 'Cerrar sesión';

  @override
  String get logoutConfirmation => '¿Estás seguro de que deseas cerrar sesión de tu cuenta?';

  @override
  String get about => 'Acerca de';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get readPrivacyPolicy => 'Lee nuestra política de privacidad';

  @override
  String get termsOfUse => 'Términos de Uso';

  @override
  String get viewTermsOfUse => 'Ver los términos de uso de la aplicación';

  @override
  String get aboutApp => 'Sobre la Aplicación';

  @override
  String get appInfo => 'Versión e información de la aplicación';

  @override
  String version(String version) {
    return 'Versión $version';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get next => 'Siguiente';

  @override
  String get back => 'Atrás';

  @override
  String get finish => 'Finalizar';

  @override
  String get cigarettesPerDayQuestion => '¿Cuántos cigarrillos fumas al día?';

  @override
  String get cigarettesPerDaySubtitle => 'Esto nos ayuda a entender tu nivel de consumo';

  @override
  String get exactNumber => 'Número exacto: ';

  @override
  String get selectConsumptionLevel => 'O selecciona tu nivel de consumo:';

  @override
  String get low => 'Bajo';

  @override
  String get moderate => 'Moderado';

  @override
  String get high => 'Alto';

  @override
  String get veryHigh => 'Muy Alto';

  @override
  String get upTo5 => 'Hasta 5 cigarrillos por día';

  @override
  String get sixTo15 => '6 a 15 cigarrillos por día';

  @override
  String get sixteenTo25 => '16 a 25 cigarrillos por día';

  @override
  String get moreThan25 => 'Más de 25 cigarrillos por día';

  @override
  String get selectConsumptionLevelError => 'Por favor, selecciona tu nivel de consumo';

  @override
  String get welcomeToNicotinaAI => 'Bienvenido a NicotinaAI';

  @override
  String get personalAssistant => 'Tu asistente personal para dejar de fumar';

  @override
  String get start => 'Comenzar';

  @override
  String get breatheFreedom => 'RESPIRA LIBERTAD. TU NUEVA VIDA COMIENZA AHORA.';

  @override
  String get personalizeExperience => 'Vamos a personalizar tu experiencia para ayudarte a alcanzar tus objetivos de dejar de fumar. Responde algunas preguntas para comenzar.';

  @override
  String get cigarettesPerPackQuestion => '¿Cuántos cigarrillos vienen en un paquete?';

  @override
  String get selectStandardAmount => 'Selecciona la cantidad estándar para tus paquetes de cigarrillos';

  @override
  String get packSizesInfo => 'Los paquetes de cigarrillos generalmente vienen con 10 o 20 unidades. Selecciona la cantidad que corresponde a los paquetes que compras.';

  @override
  String get tenCigarettes => '10 cigarrillos';

  @override
  String get twentyCigarettes => '20 cigarrillos';

  @override
  String get smallPack => 'Paquete pequeño/compacto';

  @override
  String get standardPack => 'Paquete estándar/tradicional';

  @override
  String get otherQuantity => 'Otra cantidad';

  @override
  String get selectCustomValue => 'Selecciona un valor personalizado';

  @override
  String get quantity => 'Cantidad: ';

  @override
  String get packSizeHelp => 'Esta información nos ayuda a calcular con precisión tu consumo y los beneficios de reducir o dejar de fumar.';

  @override
  String get packPriceQuestion => '¿Cuánto cuesta un paquete de cigarrillos?';

  @override
  String get helpCalculateFinancial => 'Esto nos ayuda a calcular tu ahorro financiero';

  @override
  String get enterAveragePrice => 'Introduce el precio promedio que pagas por un paquete de cigarrillos.';

  @override
  String get priceHelp => 'Esta información nos ayuda a mostrarte cuánto ahorrarás al reducir o dejar de fumar.';

  @override
  String get productTypeQuestion => '¿Qué tipo de producto consumes?';

  @override
  String get selectApplicable => 'Selecciona lo que se aplica a ti';

  @override
  String get helpPersonalizeStrategy => 'Esto nos ayuda a personalizar estrategias y recomendaciones para tu caso específico.';

  @override
  String get cigaretteOnly => 'Solo cigarrillos tradicionales';

  @override
  String get traditionalCigarettes => 'Cigarrillos de tabaco convencionales';

  @override
  String get vapeOnly => 'Solo vaporizador/cigarrillos electrónicos';

  @override
  String get electronicDevices => 'Dispositivos electrónicos de vapeo';

  @override
  String get both => 'Ambos';

  @override
  String get useBoth => 'Uso tanto cigarrillos tradicionales como electrónicos';

  @override
  String get productTypeHelp => 'Diferentes productos contienen diferentes cantidades de nicotina y pueden requerir distintas estrategias para reducción o cese.';

  @override
  String get pleaseSelectProductType => 'Por favor, selecciona un tipo de producto';

  @override
  String get goalQuestion => '¿Cuál es tu objetivo?';

  @override
  String get selectGoal => 'Selecciona lo que quieres lograr';

  @override
  String get goalExplanation => 'Establecer un objetivo claro es esencial para tu éxito. Queremos ayudarte a lograr lo que deseas.';

  @override
  String get reduceConsumption => 'Reducir el consumo';

  @override
  String get reduceDescription => 'Quiero fumar menos cigarrillos y tener más control sobre el hábito';

  @override
  String get reduce => 'Reducir';

  @override
  String get quitSmoking => 'Dejar de fumar';

  @override
  String get quitDescription => 'Quiero dejar completamente los cigarrillos y vivir libre de tabaco';

  @override
  String get quit => 'Dejar';

  @override
  String get goalHelp => 'Adaptaremos nuestros recursos y recomendaciones según tu objetivo. Puedes modificarlo más tarde si cambias de opinión.';

  @override
  String get pleaseSelectGoal => 'Por favor, selecciona un objetivo';

  @override
  String get timelineQuestionReduce => '¿Cuándo quieres reducir el consumo?';

  @override
  String get timelineQuestionQuit => '¿Cuándo quieres dejar de fumar?';

  @override
  String get establishDeadline => 'Establece un plazo que te parezca alcanzable';

  @override
  String get timelineExplanation => 'Un cronograma realista aumenta tus posibilidades de éxito. Elige un plazo con el que te sientas cómodo.';

  @override
  String get sevenDays => '7 días';

  @override
  String get sevenDaysDescription => 'Quiero resultados rápidos y estoy comprometido';

  @override
  String get fourteenDays => '14 días';

  @override
  String get fourteenDaysDescription => 'Un plazo equilibrado para cambiar hábitos';

  @override
  String get thirtyDays => '30 días';

  @override
  String get thirtyDaysDescription => 'Un mes para un cambio gradual y sostenible';

  @override
  String get noDeadline => 'Sin plazo definido';

  @override
  String get noDeadlineDescription => 'Prefiero ir a mi propio ritmo';

  @override
  String get timelineHelp => 'No te preocupes si no logras tu objetivo exactamente en el plazo. Lo importante es el progreso continuo.';

  @override
  String get pleaseSelectTimeline => 'Por favor, selecciona un plazo';

  @override
  String challengeQuestion(String goalText) {
    return '¿Qué hace difícil $goalText para ti?';
  }

  @override
  String get identifyChallenge => 'Identificar tu principal desafío nos ayuda a proporcionar mejor apoyo';

  @override
  String get challengeExplanation => 'Entender lo que hace difícil dejar el cigarrillo es el primer paso para superar ese obstáculo.';

  @override
  String get stressAnxiety => 'Estrés y ansiedad';

  @override
  String get stressDescription => 'Fumo para lidiar con situaciones estresantes y ansiedad';

  @override
  String get habitStrength => 'Fuerza del hábito';

  @override
  String get habitDescription => 'Fumar ya es parte de mi rutina diaria';

  @override
  String get socialInfluence => 'Influencia social';

  @override
  String get socialDescription => 'Personas a mi alrededor fuman o me animan a fumar';

  @override
  String get physicalDependence => 'Dependencia física';

  @override
  String get dependenceDescription => 'Experimento síntomas físicos cuando estoy sin fumar';

  @override
  String get challengeHelp => 'Tus respuestas nos ayudan a personalizar consejos y estrategias más efectivas para tu caso específico.';

  @override
  String get pleaseSelectChallenge => 'Por favor, selecciona un desafío';

  @override
  String get locationsQuestion => '¿Dónde sueles fumar?';

  @override
  String get selectCommonPlaces => 'Selecciona los lugares donde más a menudo fumas';

  @override
  String get locationsExplanation => 'Conocer tus lugares habituales nos ayuda a identificar patrones y crear estrategias específicas.';

  @override
  String get atHome => 'En casa';

  @override
  String get homeDetails => 'Balcón, sala, oficina';

  @override
  String get atWork => 'En el trabajo/escuela';

  @override
  String get workDetails => 'Durante descansos o pausas';

  @override
  String get inCar => 'En el coche/transporte';

  @override
  String get carDetails => 'Durante viajes';

  @override
  String get socialEvents => 'En eventos sociales';

  @override
  String get socialDetails => 'Bares, fiestas, restaurantes';

  @override
  String get outdoors => 'Al aire libre';

  @override
  String get outdoorsDetails => 'Parques, aceras, áreas exteriores';

  @override
  String get otherPlaces => 'Otros lugares';

  @override
  String get otherPlacesDetails => 'Cuando estoy ansioso, independientemente del lugar';

  @override
  String get locationsHelp => 'Identificar los lugares más comunes ayuda a evitar desencadenantes y crear estrategias para cambiar hábitos.';

  @override
  String get continueButton => 'Continuar';

  @override
  String get allDone => '¡Todo listo!';

  @override
  String get personalizedJourney => 'Tu viaje personalizado comienza ahora';

  @override
  String get startMyJourney => 'Comenzar Mi Viaje';

  @override
  String get congratulations => '¡Felicitaciones por dar el primer paso!';

  @override
  String personalizedPlanReduce(String timelineText) {
    return 'Hemos creado un plan personalizado basado en tus respuestas para ayudarte a reducir el consumo $timelineText.';
  }

  @override
  String personalizedPlanQuit(String timelineText) {
    return 'Hemos creado un plan personalizado basado en tus respuestas para ayudarte a dejar de fumar $timelineText.';
  }

  @override
  String get yourPersonalizedSummary => 'Tu resumen personalizado';

  @override
  String get dailyConsumption => 'Consumo diario';

  @override
  String cigarettesPerDayValue(int count) {
    return '$count cigarrillos por día';
  }

  @override
  String get potentialMonthlySavings => 'Ahorro mensual potencial';

  @override
  String get yourGoal => 'Tu objetivo';

  @override
  String get mainChallenge => 'Tu principal desafío';

  @override
  String get personalized => 'Monitoreo personalizado';

  @override
  String get personalizedDescription => 'Sigue tu progreso basado en tus hábitos';

  @override
  String get importantAchievements => 'Logros importantes';

  @override
  String get achievementsDescription => 'Celebra cada hito en tu viaje';

  @override
  String get supportWhenNeeded => 'Apoyo cuando lo necesitas';

  @override
  String get supportDescription => 'Consejos y estrategias para momentos difíciles';

  @override
  String get guaranteedResults => 'Resultados garantizados';

  @override
  String get resultsDescription => 'Con nuestra tecnología basada en ciencia';

  @override
  String loadingError(String error) {
    return 'Error al completar: $error';
  }

  @override
  String get developer => 'Desarrollador';

  @override
  String get developerMode => 'Modo Desarrollador';

  @override
  String get enableDebugging => 'Habilitar depuración detallada y seguimiento';

  @override
  String get dashboard => 'Panel';

  @override
  String get viewDetailedTracking => 'Ver panel de seguimiento detallado';

  @override
  String get currency => 'Moneda';

  @override
  String get changeCurrency => 'Cambiar moneda';

  @override
  String get setCurrencyForCalculations => 'Establecer la moneda para cálculos de ahorro';

  @override
  String get search => 'Buscar';

  @override
  String get noResults => 'No se encontraron resultados';

  @override
  String get listView => 'Vista de lista';

  @override
  String get gridView => 'Vista de cuadrícula';

  @override
  String get atYourOwnPace => 'a tu propio ritmo';

  @override
  String get nextSevenDays => 'en los próximos 7 días';

  @override
  String get nextTwoWeeks => 'en las próximas 2 semanas';

  @override
  String get nextMonth => 'en el próximo mes';

  @override
  String get notSpecified => 'No especificado';

  @override
  String get registerCraving => 'Registrar Antojo';

  @override
  String get registerCravingSubtitle => 'Cuando sientas ganas';

  @override
  String get newRecord => 'Nuevo Registro';

  @override
  String get newRecordSubtitle => 'Cuando fumes';

  @override
  String get whereAreYou => '¿Dónde estás?';

  @override
  String get work => 'Trabajo';

  @override
  String get car => 'Coche';

  @override
  String get restaurant => 'Restaurante';

  @override
  String get bar => 'Bar';

  @override
  String get street => 'Calle';

  @override
  String get park => 'Parque';

  @override
  String get others => 'Otros';

  @override
  String get notes => 'Notas (opcional)';

  @override
  String get howAreYouFeeling => '¿Cómo te sientes?';

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
  String get craving => 'Antojo';

  @override
  String get other => 'Otro';

  @override
  String get intensityLevel => 'Nivel de intensidad';

  @override
  String get mild => 'Suave';

  @override
  String get intense => 'Intenso';

  @override
  String get veryIntense => 'Muy intenso';

  @override
  String get pleaseSelectLocation => 'Por favor, selecciona tu ubicación';

  @override
  String get pleaseSelectTrigger => 'Por favor, selecciona qué desencadenó tu antojo';

  @override
  String get pleaseSelectIntensity => 'Por favor, selecciona el nivel de intensidad';

  @override
  String get whatsTheReason => '¿Cuál es el motivo?';

  @override
  String get anxiety => 'Ansiedad';

  @override
  String get pleaseSelectReason => 'Por favor, selecciona un motivo';

  @override
  String get howDoYouFeel => '¿Cómo te sientes? ¿Qué podrías haber hecho diferente?';

  @override
  String get didYouResist => '¿Resististe?';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get howMuchDidYouSmoke => '¿Cuánto fumaste?';

  @override
  String get oneOrLess => '1 o menos';

  @override
  String get twoToFive => '2-5';

  @override
  String get moreThanFive => 'Más de 5';

  @override
  String get pleaseSelectAmount => 'Por favor, selecciona cuánto fumaste';

  @override
  String get howLongDidItLast => '¿Cuánto duró?';

  @override
  String get lessThan5min => 'Menos de 5 min';

  @override
  String get fiveToFifteenMin => '5-15 min';

  @override
  String get moreThan15min => 'Más de 15 min';

  @override
  String get pleaseSelectDuration => 'Por favor, selecciona cuánto duró';

  @override
  String get selectCurrency => 'Selecciona tu moneda';

  @override
  String get selectCurrencySubtitle => 'Elige la moneda para los cálculos financieros';

  @override
  String get preselectedCurrency => 'Hemos preseleccionado tu moneda local. Puedes cambiarla si es necesario.';

  @override
  String get pleaseCompleteAllFields => 'Por favor, completa todos los campos requeridos para continuar';

  @override
  String get understood => 'Entendido';

  @override
  String get commonPrices => 'Precios comunes de paquetes';

  @override
  String get refresh => 'Actualizar';

  @override
  String get errorLoadingNotifications => 'Error al cargar notificaciones';

  @override
  String get noNotificationsYet => '¡Aún no hay notificaciones!';

  @override
  String get emptyNotificationsDescription => 'Continúa usando la aplicación para recibir mensajes motivacionales y logros.';

  @override
  String get motivationalMessage => 'Mensaje Motivacional';

  @override
  String claimReward(int xp) {
    return 'Reclamar $xp XP';
  }

  @override
  String rewardClaimed(int xp) {
    return 'Recompensa reclamada: $xp XP';
  }

  @override
  String get dailyMotivation => 'Motivación Diaria';

  @override
  String get dailyMotivationDescription => 'Tu motivación diaria personalizada está aquí. ¡Ábrela para obtener tu recompensa de XP!';

  @override
  String get retry => 'Reintentar';

  @override
  String get cravingResistedRecorded => '¡Resistencia al antojo registrada exitosamente!';

  @override
  String get cravingRecorded => '¡Antojo registrado exitosamente!';

  @override
  String get errorSavingCraving => 'Error al guardar antojo. Toca para reintentar.';

  @override
  String get recordSaved => '¡Registro guardado exitosamente!';

  @override
  String get tapToRetry => 'Toca para reintentar';

  @override
  String get syncError => 'Error de sincronización';

  @override
  String get loading => 'Cargando...';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String get errorLoadingData => 'Error al cargar datos';

  @override
  String get noRecoveriesFound => 'No se encontraron recuperaciones de salud';

  @override
  String get noRecentRecoveries => 'No hay recuperaciones de salud recientes para mostrar';

  @override
  String get viewAllRecoveries => 'Ver Todas las Recuperaciones de Salud';

  @override
  String get healthRecovery => 'Recuperación de Salud';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get achieved => 'Logrado';

  @override
  String get progress => 'Progreso';

  @override
  String daysToAchieve(int days) {
    return '$days días para lograr';
  }

  @override
  String daysRemaining(int days) {
    return '$days días restantes';
  }

  @override
  String achievedOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Logrado el $dateString';
  }

  @override
  String daysSmokeFree(int days) {
    return '$days días sin fumar';
  }

  @override
  String get keepGoing => '¡Sigue así!';

  @override
  String get encouragementMessage => 'Estás haciendo un gran progreso. Cada día sin fumar te acerca más a alcanzar este hito de salud.';

  @override
  String get recoveryAchievedMessage => 'Tu cuerpo ya se ha recuperado en esta área. Sigue con el buen trabajo para mantener y mejorar aún más tu salud.';

  @override
  String get scienceBehindIt => 'La Ciencia Detrás';

  @override
  String get generalHealthScienceInfo => 'Cuando dejas de fumar, tu cuerpo comienza una serie de procesos de curación. Estos comienzan minutos después de tu último cigarrillo y continúan durante años, restaurando gradualmente tu salud a la de un no fumador.';

  @override
  String get tasteScienceInfo => 'Cuando fumas, los químicos del tabaco dañan las papilas gustativas y reducen tu capacidad de saborear. Después de solo unos días sin fumar, estos receptores de sabor comienzan a sanar, permitiéndote experimentar más sabores y disfrutar más de la comida.';

  @override
  String get smellScienceInfo => 'Fumar daña los nervios olfativos que transmiten información de olor al cerebro. En pocos días después de dejar de fumar, estos nervios comienzan a recuperarse, mejorando gradualmente tu sentido del olfato y permitiéndote detectar olores más sutiles.';

  @override
  String get bloodOxygenScienceInfo => 'El monóxido de carbono de los cigarrillos se une a la hemoglobina en tu sangre, reduciendo su capacidad para transportar oxígeno. En 12-24 horas después de dejar de fumar, los niveles de monóxido de carbono caen dramáticamente, permitiendo que tu sangre transporte oxígeno más eficazmente.';

  @override
  String get carbonMonoxideScienceInfo => 'El humo del cigarrillo contiene monóxido de carbono, que desplaza el oxígeno en tu sangre. Dentro de 12 horas después de dejar de fumar, los niveles de monóxido de carbono vuelven a la normalidad, y los niveles de oxígeno en tu cuerpo aumentan significativamente.';

  @override
  String get nicotineScienceInfo => 'La nicotina tiene una vida media de aproximadamente 2 horas, lo que significa que toma aproximadamente 72 horas (3 días) para que toda la nicotina sea eliminada de tu cuerpo. Una vez que la nicotina desaparece, los síntomas físicos de abstinencia comienzan a disminuir.';

  @override
  String get improvedBreathingScienceInfo => 'Después de 7 días sin fumar, la función pulmonar comienza a mejorar a medida que disminuye la inflamación y los pulmones comienzan a limpiar la mucosidad acumulada. Notarás menos tos y respiración más fácil, especialmente durante la actividad física.';

  @override
  String get improvedCirculationScienceInfo => 'Después de dos semanas sin fumar, tu circulación mejora significativamente. Los vasos sanguíneos se dilatan, la presión arterial se normaliza, y más oxígeno llega a tus músculos y órganos, haciendo que la actividad física sea más fácil y menos extenuante.';

  @override
  String get decreasedCoughingScienceInfo => 'Un mes después de dejar de fumar, los cilios (pequeñas estructuras similares a pelos) en tus pulmones comienzan a crecer de nuevo. Estos ayudan a limpiar tus pulmones y reducir infecciones. Tu tos y falta de aliento continúan disminuyendo.';

  @override
  String get lungCiliaScienceInfo => 'Después de 3 meses sin fumar, tu función pulmonar puede mejorar hasta un 30%. Los cilios en tus pulmones han crecido en gran medida, mejorando la capacidad de tus pulmones para limpiarse, combatir infecciones y reducir la mucosidad.';

  @override
  String get reducedHeartDiseaseRiskScienceInfo => 'Después de un año sin fumar, tu riesgo de enfermedad coronaria disminuye aproximadamente a la mitad del de un fumador. Tu función cardíaca continúa mejorando a medida que los vasos sanguíneos sanan y la circulación mejora.';

  @override
  String get viewHealthRecoveries => 'Ver Recuperaciones de Salud';

  @override
  String get recoveryNotFound => 'Recuperación de salud no encontrada';

  @override
  String get trackYourHealthJourney => 'Sigue Tu Camino de Salud';

  @override
  String get healthRecoveryDescription => 'Ve cómo tu cuerpo se recupera después de dejar de fumar';
}
