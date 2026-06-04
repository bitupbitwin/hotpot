import 'package:image_picker/image_picker.dart';

import '../models/hotpot_item.dart';

class RecognitionResult {
  final List<HotpotItem> matchedItems;
  final List<String> unmatchedNames;

  const RecognitionResult({
    required this.matchedItems,
    required this.unmatchedNames,
  });
}

class FoodRecognitionService {
  /// 本地可运行的识别占位层：从文件名/路径中的中文、拼音或英文关键词匹配。
  /// 后续接入真实视觉 API 时，只需要替换这个方法的内部实现。
  Future<RecognitionResult> recognizeImage({
    required XFile image,
    required List<HotpotItem> catalog,
    List<String> userHints = const [],
  }) async {
    final sourceText = [
      image.name,
      image.path,
      ...userHints,
    ].join(' ').toLowerCase();

    final matched = <HotpotItem>[];
    for (final item in catalog) {
      final keys = [
        item.name,
        item.category,
        ...item.aliases,
      ].map((key) => key.toLowerCase());

      if (keys.any((key) => key.isNotEmpty && sourceText.contains(key))) {
        matched.add(item);
      }
    }

    final unmatched = userHints
        .expand(_splitFoodNames)
        .where((name) => name.trim().isNotEmpty)
        .where((name) => !_matchesCatalog(name, catalog))
        .toSet()
        .toList();

    return RecognitionResult(matchedItems: matched, unmatchedNames: unmatched);
  }

  List<String> parseInputNames(String value) => _splitFoodNames(value).toList();

  Iterable<String> _splitFoodNames(String value) {
    return value
        .split(RegExp(r'[,，、\s\n]+'))
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty);
  }

  bool _matchesCatalog(String name, List<HotpotItem> catalog) {
    final lowerName = name.toLowerCase();
    return catalog.any((item) {
      final keys = [
        item.name,
        item.category,
        ...item.aliases,
      ].map((key) => key.toLowerCase());
      return keys.any((key) => key == lowerName || key.contains(lowerName));
    });
  }
}
