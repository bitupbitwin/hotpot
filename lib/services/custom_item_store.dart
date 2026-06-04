import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/hotpot_item.dart';

class CustomItemStore {
  static const String _itemsKey = 'custom_hotpot_items';

  Future<List<HotpotItem>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final rawItems = prefs.getStringList(_itemsKey) ?? const [];

    return rawItems
        .map((raw) => jsonDecode(raw) as Map<String, dynamic>)
        .map(HotpotItem.fromJson)
        .toList();
  }

  Future<void> saveItems(List<HotpotItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final rawItems = items.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_itemsKey, rawItems);
  }
}
