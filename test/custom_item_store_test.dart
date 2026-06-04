import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hotpot_timer/models/hotpot_item.dart';
import 'package:hotpot_timer/services/custom_item_store.dart';

void main() {
  test('保存并恢复自定义食材', () async {
    SharedPreferences.setMockInitialValues({});
    final store = CustomItemStore();

    await store.saveItems([
      HotpotItem(
        id: 'custom_1',
        name: '鸭血',
        category: '自定义',
        targetSeconds: 90,
        emoji: '',
      ),
    ]);

    final items = await store.loadItems();

    expect(items, hasLength(1));
    expect(items.first.name, '鸭血');
    expect(items.first.targetSeconds, 90);
  });
}
