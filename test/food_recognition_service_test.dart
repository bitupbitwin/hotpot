import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'package:hotpot_timer/data/default_items.dart';
import 'package:hotpot_timer/services/food_recognition_service.dart';

void main() {
  test('根据用户补充文字匹配已收录食材并返回缺失项', () async {
    final service = FoodRecognitionService();

    final result = await service.recognizeImage(
      image: XFile('hotpot.jpg', name: 'hotpot.jpg'),
      catalog: defaultItems,
      userHints: const ['毛肚', '肥牛', '鸭血'],
    );

    expect(result.matchedItems.map((item) => item.name), contains('脆爽毛肚'));
    expect(result.matchedItems.map((item) => item.name), contains('肥牛卷'));
    expect(result.unmatchedNames, contains('鸭血'));
  });

  test('支持用文件名里的拼音关键词匹配', () async {
    final service = FoodRecognitionService();

    final result = await service.recognizeImage(
      image: XFile('xiahua_jinzhengu.png', name: 'xiahua_jinzhengu.png'),
      catalog: defaultItems,
    );

    expect(result.matchedItems.map((item) => item.name), contains('虾滑'));
    expect(result.matchedItems.map((item) => item.name), contains('金针菇'));
  });
}
