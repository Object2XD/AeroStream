import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/mock_info.dart';
import '../../models/info_models.dart';
import '../../widgets/aero_page_scaffold.dart';
import '../../widgets/info_panels.dart';
import '../../widgets/list_row.dart';

class SongsPlayedScreen extends HookConsumerWidget {
  const SongsPlayedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return AeroPageScaffold(
      title: 'Songs Played',
      showBackButton: true,
      largeTitle: false,
      scrollViewKey: const ValueKey('songs-played-scroll-view'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InfoSummaryCard(
            icon: Icons.music_note_rounded,
            title: '1,234',
            suffix: 'plays',
            subtitle:
                'Every replay, late-night loop, and commute favorite in one view',
          ),
          const SizedBox(height: 32),
          Text(
            'Playback Patterns',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: InfoMetricCard(label: 'This Week', value: '86 plays'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: InfoMetricCard(label: 'Daily Avg', value: '17 plays'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Top Rotation',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _TopRotationChart(items: mostPlayedSongs.take(5).toList()),
          const SizedBox(height: 32),
          Text(
            'Most Played Songs',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          InfoSectionCard(
            dividerIndent: 68,
            children: mostPlayedSongs.map((song) {
              return ListRow(
                title: song.title,
                subtitle: song.artist,
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.14,
                  ),
                  foregroundColor: theme.colorScheme.primary,
                  child: Text('${song.rank}'),
                ),
                trailing: Text(
                  '${song.plays}',
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

class _TopRotationChart extends StatelessWidget {
  const _TopRotationChart({required this.items});

  final List<SongPlayItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highestCount = items
        .map((item) => item.plays)
        .reduce((value, element) => value > element ? value : element);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            minY: 0,
            maxY: (highestCount + 24).toDouble(),
            alignment: BarChartAlignment.spaceAround,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 40,
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
                  final song = items[group.x.toInt()];
                  return BarTooltipItem(
                    '${song.title}\n${song.plays} plays',
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
                  interval: 40,
                  getTitlesWidget: (value, meta) {
                    if (value <= 0) {
                      return const SizedBox.shrink();
                    }

                    return Text(
                      value.toInt().toString(),
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
                    if (index < 0 || index >= items.length) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        '#${items[index].rank}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: List.generate(items.length, (index) {
              final song = items[index];
              final color = index == 0
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondaryContainer.withValues(
                      alpha: 0.92 - (index * 0.08),
                    );

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: song.plays.toDouble(),
                    width: 20,
                    borderRadius: BorderRadius.circular(10),
                    color: color,
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: (highestCount + 12).toDouble(),
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
