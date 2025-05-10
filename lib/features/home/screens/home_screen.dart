import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_bloc.dart';
import 'package:nicotinaai_flutter/blocs/auth/auth_state.dart' as bloc_auth;
import 'package:nicotinaai_flutter/blocs/smoking_record/smoking_record_bloc.dart';
import 'package:nicotinaai_flutter/blocs/smoking_record/smoking_record_event.dart';
import 'package:nicotinaai_flutter/blocs/smoking_record/smoking_record_state.dart';
import 'package:nicotinaai_flutter/blocs/theme/theme_bloc.dart';
import 'package:nicotinaai_flutter/blocs/theme/theme_state.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_bloc.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_event.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_state.dart';
import 'package:nicotinaai_flutter/core/routes/app_routes.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/core/theme/theme_switch.dart';
import 'package:nicotinaai_flutter/features/home/widgets/new_record_sheet.dart';
import 'package:nicotinaai_flutter/features/home/widgets/register_craving_sheet_bloc.dart';
import 'package:nicotinaai_flutter/features/tracking/models/health_recovery.dart';
import 'package:nicotinaai_flutter/features/tracking/models/user_stats.dart';
import 'package:nicotinaai_flutter/features/tracking/widgets/health_recovery_widget.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/utils/currency_utils.dart';
import 'package:nicotinaai_flutter/utils/health_recovery_utils.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State variables to store stats
  int _daysWithoutSmoking = 0;
  int _minutesLifeGained = 0;
  int _breathCapacityPercent = 0;
  int _cravingsResisted = 0;
  int _dailyMinutesGained = 0;
  int _moneySavedInCents = 0;
  UserStats? _stats;
  // Health recovery IDs
  List<String> _userRecoveryIds = [];
  Map<String, bool> _healthRecoveryStatus = {
    'taste': false,
    'smell': false,
    'circulation': false,
    'lungs': false,
    'heart': false,
  };
  // Next health recovery milestone
  Map<String, dynamic>? _nextHealthMilestone;
  // Flag para evitar múltiplas chamadas de atualização simultâneas
  bool _isUpdating = false;
  // Flag para limitar o número de atualizações quando não há dados de saúde
  bool _hasCheckedHealthData = false;
  // Timestamp da última atualização
  DateTime? _lastUpdateTime;
  // Currency formatter
  final CurrencyUtils _currencyUtils = CurrencyUtils();
  
  @override
  void initState() {
    super.initState();
    // Evite chamar BLoC diretamente em initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeBlocs();
    });
  }

  void _initializeBlocs() {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    final authState = authBloc.state;
    
    if (authState.status == bloc_auth.AuthStatus.authenticated && authState.user != null) {
      final userId = authState.user!.id;
      
      // Solicitar dados de registros de fumo
      final recordBloc = BlocProvider.of<SmokingRecordBloc>(context);
      recordBloc.add(LoadSmokingRecordsRequested(userId: userId));
      
      // Solicitar dados de estatísticas
      final trackingBloc = BlocProvider.of<TrackingBloc>(context);
      trackingBloc.add(LoadUserStats(forceRefresh: true));
      trackingBloc.add(LoadHealthRecoveries());
    }
  }

  void _loadData(TrackingState trackingState) {
    if (!mounted) return;
    
    // Evitar múltiplas chamadas simultâneas
    if (_isUpdating) {
      if (kDebugMode) {
        print('🚫 Atualização já em andamento, ignorando chamada duplicada');
      }
      return;
    }
    
    // Limitar a frequência de atualizações
    final now = DateTime.now();
    if (_lastUpdateTime != null) {
      final timeSinceLastUpdate = now.difference(_lastUpdateTime!);
      // Se a última atualização foi há menos de 2 segundos, ignorar
      // Reduzido de 10 segundos para 2 segundos para maior responsividade
      if (timeSinceLastUpdate.inSeconds < 2) {
        if (kDebugMode) {
          print('🕒 Última atualização foi há apenas ${timeSinceLastUpdate.inSeconds} segundos, ignorando');
        }
        return;
      }
    }
    
    setState(() {
      _isUpdating = true;
    });
    
    // Atualizar o timestamp da última atualização
    _lastUpdateTime = now;
    
    // Verificar explicitamente se a última data de fumo está atualizada
    final hasLastSmokeDate = trackingState.userStats?.lastSmokeDate != null;
    
    if (kDebugMode) {
      if (hasLastSmokeDate) {
        print('📅 Data do último cigarro no BLoC: ${trackingState.userStats!.lastSmokeDate}');
      } else {
        print('⚠️ Data do último cigarro não disponível no BLoC');
      }
    }
    
    // Se não temos data de último cigarro e já verificamos antes, limitar atualizações
    if (!hasLastSmokeDate && _hasCheckedHealthData) {
      if (kDebugMode) {
        print('🛑 Limitando atualizações repetidas quando não há dados de saúde');
      }
      setState(() {
        _isUpdating = false;
      });
      return;
    }
    
    try {
      // Get health recoveries
      final userRecoveries = trackingState.userHealthRecoveries;
      final allRecoveries = trackingState.healthRecoveries;
      
      // Map recovery IDs to their types
      Map<String, String> recoveryTypeMap = {};
      for (var recovery in allRecoveries) {
        String type = '';
        
        if (recovery.name.toLowerCase().contains('taste')) type = 'taste';
        else if (recovery.name.toLowerCase().contains('smell')) type = 'smell';
        else if (recovery.name.toLowerCase().contains('circulation')) type = 'circulation';
        else if (recovery.name.toLowerCase().contains('lung') || 
                 recovery.name.toLowerCase().contains('breathing')) type = 'lungs';
        else if (recovery.name.toLowerCase().contains('heart')) type = 'heart';
        
        if (type.isNotEmpty) {
          recoveryTypeMap[recovery.id] = type;
        }
      }
      
      // Get list of recovery IDs user has achieved
      final newUserRecoveryIds = userRecoveries.map((recovery) => recovery.recoveryId).toList();
      
      // Reset health status
      final Map<String, bool> newHealthRecoveryStatus = {
        'taste': false,
        'smell': false,
        'circulation': false,
        'lungs': false,
        'heart': false,
      };
      
      // Update recovery status based on user's achievements
      for (var recoveryId in newUserRecoveryIds) {
        final type = recoveryTypeMap[recoveryId];
        if (type != null && newHealthRecoveryStatus.containsKey(type)) {
          newHealthRecoveryStatus[type] = true;
        }
      }
      
      // Update state variables from BLoC state
      if (mounted) {
        // Obter estatísticas atualizadas diretamente do BLoC state
        final updatedStats = trackingState.userStats;
        final updatedCravingsResisted = updatedStats?.cravingsResisted ?? 0;
        final updatedDaysWithoutSmoking = updatedStats?.currentStreakDays ?? 0;
        final updatedMoneySaved = updatedStats?.moneySaved ?? 0;
        
        if (kDebugMode && updatedStats?.lastSmokeDate != null && _stats?.lastSmokeDate != null) {
          // Verificar se a data mudou para debug
          final oldDate = _stats!.lastSmokeDate!;
          final newDate = updatedStats!.lastSmokeDate!;
          if (oldDate != newDate) {
            print('🔄 Data do último cigarro atualizada: ${oldDate.toIso8601String()} -> ${newDate.toIso8601String()}');
          }
        }
        
        setState(() {
          _userRecoveryIds = newUserRecoveryIds;
          _healthRecoveryStatus = newHealthRecoveryStatus;
          _stats = updatedStats;
          _daysWithoutSmoking = updatedDaysWithoutSmoking;
          _minutesLifeGained = (_stats?.cigarettesAvoided ?? 0) * 6; // Each cigarette not smoked gives ~6 minutes
          _breathCapacityPercent = _daysWithoutSmoking > 30 ? 40 : (_daysWithoutSmoking > 7 ? 20 : 10);
          _cravingsResisted = updatedCravingsResisted;
          _dailyMinutesGained = _daysWithoutSmoking == 0 ? 0 : _minutesLifeGained ~/ _daysWithoutSmoking;
          // Debug para analisar o valor da economia
          if (kDebugMode) {
            print('💰 Valor economizado recebido do servidor: $updatedMoneySaved centavos');
            print('💰 Dias sem fumar: $_daysWithoutSmoking, Cigarros evitados: ${_stats?.cigarettesAvoided}');
          }
          
          // Verificar se o valor do servidor é válido - se for próximo de 247 centavos consistentemente,
          // há um problema no cálculo do servidor
          if (updatedMoneySaved > 0 && updatedMoneySaved != 247) {
            // Use o valor do servidor se parecer válido
            _moneySavedInCents = updatedMoneySaved;
          } else {
            // SOLUÇÃO TEMPORÁRIA: Calcular o valor localmente se o servidor retornar zero ou 247 centavos
            // Assumindo preço médio de R$12,00 por maço com 20 cigarros
            const int defaultPackPriceInCents = 1200; // R$12,00
            const int defaultCigarettesPerPack = 20;
            const int defaultCigarettesPerDay = 20; // Se não temos o valor real, assumimos 1 maço por dia
            
            // Cálculo: dias sem fumar * cigarros por dia * (preço do maço / cigarros por maço)
            final int cigarettesAvoided = _stats?.cigarettesAvoided ?? (_daysWithoutSmoking * defaultCigarettesPerDay);
            final double pricePerCigarette = defaultPackPriceInCents / defaultCigarettesPerPack;
            final int calculatedMoneySaved = (cigarettesAvoided * pricePerCigarette).round();
            
            if (kDebugMode) {
              print('💰 CALCULANDO LOCALMENTE: dias=$_daysWithoutSmoking, cigarros evitados=$cigarettesAvoided');
              print('💰 Preço por cigarro=$pricePerCigarette centavos, economia calculada=$calculatedMoneySaved centavos');
            }
            
            _moneySavedInCents = calculatedMoneySaved > 0 ? calculatedMoneySaved : updatedMoneySaved;
          }
          
          // Load the next health milestone
          _loadNextHealthMilestone();
          
          _isUpdating = false;
          _hasCheckedHealthData = true; // Marcar que verificamos os dados de saúde
        });
      } else {
        _isUpdating = false;
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ Erro ao atualizar dados: $error');
      }
      if (mounted) {
        setState(() {
          _isUpdating = false;
          _hasCheckedHealthData = true; // Marcar que verificamos os dados mesmo em caso de erro
        });
      } else {
        _isUpdating = false;
      }
    }
  }
  
  /// Load the next health milestone from the server
  Future<void> _loadNextHealthMilestone() async {
    if (!mounted) return;
    
    // Se o usuário não tem dias sem fumar ou estatísticas, não tentamos carregar o próximo milestone
    final trackingBloc = BlocProvider.of<TrackingBloc>(context);
    final hasLastSmokeDate = trackingBloc.state.userStats?.lastSmokeDate != null;
    
    if (!hasLastSmokeDate || _daysWithoutSmoking <= 0) {
      if (kDebugMode) {
        print('⚠️ Skipping next health milestone load: no last smoke date or days without smoking');
      }
      return;
    }
    
    try {
      // Get the next health milestone
      final nextMilestone = await HealthRecoveryUtils.getNextHealthRecoveryMilestone(_daysWithoutSmoking);
      
      if (mounted) {
        setState(() {
          _nextHealthMilestone = nextMilestone;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading next health milestone: $e');
      }
      // Don't update state on error, keep previous milestone if any
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Nada aqui para evitar problemas durante o build
  }
  
  @override
  Widget build(BuildContext context) {
    // Obter dados do usuário do AuthBloc
    return BlocBuilder<AuthBloc, bloc_auth.AuthState>(
      builder: (context, authState) {
        if (authState.status == bloc_auth.AuthStatus.authenticated && authState.user != null) {
          final user = authState.user!;
          final l10n = AppLocalizations.of(context);
          
          // Usar BlocListener para reagir a mudanças de estado
          return MultiBlocListener(
            listeners: [
              // Listener para TrackingBloc
              BlocListener<TrackingBloc, TrackingState>(
                listenWhen: (previous, current) => 
                  // Adicionar verificação específica para o caso de estado inicial
                  previous.lastUpdated != current.lastUpdated || 
                  (previous.userStats == null && current.userStats != null) ||
                  // Listen specifically for changes in key stats values
                  previous.userStats?.cravingsResisted != current.userStats?.cravingsResisted || 
                  previous.userStats?.currentStreakDays != current.userStats?.currentStreakDays ||
                  previous.userStats?.moneySaved != current.userStats?.moneySaved ||
                  (previous.userStats?.lastSmokeDate?.millisecondsSinceEpoch ?? 0) != 
                  (current.userStats?.lastSmokeDate?.millisecondsSinceEpoch ?? 0) ||
                  // Also listen for changes in loading state or update timestamp
                  previous.isStatsLoading != current.isStatsLoading,
                listener: (context, state) {
                  // Atualizar dados locais quando o estado do TrackingBloc mudar
                  if (state.isLoaded || !state.isStatsLoading) {
                    if (kDebugMode) {
                      print('🔄 [HomeScreen] TrackingBloc state changed, reloading data');
                      print('📊 [HomeScreen] Cravings resistidos: ${state.userStats?.cravingsResisted ?? 0}');
                    }
                    _loadData(state);
                  }
                },
              ),
              // Listener para SmokingRecordBloc - com detecção melhorada de mudanças
              BlocListener<SmokingRecordBloc, SmokingRecordState>(
                listenWhen: (previous, current) {
                  // Detectar mudanças na quantidade de registros ou no status
                  return previous.records.length != current.records.length ||
                         previous.status != current.status ||
                         (previous.status == SmokingRecordStatus.saving && 
                          current.status == SmokingRecordStatus.loaded);
                },
                listener: (context, state) {
                  // Reagir a mudanças no estado do SmokingRecordBloc
                  // Forçar atualização das estatísticas quando houver mudanças nos registros
                  final trackingBloc = BlocProvider.of<TrackingBloc>(context);
                  trackingBloc.add(ForceUpdateStats());
                  
                  // Forçar atualização imediata da UI
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && !_isUpdating) {
                      _loadData(trackingBloc.state);
                    }
                  });
                },
              ),
            ],
            child: BlocBuilder<TrackingBloc, TrackingState>(
              builder: (context, trackingState) {
                // Verifica se passou pelo menos 1 segundo desde a última atualização
                // Reduzido de 5 segundos para 1 segundo para maior responsividade
                bool canUpdate = true;
                if (_lastUpdateTime != null) {
                  final timeSinceLastUpdate = DateTime.now().difference(_lastUpdateTime!);
                  canUpdate = timeSinceLastUpdate.inSeconds >= 1;
                }
                
                // Detecta eventos reais de mudança para atualizar
                // Adicionadas mais condições de detecção para garantir que as atualizações sejam percebidas
                final bool shouldUpdate = trackingState.isLoaded && canUpdate && (
                  // Condições originais
                  _stats?.cravingsResisted != trackingState.userStats?.cravingsResisted || 
                  _stats?.currentStreakDays != trackingState.userStats?.currentStreakDays ||
                  _stats?.moneySaved != trackingState.userStats?.moneySaved ||
                  (_stats?.lastSmokeDate?.millisecondsSinceEpoch ?? 0) != (trackingState.userStats?.lastSmokeDate?.millisecondsSinceEpoch ?? 0) ||
                  (_userRecoveryIds.isEmpty && trackingState.userHealthRecoveries.isNotEmpty) ||
                  // Condições adicionais para melhor detecção
                  (trackingState.lastUpdated != null && 
                   _lastUpdateTime != null && 
                   trackingState.lastUpdated! > _lastUpdateTime!.millisecondsSinceEpoch) ||
                  (_stats != null && trackingState.userStats != null && 
                   (_stats!.smokingRecordsCount != trackingState.userStats!.smokingRecordsCount))
                );
                
                // Atualiza apenas quando há mudanças reais nos dados
                if (shouldUpdate && !_isUpdating) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && !_isUpdating) {
                      if (kDebugMode) {
                        print('🔄 Atualizando dados devido a mudanças reais nos dados');
                      }
                      _loadData(trackingState);
                    }
                  });
                }
                
                return Scaffold(
                  backgroundColor: context.backgroundColor,
                  appBar: AppBar(
                    title: Text(
                      l10n.appName,
                      style: context.titleStyle,
                    ),
                    backgroundColor: context.backgroundColor,
                    elevation: 0,
                    actions: const [
                      ThemeSwitch(useIcons: true),
                      SizedBox(width: 8),
                    ],
                  ),
                  body: SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cabeçalho com saudação e contador de dias
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.homeGreeting(user.name?.split(' ')[0] ?? 'Usuário'),
                                      style: context.headlineStyle,
                                    ),
                                    const SizedBox(height: 4),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.homeDaysWithoutSmoking(_daysWithoutSmoking),
                                          style: context.subtitleStyle,
                                        ),
                                        if (_stats?.lastSmokeDate != null)
                                          Text(
                                            'Último: ${_formatLastSmokeDate(_stats!.lastSmokeDate!)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: context.subtitleColor.withOpacity(0.8),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: context.primaryColor.withOpacity(0.2),
                                  child: Text(
                                    user.name?.substring(0, 1).toUpperCase() ?? 'U',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: context.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Estatísticas diárias
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.homeTodayStats,
                                  style: context.titleStyle,
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Navigate to statistics dashboard
                                    context.go(AppRoutes.statisticsDashboard.path);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: context.primaryColor,
                                  ),
                                  child: const Text(
                                    'View All',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Cards de estatísticas diárias
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildDailyStatCard(
                                    context,
                                    '$_cravingsResisted',
                                    l10n.homeCravingsResisted,
                                    Colors.orange,
                                    Icons.smoke_free,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDailyStatCard(
                                    context,
                                    _dailyMinutesGained > 0 ? '$_dailyMinutesGained min' : '0',
                                    l10n.homeMinutesGainedToday,
                                    Colors.teal,
                                    Icons.favorite,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Botões de registro
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    context,
                                    l10n.registerCraving,
                                    l10n.registerCravingSubtitle,
                                    Colors.redAccent,
                                    Icons.air,
                                    () {
                                      // Use the BLoC version of RegisterCravingSheet
                                      RegisterCravingSheetBloc.show(context).then((registered) {
                                        // Only update if a craving was actually registered
                                        if (registered) {
                                          if (kDebugMode) {
                                            print("🔄 Updating after registering craving with BLoC");
                                          }
                                          
                                          // Force full update of statistics (via BLoC)
                                          final trackingBloc = BlocProvider.of<TrackingBloc>(context);
                                          trackingBloc.add(ForceUpdateStats());
                                          
                                          // Force a UI refresh as well
                                          setState(() {
                                            _isUpdating = false;
                                            _lastUpdateTime = null; // Clear update time to force refresh
                                          });
                                          
                                          // Log current stats
                                          if (kDebugMode) {
                                            print('🔢 Current cravings resisted: ${trackingBloc.state.cravingsResisted}');
                                          }
                                          
                                          // Wait slightly to let changes propagate
                                          Future.delayed(const Duration(milliseconds: 500), () {
                                            // Force data reload directly after a delay
                                            if (mounted) {
                                              setState(() {}); // Trigger rebuild
                                              _loadData(trackingBloc.state);
                                              
                                              if (kDebugMode) {
                                                print('🔢 After refresh - cravings resisted: ${trackingBloc.state.cravingsResisted}');
                                              }
                                            }
                                          });
                                        }
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildActionButton(
                                    context,
                                    l10n.newRecord,
                                    l10n.newRecordSubtitle,
                                    Colors.blueAccent,
                                    Icons.smoking_rooms,
                                    () {
                                      // Usar a versão BLoC da sheet
                                      NewRecordSheet.show(context).then((registered) {
                                        // Só atualiza se um record foi realmente registrado
                                        if (registered) {
                                          if (kDebugMode) {
                                            print("🔄 Atualizando após registrar cigarro com BLoC");
                                          }
                                          
                                          // Forçar atualização completa das estatísticas (via BLoC)
                                          final trackingBloc = BlocProvider.of<TrackingBloc>(context);
                                          trackingBloc.add(ForceUpdateStats());
                                          
                                          // Force a UI refresh as well
                                          setState(() {
                                            _isUpdating = false;
                                            _lastUpdateTime = null; // Clear update time to force refresh
                                          });
                                          
                                          // Log current stats
                                          if (kDebugMode) {
                                            print('🔢 Current stats before refresh');
                                          }
                                          
                                          // Wait slightly to let changes propagate
                                          Future.delayed(const Duration(milliseconds: 500), () {
                                            // Force data reload directly after a delay
                                            if (mounted) {
                                              setState(() {}); // Trigger rebuild
                                              _loadData(trackingBloc.state);
                                              
                                              if (kDebugMode) {
                                                print('🔢 After refresh - stats updated');
                                              }
                                            }
                                          });
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Health Recovery Section
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l10n.healthRecovery,
                                      style: context.titleStyle,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Navigate to health recovery screen
                                        context.push(AppRoutes.healthRecovery.path);
                                      },
                                      child: Text(
                                        l10n.seeAll,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: context.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Health Recovery Widget or Placeholder
                              BlocBuilder<TrackingBloc, TrackingState>(
                                builder: (context, state) {
                                  final hasLastSmokeDate = state.userStats?.lastSmokeDate != null;
                                  
                                  // Se não tem data do último cigarro, mostramos um widget de placeholder
                                  if (!hasLastSmokeDate) {
                                    return _buildHealthRecoveryPlaceholder(context, l10n);
                                  }
                                  
                                  // Se tem data, mostramos o widget normal
                                  return HealthRecoveryWidget(
                                    showAllRecoveries: false,
                                    autoRefresh: true,
                                    showHeader: false,
                                    onRecoveryTap: (recovery, isAchieved) {
                                      if (recovery.id == 'all') {
                                        context.push(AppRoutes.healthRecovery.path);
                                      } else {
                                        context.push(AppRoutes.healthRecoveryDetail.withParams(
                                          params: {'recoveryId': recovery.id},
                                        ));
                                      }
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Cards de estatísticas
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildStatisticCard(
                                    context,
                                    '$_minutesLifeGained',
                                    l10n.homeMinutesLifeGained,
                                    Colors.green,
                                    Icons.access_time,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStatisticCard(
                                    context,
                                    '$_breathCapacityPercent%',
                                    l10n.homeLungCapacity,
                                    Colors.blue,
                                    Icons.air,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Money saved card
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildMoneyStatisticCard(
                              context,
                              _moneySavedInCents,
                              l10n.savingsCalculator,
                              Colors.amber,
                              Icons.savings,
                              user,
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Next milestone - only show if we have days without smoking
                          if (_stats?.lastSmokeDate != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: context.isDarkMode 
                                  ? _buildGlassMorphicNextMilestone(context, l10n)
                                  : _buildNextMilestone(context, l10n),
                            ),
                          
                          const SizedBox(height: 24),
                          
                          // Recent achievements
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.homeRecentAchievements,
                                  style: context.titleStyle,
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Navigate to achievements screen
                                    context.go(AppRoutes.achievements.path);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: context.primaryColor,
                                  ),
                                  child: Text(
                                    l10n.homeSeeAll,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Achievement cards
                          BlocBuilder<TrackingBloc, TrackingState>(
                            builder: (context, state) {
                              // Check if BLoC is loaded and we have achievements
                              bool hasRecoveries = state.isLoaded && 
                                state.userHealthRecoveries.isNotEmpty;
                                
                              return hasRecoveries
                                  // Show real user achievements when available
                                  ? SizedBox(
                                      height: 140,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        children: _buildRecentAchievements(context, l10n),
                                      ),
                                    )
                                  // Show motivational card when we don't have achievements or we're loading
                                  : _buildMotivationalCard(context, l10n);
                            },
                          ),
                          
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
        
        // Fallback for non-authenticated state
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
  
  Widget _buildHealthIndicator(BuildContext context, String title, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: isActive 
                ? context.primaryColor.withOpacity(0.15) 
                : context.isDarkMode 
                    ? Colors.grey[800] 
                    : Colors.grey[200],
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive 
                  ? context.primaryColor 
                  : context.isDarkMode
                      ? Colors.grey[700]!
                      : Colors.grey[400]!,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.check_circle,
              color: isActive 
                ? context.primaryColor 
                : context.isDarkMode
                    ? Colors.grey[600]
                    : Colors.grey[400],
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive 
                ? context.primaryColor 
                : context.subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatisticCard(BuildContext context, String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: context.isDarkMode 
            ? Border.all(color: context.borderColor)
            : null,
        boxShadow: context.isDarkMode 
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(context.isDarkMode ? 0.2 : 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color.withOpacity(context.isDarkMode ? 0.9 : 1.0),
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: context.textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: context.contentColor,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.textTheme.bodySmall!.copyWith(
              color: context.subtitleColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNextMilestone(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: _onNextMilestoneTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.primaryColor.withOpacity(0.7), 
              context.primaryColor
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: _buildMilestoneContent(context, Colors.white, l10n),
      ),
    );
  }
  
  Widget _buildGlassMorphicNextMilestone(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: _onNextMilestoneTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.primaryColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: _buildMilestoneContent(context, Colors.white, l10n),
          ),
        ),
      ),
    );
  }
  
  /// Handle tap on the next milestone card
  void _onNextMilestoneTap() {
    if (_nextHealthMilestone != null) {
      // Navigate to the health recovery detail screen for this milestone
      context.push(AppRoutes.healthRecoveryDetail.withParams(
        params: {'recoveryId': _nextHealthMilestone!['id']},
      ));
    } else {
      // Navigate to the health recovery list screen if we don't have a specific milestone
      context.push(AppRoutes.healthRecovery.path);
    }
  }
  
  Widget _buildMilestoneContent(BuildContext context, Color textColor, AppLocalizations l10n) {
    // If we have a next milestone, display it, otherwise use the default static content
    final hasMilestone = _nextHealthMilestone != null;
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            hasMilestone 
                ? _nextHealthMilestone!['icon'] as IconData 
                : Icons.flag_rounded,
            color: textColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasMilestone 
                    ? '${_nextHealthMilestone!['name']}' 
                    : l10n.homeNextMilestone,
                style: context.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              if (hasMilestone)
                Text(
                  'In ${_nextHealthMilestone!['daysRemaining']} days: ${_nextHealthMilestone!['description']}',
                  style: context.textTheme.bodyMedium!.copyWith(
                    color: textColor.withOpacity(0.85),
                  ),
                )
              else
                Text(
                  l10n.homeNextMilestoneDescription(_daysWithoutSmoking < 7 ? (7 - _daysWithoutSmoking).toInt() : 
                                             _daysWithoutSmoking < 14 ? (14 - _daysWithoutSmoking).toInt() : 
                                             _daysWithoutSmoking < 30 ? (30 - _daysWithoutSmoking).toInt() : 1),
                  style: context.textTheme.bodyMedium!.copyWith(
                    color: textColor.withOpacity(0.85),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildAchievementCard(BuildContext context, String milestone, String title, String description, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 160,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: context.isDarkMode 
            ? Border.all(color: context.borderColor)
            : null,
        boxShadow: context.isDarkMode 
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Keep the column as small as possible
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(context.isDarkMode ? 0.2 : 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              milestone,
              style: context.textTheme.labelSmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: color.withOpacity(context.isDarkMode ? 0.9 : 1.0),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 8), // Reduced spacing
          Text(
            title,
            style: context.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: context.contentColor,
              fontSize: 15, // Slightly smaller font
            ),
            maxLines: 1, // Limit to 1 line
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2), // Reduced spacing
          Flexible(
            child: Text(
              description,
              style: context.textTheme.bodySmall!.copyWith(
                color: context.subtitleColor,
                fontSize: 11, // Smaller font size
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDailyStatCard(BuildContext context, String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: context.isDarkMode 
            ? Border.all(color: context.borderColor)
            : null,
        boxShadow: context.isDarkMode 
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(context.isDarkMode ? 0.2 : 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color.withOpacity(context.isDarkMode ? 0.9 : 1.0),
                  size: 18,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_upward,
                color: Colors.green,
                size: 16,
              ),
              const SizedBox(width: 2),
              Text(
                _getStreakPercentage(),
                style: context.textTheme.labelSmall!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: context.textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: context.contentColor,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.textTheme.bodySmall!.copyWith(
              color: context.subtitleColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(
    BuildContext context, 
    String title,
    String subtitle,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: context.isDarkMode ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: context.contentColor,
                fontSize: 16,
              ),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.subtitleColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to safely calculate streak percentage
  String _getStreakPercentage() {
    if (_stats == null) return "--";
    
    final days = _stats!.currentStreakDays;
    if (days <= 0) return "--";
    
    final percentage = (days * 3).clamp(1, 30);
    return "$percentage%";
  }
  
  // Format the date of the last cigarette in a readable way
  String _formatLastSmokeDate(DateTime date) {
    // Today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Last cigarette date without time
    final smokeDate = DateTime(date.year, date.month, date.day);
    
    // Difference in days
    final difference = today.difference(smokeDate).inDays;
    
    if (difference == 0) {
      // If today, show "Today at HH:MM"
      return 'Hoje às ${_formatTime(date)}';
    } else if (difference == 1) {
      // If yesterday
      return 'Ontem às ${_formatTime(date)}';
    } else if (difference < 7) {
      // If in the last 7 days, show the day of the week
      final weekday = _getDayOfWeek(date.weekday);
      return '$weekday às ${_formatTime(date)}';
    } else {
      // Complete format for older dates
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${_formatTime(date)}';
    }
  }
  
  // Format time
  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  // Return the name of the day of the week
  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1: return 'Segunda';
      case 2: return 'Terça';
      case 3: return 'Quarta';
      case 4: return 'Quinta';
      case 5: return 'Sexta';
      case 6: return 'Sábado';
      case 7: return 'Domingo';
      default: return '';
    }
  }
  
  // Build a motivational card when there are no achievements
  Widget _buildMotivationalCard(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: context.primaryColor.withOpacity(0.08),
          border: Border.all(
            color: context.primaryColor.withOpacity(0.2),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.emoji_events,
                  color: context.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.importantAchievements,
                  style: context.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.primaryColor,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.achievementsDescription,
            style: context.textTheme.bodyMedium!.copyWith(
              color: context.contentColor,
              height: 1.4,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.congratulations,
            style: context.textTheme.bodyMedium!.copyWith(
              color: context.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
      ),
    );
  }
  
  // Builds a list of real achievements based on the user's health recoveries
  /// Health recovery placeholder widget when the user doesn't have data yet
  Widget _buildHealthRecoveryPlaceholder(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemBuilder: (context, index) {
          return Container(
            width: 110,
            margin: const EdgeInsets.only(right: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    index == 0 ? Icons.favorite : 
                    index == 1 ? Icons.air : 
                    Icons.spa,
                    color: context.primaryColor.withOpacity(0.5),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    l10n.comingSoon,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.contentColor.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    l10n.registerFirstCigarette,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.subtitleColor,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  List<Widget> _buildRecentAchievements(BuildContext context, AppLocalizations l10n) {
    final achievements = <Widget>[];
    final trackingBloc = BlocProvider.of<TrackingBloc>(context);
    final userRecoveries = trackingBloc.state.userHealthRecoveries;
    final allRecoveries = trackingBloc.state.healthRecoveries;
    
    // Map to store recovery details by ID
    Map<String, HealthRecovery> recoveryDetailsMap = {};
    for (var recovery in allRecoveries) {
      recoveryDetailsMap[recovery.id] = recovery;
    }
    
    // List of achievements based on the user's health recoveries
    for (var userRecovery in userRecoveries) {
      final recoveryDetails = recoveryDetailsMap[userRecovery.recoveryId];
      if (recoveryDetails != null) {
        // Determine color based on recovery type
        Color cardColor = context.primaryColor;
        if (recoveryDetails.name.toLowerCase().contains('taste')) {
          cardColor = Colors.purple;
        } else if (recoveryDetails.name.toLowerCase().contains('smell')) {
          cardColor = Colors.teal;
        } else if (recoveryDetails.name.toLowerCase().contains('circulation')) {
          cardColor = Colors.red;
        } else if (recoveryDetails.name.toLowerCase().contains('lung') || 
                   recoveryDetails.name.toLowerCase().contains('breathing')) {
          cardColor = Colors.blue;
        } else if (recoveryDetails.name.toLowerCase().contains('heart')) {
          cardColor = Colors.pink;
        }
        
        // Create achievement card
        achievements.add(
          _buildAchievementCard(
            context,
            '${recoveryDetails.daysToAchieve} ${l10n.days}',
            recoveryDetails.name,
            recoveryDetails.description,
            cardColor,
          ),
        );
      }
    }
    
    // List of basic achievements based on days without smoking
    if (_daysWithoutSmoking >= 1) {
      achievements.add(
        _buildAchievementCard(
          context,
          '24h',
          l10n.homeFirstDay,
          l10n.homeFirstDayDescription,
          Colors.amber,
        ),
      );
    }
    
    if (_daysWithoutSmoking >= 3) {
      achievements.add(
        _buildAchievementCard(
          context,
          '3 ${l10n.days}',
          l10n.homeOvercoming,
          l10n.homeOvercomingDescription,
          Colors.green,
        ),
      );
    }
    
    if (_daysWithoutSmoking >= 7) {
      achievements.add(
        _buildAchievementCard(
          context,
          '7 ${l10n.days}',
          l10n.homePersistence,
          l10n.homePersistenceDescription,
          context.primaryColor,
        ),
      );
    }
    
    // Savings achievements based on money saved
    if (_moneySavedInCents >= 2500) {
      achievements.add(
        _buildAchievementCard(
          context,
          _currencyUtils.formatWithDeviceLocale(2500, context: context),
          l10n.achievementInitialSavings,
          l10n.achievementInitialSavingsDescription,
          Colors.amber.shade700,
        ),
      );
    }
    
    // If there are no specific achievements, add at least one motivational message
    if (achievements.isEmpty) {
      achievements.add(
        _buildAchievementCard(
          context,
          l10n.supportWhenNeeded,
          l10n.homeNextMilestone,
          l10n.homeNextMilestoneDescription(1),
          context.primaryColor,
        ),
      );
    }
    
    return achievements;
  }
  
  // Money statistic card with proper currency formatting using device locale
  Widget _buildMoneyStatisticCard(
    BuildContext context, 
    int valueInCents, 
    String label, 
    Color color, 
    IconData icon,
    dynamic user, // Can be null, will use device locale
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: context.isDarkMode 
            ? Border.all(color: context.borderColor)
            : null,
        boxShadow: context.isDarkMode 
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(context.isDarkMode ? 0.2 : 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color.withOpacity(context.isDarkMode ? 0.9 : 1.0),
                  size: 24,
                ),
              ),
              const Spacer(),
              if (_daysWithoutSmoking > 0) ...[
                const Icon(
                  Icons.arrow_upward,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 2),
                Text(
                  _getStreakPercentage(),
                  style: context.textTheme.labelSmall!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            // Use device locale if user is null
            user == null 
                ? _currencyUtils.formatWithDeviceLocale(valueInCents, context: context)
                : _currencyUtils.format(valueInCents, user: user),
            style: context.textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: context.contentColor,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: context.textTheme.bodyMedium!.copyWith(
              color: context.subtitleColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}