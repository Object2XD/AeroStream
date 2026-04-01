import 'package:aero_stream/core/theme/app_theme.dart';
import 'package:aero_stream/models/info_models.dart';
import 'package:aero_stream/widgets/info_stats_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const statsHostKey = ValueKey('stats-host');

  const testItems = <InfoStatItem>[
    InfoStatItem(label: 'Stat 1', value: '101', icon: Icons.looks_one_rounded),
    InfoStatItem(label: 'Stat 2', value: '102', icon: Icons.looks_two_rounded),
    InfoStatItem(label: 'Stat 3', value: '103', icon: Icons.looks_3_rounded),
    InfoStatItem(label: 'Stat 4', value: '104', icon: Icons.looks_4_rounded),
    InfoStatItem(label: 'Stat 5', value: '105', icon: Icons.looks_5_rounded),
  ];

  testWidgets(
    'InfoStatsGrid centers the block and starts incomplete rows from the left',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1400, 1000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAeroTheme(),
          home: const Scaffold(
            body: Center(
              child: SizedBox(
                key: statsHostKey,
                width: 760,
                child: InfoStatsGrid(items: testItems),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final hostRect = tester.getRect(find.byKey(statsHostKey));
      final firstRect = tester.getRect(
        find.byKey(const ValueKey('info-stat-tile-Stat 1')),
      );
      final fourthRect = tester.getRect(
        find.byKey(const ValueKey('info-stat-tile-Stat 4')),
      );
      final fifthRect = tester.getRect(
        find.byKey(const ValueKey('info-stat-tile-Stat 5')),
      );

      final leftMargin = firstRect.left - hostRect.left;
      final rightMargin = hostRect.right - fourthRect.right;

      expect(firstRect.top, equals(fourthRect.top));
      expect(fifthRect.top, greaterThan(firstRect.top));
      expect(fifthRect.left, closeTo(firstRect.left, 0.01));
      expect(leftMargin, closeTo(rightMargin, 0.01));
    },
  );
}
