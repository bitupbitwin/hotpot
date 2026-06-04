import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hotpot_timer/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('启动后展示菜品名与推荐时间', (WidgetTester tester) async {
    await tester.pumpWidget(const HotpotApp());
    await tester.pump();

    expect(find.text('脆爽毛肚'), findsOneWidget);
    expect(find.textContaining('推荐'), findsWidgets);
  });

  testWidgets('点击菜品后加入已点并支持数量增加', (WidgetTester tester) async {
    await tester.pumpWidget(const HotpotApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('脆爽毛肚').last);
    await tester.pumpAndSettle();

    expect(find.text('已点 1 道'), findsOneWidget);
    expect(find.text('x2'), findsNothing);

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();

    expect(find.text('已点 1 道'), findsOneWidget);
    expect(find.text('x2'), findsWidgets);
  });
}
