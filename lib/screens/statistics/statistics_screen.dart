import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:nameless_ai/data/providers/app_config_provider.dart';
import 'package:nameless_ai/data/providers/statistics_provider.dart';
import 'package:nameless_ai/l10n/app_localizations.dart';
import 'package:nameless_ai/services/haptic_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Widget _buildBlurBackground(BuildContext context) {
    final appConfig = Provider.of<AppConfigProvider>(context);
    if (!appConfig.enableBlurEffect) {
      return const SizedBox.shrink();
    }
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final statsProvider = Provider.of<StatisticsProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final appConfig = Provider.of<AppConfigProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: appConfig.enableBlurEffect ? Colors.transparent : null,
        flexibleSpace: _buildBlurBackground(context),
        title: Text(localizations.statistics),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: localizations.refresh,
            onPressed: () {
              HapticService.onButtonPress(context);
              Provider.of<StatisticsProvider>(context, listen: false)
                  .recalculate();
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16,
            80 + MediaQuery.of(context).padding.top, 16, isDesktop ? 16 : 96),
        children: [
          LayoutBuilder(builder: (context, constraints) {
            final crossAxisCount = isDesktop ? 5 : 2;
            final itemWidth =
                (constraints.maxWidth - (crossAxisCount - 1) * 16) /
                    crossAxisCount;

            final cards = [
              _StatInfoCard(
                icon: Icons.chat_bubble_outline,
                value: statsProvider.totalChats.toString(),
                label: localizations.totalChats,
              ),
              _StatInfoCard(
                icon: Icons.message_outlined,
                value: statsProvider.totalMessages.toString(),
                label: localizations.totalMessages,
              ),
              _StatInfoCard(
                icon: Icons.token_outlined,
                value: (statsProvider.totalPromptTokens +
                        statsProvider.totalCompletionTokens)
                    .toString(),
                label: localizations.totalTokensUsed,
              ),
              _StatInfoCard(
                icon: Icons.input_outlined,
                value: statsProvider.totalPromptTokens.toString(),
                label: localizations.promptTokens,
              ),
              _StatInfoCard(
                icon: Icons.output_outlined,
                value: statsProvider.totalCompletionTokens.toString(),
                label: localizations.completionTokens,
              ),
            ];

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: cards
                  .map((card) => SizedBox(width: itemWidth, child: card))
                  .toList(),
            );
          }),
          const SizedBox(height: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.modelUsage,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _ModelUsagePieChart(modelUsage: statsProvider.modelUsage),
            ],
          ),
          const SizedBox(height: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.chatsLast7Days,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _DailyChatsBarChart(chatData: statsProvider.chatsLast7Days),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatInfoCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _StatInfoCard(
      {required this.icon,
      required this.value,
      required this.label,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                value,
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModelUsagePieChart extends StatelessWidget {
  final Map<String, int> modelUsage;

  const _ModelUsagePieChart({required this.modelUsage});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    if (modelUsage.isEmpty) {
      return SizedBox(
          height: 100,
          child: Center(child: Text(localizations.noDataForChart)));
    }

    final sortedModels = modelUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalUsage = modelUsage.values.fold(0, (sum, item) => sum + item);

    final List<Color> baseColors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.primaryContainer,
      theme.colorScheme.secondaryContainer,
      theme.colorScheme.tertiaryContainer,
    ];

    final List<Color> colors = List.generate(
      sortedModels.length,
      (index) => baseColors[index % baseColors.length],
    );

    final pieChart = PieChart(
      PieChartData(
        sections: List.generate(sortedModels.length, (index) {
          final entry = sortedModels[index];
          final percentage = (entry.value / totalUsage) * 100;
          final sliceColor = colors[index];
          return PieChartSectionData(
            color: sliceColor,
            value: entry.value.toDouble(),
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 60,
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: ThemeData.estimateBrightnessForColor(sliceColor) ==
                      Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          );
        }),
        centerSpaceRadius: 30,
        sectionsSpace: 2,
      ),
    );

    final legendItems = List.generate(sortedModels.length, (index) {
      return _Indicator(
        color: colors[index],
        text: sortedModels[index].key,
        value: sortedModels[index].value.toString(),
      );
    });

    final isDesktop = MediaQuery.of(context).size.width >= 600;

    if (isDesktop) {
      return SizedBox(
        height: 200,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: pieChart,
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: ListView(
                children: legendItems,
              ),
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          SizedBox(
            height: 200,
            child: pieChart,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: legendItems,
          )
        ],
      );
    }
  }
}

class _DailyChatsBarChart extends StatelessWidget {
  final Map<DateTime, int> chatData;

  const _DailyChatsBarChart({required this.chatData});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    if (chatData.values.every((count) => count == 0)) {
      return SizedBox(
          height: 150,
          child: Center(child: Text(localizations.noDataForChart)));
    }

    final sortedEntries = chatData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final maxY = chatData.values
            .reduce((value, element) => value > element ? value : element)
            .toDouble() *
        1.2;

    return SizedBox(
      height: 150,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${DateFormat.MMMd().format(sortedEntries[groupIndex].key)}\n',
                  TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold),
                  children: <TextSpan>[
                    TextSpan(
                      text: rod.toY.round().toString(),
                      style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final date = sortedEntries[value.toInt()].key;
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(DateFormat.E().format(date),
                        style: theme.textTheme.bodySmall),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  if (value == 0 || value == meta.max) {
                    return SideTitleWidget(meta: meta, child: const Text(''));
                  }
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(value.toInt().toString(),
                        style: theme.textTheme.bodySmall),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(sortedEntries.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: sortedEntries[index].value.toDouble(),
                  color: theme.colorScheme.primary,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                )
              ],
            );
          }),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: theme.colorScheme.outlineVariant.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final String value;

  const _Indicator({
    required this.color,
    required this.text,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color,
        radius: 6,
      ),
      label: Text('$text: $value'),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3)),
    );
  }
}
