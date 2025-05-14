import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nicotinaai_flutter/blocs/currency/currency_bloc.dart';
import 'package:nicotinaai_flutter/blocs/currency/currency_event.dart';
import 'package:nicotinaai_flutter/blocs/currency/currency_state.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_bloc.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_event.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_state.dart';
import 'package:nicotinaai_flutter/blocs/tracking/tracking_normalizer.dart';
import 'package:nicotinaai_flutter/core/routes/app_routes.dart';
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/features/tracking/models/craving.dart';
import 'package:nicotinaai_flutter/features/tracking/models/health_recovery.dart';
import 'package:nicotinaai_flutter/features/tracking/models/user_stats.dart';
import 'package:nicotinaai_flutter/l10n/app_localizations.dart';
import 'package:nicotinaai_flutter/widgets/statistics_skeleton.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class StatisticsDashboardScreen extends StatefulWidget {
  static const String routeName = '/statistics-dashboard';

  const StatisticsDashboardScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsDashboardScreen> createState() =>
      _StatisticsDashboardScreenState();
}

class _StatisticsDashboardScreenState extends State<StatisticsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize tracking data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrackingBloc>().add(InitializeTracking());

      // Garante que o CurrencyBloc também esteja inicializado
      final currencyState = context.read<CurrencyBloc>().state;
      if (!currencyState.isInitialized) {
        context.read<CurrencyBloc>().add(InitializeCurrency());
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard, style: context.titleStyle),
        backgroundColor: context.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(AppRoutes.main.path);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TrackingBloc>().add(
                RefreshAllData(forceRefresh: true),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: context.primaryColor,
          unselectedLabelColor: context.subtitleColor,
          indicatorColor: context.primaryColor,
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Savings'),
            Tab(text: 'Cravings'),
            Tab(text: 'Health'),
          ],
        ),
      ),
      body: BlocBuilder<TrackingBloc, TrackingState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const StatisticsDashboardSkeleton();
          }

          if (state.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.errorMessage}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TrackingBloc>().add(ClearError());
                      context.read<TrackingBloc>().add(InitializeTracking());
                    },
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<TrackingBloc>().add(
                RefreshAllData(forceRefresh: true),
              );
              // Esperar pelo menos 500ms para dar feedback visual ao usuário
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(context, state.userStats),
                _buildSavingsTab(context, state.userStats),
                _buildCravingsTab(context, state.cravings),
                _buildHealthTab(
                  context,
                  state.userStats,
                  state.userHealthRecoveries,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, UserStats? stats) {
    final l10n = AppLocalizations.of(context);

    // Use BlocBuilder para o CurrencyBloc para atualizar quando a moeda mudar
    return BlocBuilder<CurrencyBloc, CurrencyState>(
      builder: (context, currencyState) {
        // Debug para verificar qual moeda está sendo usada
        if (stats?.moneySaved != null) {
          debugPrint(
            '🔄 Moeda atual: ${currencyState.currencySymbol} (${currencyState.currencyCode}) - Economia: ${stats!.moneySaved} centavos',
          );
        }

        if (stats == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'No stats available yet. Start tracking to see your progress!',
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Key stats
            const SizedBox(height: 16),
            _buildSectionHeader(context, l10n.achievementCurrentProgress),
            const SizedBox(height: 16),

            // Current streak card
            _buildStatsCard(
              context,
              l10n.homeDaysWithoutSmoking(stats.currentStreakDays),
              stats.currentStreakDays.toString(),
              Icons.local_fire_department,
              Colors.orange,
              suffix: l10n.days,
            ),

            const SizedBox(height: 16),

            // Dual stats cards
            Row(
              children: [
                Expanded(
                  child: _buildStatsCard(
                    context,
                    l10n.homeCravingsResisted,
                    '${context.read<TrackingBloc>().getCravingsResisted()}',
                    Icons.smoke_free,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatsCard(
                    context,
                    l10n.cigarettesPerDay,
                    (stats.cigarettesPerDay ?? 0).toString(),
                    Icons.check_circle_outline,
                    Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // More stats
            _buildSectionHeader(context, l10n.homeNextMilestone),
            const SizedBox(height: 16),

            _buildStatsCard(
              context,
              l10n.homeMinutesLifeGained,
              '${context.read<TrackingBloc>().getMinutesLifeGained()}',
              Icons.favorite,
              Colors.red,
              suffix: 'minutes',
            ),

            const SizedBox(height: 16),

            // Money savings
            _buildStatsCard(
              context,
              l10n.potentialMonthlySavings,
              context.read<CurrencyBloc>().format(
                _calculateCumulativeSavings(
                  stats,
                  context.read<CurrencyBloc>(),
                ),
              ),
              Icons.account_balance_wallet,
              Colors.blue,
              subtitle:
                  'Based on cravings resisted: ${context.read<TrackingBloc>().getCravingsResisted()}',
            ),

            const SizedBox(height: 24),

            // Price information section
            _buildSectionHeader(context, 'Cigarette Prices'),
            const SizedBox(height: 16),

            // Pack price and per unit price cards - usando o mesmo estilo dos outros cards
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(13),
                            offset: const Offset(0, 4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.withAlpha(51),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.inventory_2,
                                  color: Colors.deepPurple,
                                  size: 24,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_upward,
                                color: Colors.green,
                                size: 16,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            stats.packPrice != null
                                ? context.read<CurrencyBloc>().format(
                                  stats.packPrice!,
                                )
                                : 'Not set',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: context.contentColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Price per Pack',
                            style: TextStyle(
                              fontSize: 14,
                              color: context.subtitleColor,
                            ),
                          ),
                          if (stats.cigarettesPerPack != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${stats.cigarettesPerPack} cigarettes/pack',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.subtitleColor.withAlpha(179),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(13),
                            offset: const Offset(0, 4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.withAlpha(51),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.local_offer,
                                  color: Colors.indigo,
                                  size: 24,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_upward,
                                color: Colors.green,
                                size: 16,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _calculateUnitPrice(
                              stats,
                              context.read<CurrencyBloc>(),
                            ),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: context.contentColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Price per Unit',
                            style: TextStyle(
                              fontSize: 14,
                              color: context.subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSavingsTab(BuildContext context, UserStats? stats) {
    final l10n = AppLocalizations.of(context);

    // Use BlocBuilder para o CurrencyBloc para atualizar quando a moeda mudar
    return BlocBuilder<CurrencyBloc, CurrencyState>(
      builder: (context, currencyState) {
        // Debug para verificar qual moeda está sendo usada
        if (stats?.moneySaved != null) {
          debugPrint(
            '🔄 Moeda atual: ${currencyState.currencySymbol} (${currencyState.currencyCode}) - Economia: ${stats!.moneySaved} centavos',
          );
        }

        if (stats == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('No savings data available yet.'),
            ),
          );
        }

        // Generate data for the savings chart based on actual calculations
        final days = stats.currentStreakDays > 0 ? stats.currentStreakDays : 7;

        // Log values for debugging
        if (kDebugMode) {
          print('📊 [Dashboard] Auditoria do gráfico de economia:');
          print('   - Dias sem fumar: $days');
          print('   - Cigarros por dia: ${stats.cigarettesPerDay}');
          print('   - Economia total (DB): ${stats.moneySaved} centavos');

          if (stats.packPrice != null &&
              stats.cigarettesPerPack != null &&
              stats.cigarettesPerPack! > 0) {
            final pricePerCigarette =
                stats.packPrice! / stats.cigarettesPerPack!;
            print('   - Preço do maço: ${stats.packPrice} centavos');
            print('   - Cigarros por maço: ${stats.cigarettesPerPack}');
            print('   - Preço por cigarro: $pricePerCigarette centavos');
          }
        }

        // Calcula economia real por dia com base nos cravings resistidos
        // e no preço por cigarro
        final cravingsResisted =
            context.read<TrackingBloc>().getCravingsResisted();
        double dailySavingCents;

        // Se temos informações de preço, calcular economia real
        if (stats.packPrice != null &&
            stats.cigarettesPerPack != null &&
            stats.cigarettesPerPack! > 0) {
          final pricePerCigarette = stats.packPrice! / stats.cigarettesPerPack!;
          // Usar cigarros por dia como base para economia diária
          final cigarettesPerDay =
              stats.cigarettesPerDay ?? 10; // Valor padrão se não disponível
          dailySavingCents = cigarettesPerDay * pricePerCigarette;
        } else {
          // Fallback: usar um valor estimado de acordo com a moeda atual
          // 10,00 unidades da moeda atual (normalmente equivalente a R$10, $10, €10, etc.)
          dailySavingCents =
              1000.0; // 1000 centavos = 10 unidades da moeda, independente de qual seja
        }

        if (kDebugMode) {
          print('   - Economia diária estimada: $dailySavingCents centavos');
        }

        // Gerar pontos do gráfico com valores crescentes de economia
        final List<FlSpot> savingsSpots = List.generate(days > 0 ? days : 7, (
          index,
        ) {
          // Economia acumulada até o dia (index+1)
          final dayNumber = index + 1;
          final cumulativeSavings =
              dayNumber *
              dailySavingCents /
              100; // Convertido para unidades da moeda para exibição

          if (kDebugMode && index % 3 == 0) {
            final currencyBloc = context.read<CurrencyBloc>();
            print(
              '   - Dia ${index + 1}: economia acumulada = ${(cumulativeSavings).toStringAsFixed(2)} ${currencyBloc.state.currencyCode}',
            );
          }

          return FlSpot(index.toDouble(), cumulativeSavings);
        });

        final currencyBloc = context.read<CurrencyBloc>();

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionHeader(context, l10n.potentialMonthlySavings),
            const SizedBox(height: 16),

            // Money saved card
            _buildStatsCard(
              context,
              l10n.savingsCalculator,
              currencyBloc.format(
                _calculateCumulativeSavings(stats, currencyBloc),
              ),
              Icons.account_balance_wallet,
              Colors.blue,
              subtitle:
                  'Based on cravings resisted: ${context.read<TrackingBloc>().getCravingsResisted()}',
            ),

            const SizedBox(height: 24),

            // Projected savings
            _buildSectionHeader(context, l10n.potentialMonthlySavings),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatsCard(
                    context,
                    'Month',
                    currencyBloc.format(
                      _calculateProjectedSavings(stats, 30, currencyBloc),
                    ),
                    Icons.calendar_month,
                    Colors.teal,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatsCard(
                    context,
                    'Year',
                    currencyBloc.format(
                      _calculateProjectedSavings(stats, 365, currencyBloc),
                    ),
                    Icons.cake,
                    Colors.amber,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Savings chart
            _buildSectionHeader(context, l10n.achievementCategorySavings),
            const SizedBox(height: 16),

            AspectRatio(
              aspectRatio: 1.6, // Width to height ratio (wider than pie chart)
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    // Calcular os valores máximos para ajustar a escala do gráfico
                    minY: 0, // Começar em 0
                    // Find the maximum amount from the last day's savings
                    maxY:
                        savingsSpots.isNotEmpty
                            ? savingsSpots.last.y * 1.2
                            : // 20% de margem superior
                            100, // Valor padrão
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            // Mostrar só o primeiro dia, o último e os múltiplos de 7
                            if (value == 0 ||
                                value % 7 == 0 ||
                                value == days - 1) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  '${value.toInt() + 1}d',
                                  style: TextStyle(
                                    color: context.subtitleColor,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            // Se o valor é zero, não mostrar nada (evita sobreposição com o eixo X)
                            if (value <= 0.1) return const SizedBox();

                            String yLabel = '';
                            // Usar o CurrencyBloc para formatação correta
                            final currencyBloc = context.read<CurrencyBloc>();
                            final symbol = currencyBloc.state.currencySymbol;

                            // Formato monetário simplificado para o eixo Y
                            if (value < 10) {
                              // Valores pequenos (0-9): mostrar com símbolo da moeda atual
                              yLabel = '$symbol${value.toInt()}';
                            } else if (value < 1000) {
                              // Valores médios (10-999): mostrar com símbolo da moeda atual
                              yLabel = '$symbol${value.toInt()}';
                            } else {
                              // Valores grandes (1000+): mostrar como X.X mil com símbolo da moeda atual
                              yLabel =
                                  '$symbol${(value / 1000).toStringAsFixed(1)}k';
                            }

                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                yLabel,
                                style: TextStyle(
                                  color: context.subtitleColor,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          },
                          // Intervalo entre as linhas do eixo Y
                          interval:
                              savingsSpots.isNotEmpty &&
                                      savingsSpots.last.y > 20
                                  ? savingsSpots.last.y /
                                      5 // Dividir em 5 partes
                                  : 10, // Intervalo padrão
                          reservedSize: 40, // Mais espaço para os valores
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: savingsSpots,
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 3,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.green.withAlpha(26),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Column(
              children: [
                // Chart explanation
                Text(
                  'Estimated savings based on your daily cigarette consumption',
                  style: TextStyle(
                    color: context.contentColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.savingsCalculatorDescription,
                  style: TextStyle(
                    color: context.subtitleColor,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Cigarette price cards
            _buildSectionHeader(context, 'Cost Analysis'),
            const SizedBox(height: 16),

            // Price per unit and cigarettes avoided - usando o mesmo estilo dos outros cards
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(13),
                            offset: const Offset(0, 4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.withAlpha(51),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.local_offer,
                                  color: Colors.indigo,
                                  size: 24,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_upward,
                                color: Colors.green,
                                size: 16,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _calculateUnitPrice(stats, currencyBloc),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: context.contentColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Unit Cost',
                            style: TextStyle(
                              fontSize: 14,
                              color: context.subtitleColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Per cigarette',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.subtitleColor.withAlpha(179),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(13),
                            offset: const Offset(0, 4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withAlpha(51),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.smoke_free,
                                  color: Colors.green,
                                  size: 24,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_upward,
                                color: Colors.green,
                                size: 16,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${context.read<TrackingBloc>().getCravingsResisted()}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: context.contentColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Cravings Resisted',
                            style: TextStyle(
                              fontSize: 14,
                              color: context.subtitleColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cigarettes not smoked',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.subtitleColor.withAlpha(179),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCravingsTab(BuildContext context, List<Craving> cravings) {
    final l10n = AppLocalizations.of(context);

    if (cravings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(l10n.emptyNotificationsDescription),
        ),
      );
    }

    // Get accurate craving counts from TrackingBloc normalizer
    int resistedCount = context.read<TrackingBloc>().getCravingsResisted();

    // Calculate smoked and alternative counts from the cravings list
    int smokedCount = 0;
    int alternativeCount = 0;

    for (final craving in cravings) {
      if (craving.outcome == CravingOutcome.smoked) {
        smokedCount++;
      } else if (craving.outcome == CravingOutcome.alternative) {
        alternativeCount++;
      }
    }

    final totalCravings = resistedCount + smokedCount + alternativeCount;
    final resistedPercentage =
        totalCravings > 0 ? (resistedCount / totalCravings * 100).round() : 0;

    // Data will be directly used in the pie chart sections

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionHeader(context, l10n.homeCravingsResisted),
        const SizedBox(height: 16),

        // Success rate card
        _buildStatsCard(
          context,
          l10n.achievementUnlocked,
          '$resistedPercentage%',
          Icons.trending_up,
          Colors.blue,
          subtitle: l10n.achievementCompleted,
        ),

        const SizedBox(height: 16),

        // Cravings stats
        Row(
          children: [
            Expanded(
              child: _buildStatsCard(
                context,
                'Resisted',
                resistedCount.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatsCard(
                context,
                'Total Cravings',
                '${totalCravings}',
                Icons.analytics,
                Colors.purple,
                subtitle: 'Including synced, pending and failed',
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Cravings chart
        _buildSectionHeader(context, 'Craving Outcomes'),
        const SizedBox(height: 16),

        AspectRatio(
          aspectRatio: 1.4, // Width to height ratio
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: Colors.green,
                    value: resistedCount.toDouble(),
                    title: '$resistedCount',
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.red,
                    value: smokedCount.toDouble(),
                    title: '$smokedCount',
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.blue,
                    value: alternativeCount.toDouble(),
                    title: '$alternativeCount',
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
                centerSpaceRadius: 40,
                sectionsSpace: 0,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(context, l10n.yes, Colors.green),
            const SizedBox(width: 24),
            _buildLegendItem(context, l10n.no, Colors.red),
            const SizedBox(width: 24),
            _buildLegendItem(context, 'Alternative', Colors.blue),
          ],
        ),

        const SizedBox(height: 24),

        // Recent cravings
        _buildSectionHeader(context, 'Recent Cravings'),
        const SizedBox(height: 16),

        ...cravings
            .take(5)
            .map((craving) => _buildCravingListItem(context, craving)),
      ],
    );
  }

  Widget _buildHealthTab(
    BuildContext context,
    UserStats? stats,
    List<UserHealthRecovery> healthRecoveries,
  ) {
    final l10n = AppLocalizations.of(context);

    if (stats == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(l10n.noRecoveriesFound),
        ),
      );
    }

    final daysSmokeFree = stats.currentStreakDays;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionHeader(context, l10n.homeHealthRecovery),
        const SizedBox(height: 16),

        // Days smoke free
        _buildStatsCard(
          context,
          l10n.daysSmokeFree(daysSmokeFree),
          daysSmokeFree.toString(),
          Icons.health_and_safety,
          Colors.teal,
          suffix: l10n.days,
        ),

        const SizedBox(height: 24),

        // Health indicators
        _buildSectionHeader(context, 'Health Indicators'),
        const SizedBox(height: 16),

        // Health stats
        Row(
          children: [
            Expanded(
              child: _buildStatsCard(
                context,
                l10n.homeMinutesLifeGained,
                '${context.read<TrackingBloc>().getMinutesLifeGained()}',
                Icons.favorite,
                Colors.red,
                suffix: 'minutes',
                subtitle: '6 minutes gained per craving resisted',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatsCard(
                context,
                'Breath capacity',
                '${context.read<TrackingBloc>().getBreathCapacityPercent()}%',
                Icons.air,
                Colors.blue,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Health recovery timeline
        healthRecoveries.isNotEmpty
            ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(context, 'Recovery Timeline'),
                const SizedBox(height: 16),
                ...healthRecoveries
                    .take(5)
                    .map(
                      (recovery) => _buildHealthRecoveryItem(
                        context,
                        recovery,
                        daysSmokeFree,
                      ),
                    ),
              ],
            )
            : Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(child: Text(l10n.noRecentRecoveries)),
            ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: context.primaryColor,
        ),
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
    String? suffix,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Icon(Icons.arrow_upward, color: Colors.green, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: context.contentColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (suffix != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
                  child: Text(
                    suffix,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.subtitleColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: context.subtitleColor),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: context.subtitleColor.withAlpha(179),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCravingListItem(BuildContext context, Craving craving) {
    final dateFormat = DateFormat('MMM d, h:mm a');
    final outcomeColors = [Colors.green, Colors.red, Colors.blue];
    final outcomeIcons = [
      Icons.check_circle,
      Icons.smoking_rooms,
      Icons.swap_horiz,
    ];
    final outcomeTexts = ['Resisted', 'Smoked', 'Alternative'];

    // Convert CravingOutcome enum to int index
    int outcomeIndex = 0; // Default to resisted
    if (craving.outcome == CravingOutcome.resisted) {
      outcomeIndex = 0;
    } else if (craving.outcome == CravingOutcome.smoked) {
      outcomeIndex = 1;
    } else if (craving.outcome == CravingOutcome.alternative) {
      outcomeIndex = 2;
    }
    
    // Using a more flexible layout approach without fixed height
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outcomeColors[outcomeIndex].withAlpha(77)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: outcomeColors[outcomeIndex].withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Icon(
              outcomeIcons[outcomeIndex],
              color: outcomeColors[outcomeIndex],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        _getCravingIntensityText(craving.intensity),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context.contentColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      outcomeTexts[outcomeIndex],
                      style: TextStyle(
                        color: outcomeColors[outcomeIndex],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Separate rows for date and location to prevent overflow
                Text(
                  dateFormat.format(craving.timestamp),
                  style: TextStyle(fontSize: 12, color: context.subtitleColor),
                  overflow: TextOverflow.ellipsis,
                ),
                if (craving.location != null)
                  Text(
                    craving.location!,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.subtitleColor.withAlpha(179),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRecoveryItem(
    BuildContext context,
    UserHealthRecovery recovery,
    int daysSmokeFree,
  ) {
    final l10n = AppLocalizations.of(context);
    final bool isAchieved = recovery.isAchieved;
    final Color statusColor = isAchieved ? Colors.green : Colors.orange;

    // Get the recovery details from TrackingBloc state
    final trackingState = context.read<TrackingBloc>().state;
    final recoveryDetails = trackingState.healthRecoveries.firstWhere(
      (r) => r.id == recovery.recoveryId,
      orElse:
          () => HealthRecovery(
            id: recovery.recoveryId,
            name: 'Unknown Recovery',
            description: '',
            daysToAchieve: recovery.daysToAchieve,
          ),
    );

    // Calculate percentage
    int daysRequired = recovery.daysToAchieve;
    double percentage = daysSmokeFree / daysRequired;
    if (percentage > 1) percentage = 1;

    // Using a flexible layout without fixed height
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      recoveryDetails.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.contentColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAchieved
                          ? l10n.achievedOn(recovery.achievedAt)
                          : l10n.daysToAchieve(daysRequired),
                      style: TextStyle(
                        fontSize: 12,
                        color: context.subtitleColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isAchieved ? l10n.achieved : l10n.progress,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (!isAchieved) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey.withAlpha(51),
                color: statusColor,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.daysRemaining(
                (daysRequired - daysSmokeFree).clamp(0, daysRequired),
              ),
              style: TextStyle(fontSize: 12, color: statusColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: context.subtitleColor),
        ),
      ],
    );
  }

  /// Calcula as economias acumuladas com base nos cigarros evitados realmente
  int _calculateCumulativeSavings(UserStats stats, CurrencyBloc currencyBloc) {
    // Se não tiver as informações necessárias, retorna a economia atual do banco de dados
    if (stats.packPrice == null ||
        stats.cigarettesPerPack == null ||
        stats.cigarettesPerPack == 0) {
      if (kDebugMode) {
        print(
          '💰 [Dashboard] Informações insuficientes para cálculo de economia:',
        );
        print('   - Preço do maço: ${stats.packPrice}');
        print('   - Cigarros por maço: ${stats.cigarettesPerPack}');
        print('   - Usando valor do banco: ${stats.moneySaved} centavos');
      }
      return stats.moneySaved;
    }

    // Usa o valor de cravings resistidos em vez de cigarros evitados
    final int cravingsResisted =
        context.read<TrackingBloc>().getCravingsResisted();
    if (cravingsResisted <= 0) {
      if (kDebugMode) {
        print('💰 [Dashboard] Nenhum craving resistido ainda:');
        print('   - Cravings resistidos: $cravingsResisted');
        print('   - Usando valor do banco: ${stats.moneySaved} centavos');
      }
      return stats.moneySaved;
    }

    // Calcula o preço por unidade (em centavos)
    final double pricePerCigarette =
        stats.packPrice! / stats.cigarettesPerPack!;

    // Calcula a economia acumulada com base nos cravings resistidos (cada craving = 1 cigarro)
    final int cumulativeSavings =
        (cravingsResisted * pricePerCigarette).round();

    if (kDebugMode) {
      print('💰 [Dashboard] Cálculo de economia acumulada:');
      print('   - Preço do maço: ${stats.packPrice} centavos');
      print('   - Cigarros por maço: ${stats.cigarettesPerPack}');
      print('   - Preço por cigarro: $pricePerCigarette centavos');
      print('   - Cravings resistidos: $cravingsResisted');
      print('   - Cigarros evitados (DB): ${stats.cigarettesAvoided}');
      print('   - Economia no DB: ${stats.moneySaved} centavos');
      print('   - Economia calculada: $cumulativeSavings centavos');
      print('   - Formatado: ${currencyBloc.format(cumulativeSavings)}');

      // Teste a formatação do pricePerCigarette diretamente para debug
      final int unitPriceInCents = pricePerCigarette.round();
      print(
        '   - Preço unitário formatado: ${currencyBloc.format(unitPriceInCents)}',
      );
    }

    // Use o valor do banco se for maior - isso resolve o problema quando o
    // cálculo baseado em cigarros está muito baixo devido a dados incorretos ou faltantes
    if (stats.moneySaved > cumulativeSavings) {
      if (kDebugMode) {
        print('💰 [Dashboard] Usando economia do banco por ser maior:');
        print('   - Valor do banco: ${stats.moneySaved} centavos');
        print('   - Valor calculado: $cumulativeSavings centavos');
      }
      return stats.moneySaved;
    }

    // Verifica se o valor calculado é muito pequeno (abaixo de 100 centavos)
    // e o usuário tem cravings suficientes para sugerir um valor maior
    if (cumulativeSavings < 100 && cravingsResisted > 3) {
      // Se o valor é muito pequeno mas temos muitos cravings resistidos,
      // provavelmente há um erro no preço por cigarro
      final int estimatedSavings =
          cravingsResisted * 100; // Estimate 1 real per cigarette

      if (kDebugMode) {
        print('💰 [Dashboard] Valor calculado muito baixo, usando estimativa:');
        print('   - Valor calculado original: $cumulativeSavings centavos');
        print('   - Valor estimado: $estimatedSavings centavos');
      }

      return estimatedSavings;
    }

    return cumulativeSavings;
  }

  /// Calcula as economias projetadas para um determinado período com base nos dados do usuário
  int _calculateProjectedSavings(
    UserStats stats,
    int daysInPeriod,
    CurrencyBloc currencyBloc,
  ) {
    // Se não tiver as informações necessárias, retorna 0
    if (stats.packPrice == null ||
        stats.cigarettesPerPack == null ||
        stats.cigarettesPerPack == 0 ||
        stats.cigarettesPerDay == null ||
        stats.cigarettesPerDay == 0) {
      if (kDebugMode) {
        print(
          '💰 [Dashboard] Informações insuficientes para projeção de economia:',
        );
        print('   - Preço do maço: ${stats.packPrice} centavos');
        print('   - Cigarros por maço: ${stats.cigarettesPerPack}');
        print('   - Cigarros por dia: ${stats.cigarettesPerDay}');
        print('   - Período em dias: $daysInPeriod');
      }
      return 0;
    }

    // Calcula o preço por unidade (em centavos)
    final double pricePerCigarette =
        stats.packPrice! / stats.cigarettesPerPack!;

    // Calcula os cigarros que seriam fumados no período
    final int cigarettesPerDay = stats.cigarettesPerDay!;
    final int cigarettesInPeriod = cigarettesPerDay * daysInPeriod;

    // Calcula a economia projetada para o período
    final int projectedSavings =
        (cigarettesInPeriod * pricePerCigarette).round();

    if (kDebugMode) {
      print(
        '💰 [Dashboard] AUDITORIA de economias projetadas para $daysInPeriod dias:',
      );
      print('   - Preço do maço: ${stats.packPrice} centavos');
      print('   - Cigarros por maço: ${stats.cigarettesPerPack}');
      print('   - Preço por cigarro: $pricePerCigarette centavos');
      print('   - Cigarros por dia (DB): $cigarettesPerDay');
      print(
        '   - Cigarros no período ($daysInPeriod dias): $cigarettesInPeriod',
      );
      print(
        '   - Cálculo: $cigarettesInPeriod cigarros * $pricePerCigarette centavos = $projectedSavings centavos',
      );
      print('   - Economia projetada: $projectedSavings centavos');
      print('   - Formatado: ${currencyBloc.format(projectedSavings)}');

      // Valores para teste e depuração
      final testDailyRate = 20; // Valor comum para fumantes
      final testCigarettesInPeriod = testDailyRate * daysInPeriod;
      final testProjected =
          (testCigarettesInPeriod * pricePerCigarette).round();
      print(
        '   - TESTE com 20 cigarros/dia: $testCigarettesInPeriod cigarros no período',
      );
      print('   - TESTE economia projetada: $testProjected centavos');
      print('   - TESTE formatado: ${currencyBloc.format(testProjected)}');
    }

    // Verificação de valor mínimo plausível baseado no preço do maço
    // Para evitar valores muito baixos devido a dados incorretos
    final int minimumPerDay = 10; // Valor mínimo razoável para fumantes

    if (cigarettesPerDay < minimumPerDay) {
      final int reasonableAmount = minimumPerDay * daysInPeriod;
      final int reasonableSavings =
          (reasonableAmount * pricePerCigarette).round();

      if (kDebugMode) {
        print(
          '💰 [Dashboard] Cigarros por dia muito baixo ($cigarettesPerDay), usando valor razoável ($minimumPerDay):',
        );
        print('   - Cigarros no período original: $cigarettesInPeriod');
        print('   - Cigarros no período ajustado: $reasonableAmount');
        print('   - Economia projetada original: $projectedSavings centavos');
        print('   - Economia projetada ajustada: $reasonableSavings centavos');
      }

      return reasonableSavings;
    }

    // Se o valor projetado é muito baixo, podemos estar com um problema de preço por cigarro
    if (projectedSavings < 100 * daysInPeriod && cigarettesInPeriod > 3) {
      // Usar o valor mínimo de 1 unidade da moeda atual por cigarro (independente da moeda)
      final int minimumSavings =
          cigarettesInPeriod * 100; // 1 unidade da moeda por cigarro

      if (kDebugMode) {
        print('💰 [Dashboard] Projeção muito baixa, usando estimativa mínima:');
        print(
          '   - Preço por cigarro muito baixo: $pricePerCigarette centavos',
        );
        print('   - Valor projetado original: $projectedSavings centavos');
        print(
          '   - Valor mínimo estimado: $minimumSavings centavos (1 unidade da moeda por cigarro)',
        );
      }

      return minimumSavings;
    }

    return projectedSavings;
  }

  /// Calcula o preço unitário de cada cigarro com base no preço do maço e na quantidade de cigarros por maço
  String _calculateUnitPrice(UserStats stats, CurrencyBloc currencyBloc) {
    // Se não tiver as informações necessárias, retorna "Not available"
    if (stats.packPrice == null ||
        stats.cigarettesPerPack == null ||
        stats.cigarettesPerPack == 0) {
      if (kDebugMode) {
        print(
          '💰 [Dashboard] Informações insuficientes para cálculo de preço unitário:',
        );
        print('   - Preço do maço: ${stats.packPrice}');
        print('   - Cigarros por maço: ${stats.cigarettesPerPack}');
      }
      return 'Not available';
    }

    // Calcula o preço por unidade (em centavos) - usando divisão com ponto flutuante e arredondamento
    // para ser consistente com o cálculo em ImprovedStatsCalculator
    final double pricePerCigarette =
        stats.packPrice! / stats.cigarettesPerPack!;
    final int unitPriceInCents = pricePerCigarette.round();

    if (kDebugMode) {
      print('💰 [Dashboard] Cálculo de preço por unidade:');
      print('   - Preço do maço: ${stats.packPrice} centavos');
      print('   - Cigarros por maço: ${stats.cigarettesPerPack}');
      print('   - Preço por cigarro (float): $pricePerCigarette centavos');
      print('   - Preço por cigarro (arredondado): $unitPriceInCents centavos');
      print('   - Formatado: ${currencyBloc.format(unitPriceInCents)}');

      // Testa valores específicos para debugging
      print('   - Teste com valor 100 centavos: ${currencyBloc.format(100)}');
      print('   - Teste com valor 60 centavos: ${currencyBloc.format(60)}');
      print('   - Símbolo atual: ${currencyBloc.state.currencySymbol}');
      print('   - Código atual: ${currencyBloc.state.currencyCode}');
    }

    // Se o preço por unidade for muito baixo (menos de 3 centavos), provavelmente há um erro nos dados
    if (unitPriceInCents < 3) {
      if (kDebugMode) {
        print(
          '💰 [Dashboard] Preço por unidade muito baixo, usando valor mínimo:',
        );
        print('   - Valor original: $unitPriceInCents centavos');
        print('   - Usando valor mínimo: 100 centavos (R\$1,00)');
      }

      // Retornar um valor mínimo razoável (R\$1,00)
      return currencyBloc.format(100);
    }

    // Formata o valor usando o CurrencyBloc
    return currencyBloc.format(unitPriceInCents);
  }

  String _getCravingIntensityText(CravingIntensity intensity) {
    if (intensity == CravingIntensity.low) {
      return 'Low Intensity';
    } else if (intensity == CravingIntensity.moderate) {
      return 'Moderate Intensity';
    } else if (intensity == CravingIntensity.high) {
      return 'High Intensity';
    } else {
      return 'Very High Intensity';
    }
  }

  // Method removed - now using TrackingBloc.getBreathCapacityPercent() for consistent calculations
}
