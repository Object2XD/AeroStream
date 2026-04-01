import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/mock_info.dart';
import '../../models/info_models.dart';
import '../../widgets/aero_page_scaffold.dart';
import '../../widgets/info_panels.dart';
import '../../widgets/list_row.dart';

class ListeningTimeScreen extends HookConsumerWidget {
  const ListeningTimeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return AeroPageScaffold(
      title: 'Listening Time',
      showBackButton: true,
      largeTitle: false,
      scrollViewKey: const ValueKey('listening-time-scroll-view'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InfoSummaryCard(
            icon: Icons.history_rounded,
            title: '127',
            suffix: 'hours',
            subtitle: 'Total time enjoyed with your local library',
          ),
          const SizedBox(height: 32),
          Text(
            'This Week',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _WeeklyListeningChart(points: weeklyListeningData),
          const SizedBox(height: 32),
          Text(
            'Library Activity',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: InfoMetricCard(label: 'Today', value: '2.5 hrs'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: InfoMetricCard(label: 'Daily Avg', value: '1.8 hrs'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Most Played Artists',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          InfoSectionCard(
            dividerIndent: 68,
            children: topArtistsByListeningTime.map((artist) {
              return ListRow(
                title: artist.name,
                subtitle: artist.genre,
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.14,
                  ),
                  foregroundColor: theme.colorScheme.primary,
                  child: Text('${artist.rank}'),
                ),
                trailing: Text(
                  artist.duration,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _WeeklyListeningChart extends StatelessWidget {
  const _WeeklyListeningChart({required this.points});

  final List<WeeklyListeningPoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxMinutes = points
        .map((point) => point.minutes)
        .reduce((value, element) => value > element ? value : element);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            minY: 0,
            maxY: (maxMinutes + 40).toDouble(),
            alignment: BarChartAlignment.spaceAround,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 60,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.48,
                  ),
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => theme.colorScheme.surfaceContainerHigh,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final point = points[group.x.toInt()];
                  return BarTooltipItem(
                    '${point.day}\n${point.label}',
                    theme.textTheme.labelLarge!.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  interval: 60,
                  getTitlesWidget: (value, meta) {
                    if (value <= 0) {
                      return const SizedBox.shrink();
                    }

                    return Text(
                      '${(value / 60).round()}h',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= points.length) {
                      return const SizedBox.shrink();
                    }

                    final point = points[index];
                    final isPeak = point.day == 'Sat';
                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        point.day,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: isPeak
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: List.generate(points.length, (index) {
              final point = points[index];
              final isPeak = point.day == 'Sat';

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: point.minutes.toDouble(),
                    width: 22,
                    borderRadius: BorderRadius.circular(10),
                    color: isPeak
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: (maxMinutes + 20).toDouble(),
                      color: theme.colorScheme.surfaceContainerLow,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
