import '../models/hotpot_item.dart';

/// 预设食材清单。后续可替换为从 JSON / 网络加载。
/// 没有真实图片资源时，用 emoji 兜底显示。
///
/// 替换实物图片方法：
///   1. 将图片文件放入 assets/images/，例如 assets/images/1_maodu.png
///   2. 在对应菜品的构造参数中取消 imagePath 注释并填入路径
final List<HotpotItem> defaultItems = [
  HotpotItem(id: '1',  name: '脆爽毛肚',   category: '荤菜', targetSeconds: 15,  emoji: '🥩',
    // imagePath: 'assets/images/1_maodu.png',
  ),
  HotpotItem(id: '2',  name: '鲜切鸭肠',   category: '荤菜', targetSeconds: 12,  emoji: '🐤',
    // imagePath: 'assets/images/2_duchang.png',
  ),
  HotpotItem(id: '3',  name: '嫩牛肉',     category: '荤菜', targetSeconds: 30,  emoji: '🥓',
    // imagePath: 'assets/images/3_niuniu.png',
  ),
  HotpotItem(id: '4',  name: '潮汕牛肉丸', category: '丸滑', targetSeconds: 600, emoji: '🧆',
    // imagePath: 'assets/images/4_niuwan.png',
  ),
  HotpotItem(id: '5',  name: '虾滑',       category: '丸滑', targetSeconds: 240, emoji: '🦐',
    // imagePath: 'assets/images/5_xiahua.png',
  ),
  HotpotItem(id: '6',  name: '嫩豆腐',     category: '素菜', targetSeconds: 180, emoji: '🧈',
    // imagePath: 'assets/images/6_doufu.png',
  ),
  HotpotItem(id: '7',  name: '金针菇',     category: '素菜', targetSeconds: 90,  emoji: '🍄',
    // imagePath: 'assets/images/7_jinzhengu.png',
  ),
  HotpotItem(id: '8',  name: '宽粉',       category: '主食', targetSeconds: 300, emoji: '🍜',
    // imagePath: 'assets/images/8_kuanfen.png',
  ),
  HotpotItem(id: '9',  name: '鹌鹑蛋',     category: '丸滑', targetSeconds: 360, emoji: '🥚',
    // imagePath: 'assets/images/9_anchundun.png',
  ),
  HotpotItem(id: '10', name: '生菜',       category: '素菜', targetSeconds: 20,  emoji: '🥬',
    // imagePath: 'assets/images/10_shengcai.png',
  ),
];
