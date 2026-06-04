import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hotpot_timer/data/default_items.dart';
import 'package:hotpot_timer/models/selected_hotpot_item.dart';
import 'package:hotpot_timer/services/selected_item_store.dart';

void main() {
  test('保存并恢复已点食材数量和开始时间', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SelectedItemStore();
    final startedAt = DateTime(2026, 6, 4, 20, 0, 0);

    await store.saveItems([
      SelectedHotpotItem(
        item: defaultItems.first,
        quantity: 2,
        startedAt: startedAt,
      ),
    ]);

    final items = await store.loadItems();

    expect(items, hasLength(1));
    expect(items.first.item.name, defaultItems.first.name);
    expect(items.first.quantity, 2);
    expect(items.first.startedAt, startedAt);
  });
}
