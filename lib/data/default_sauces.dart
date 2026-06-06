import '../models/sauce_recipe.dart';

/// 经网络资料验证的公认好吃火锅蘸料配方
final List<SauceRecipe> defaultSauces = [
  SauceRecipe(
    id: 's1',
    name: '蒜泥油碟',
    tag: '重庆经典',
    description: '重庆老火锅必备，简单清爽，蒜香扑鼻',
    ingredients: ['蒜蓉', '葱花', '香菜', '香油'],
  ),
  SauceRecipe(
    id: 's2',
    name: '芝麻酱蘸料',
    tag: '北方经典',
    description: '北方涮羊肉标配，浓郁醇厚，层次丰富',
    ingredients: ['芝麻酱', '花生碎', '韭菜花', '辣椒油', '葱花', '生抽'],
  ),
  SauceRecipe(
    id: 's3',
    name: '酸辣万能碟',
    tag: '万能款',
    description: '酸辣平衡，适配几乎所有食材，新手首选',
    ingredients: ['蒜蓉', '香菜', '葱花', '小米辣', '香油', '生抽', '香醋'],
  ),
  SauceRecipe(
    id: 's4',
    name: '海鲜蘸料',
    tag: '鲜香款',
    description: '鲜甜提味，专为虾滑、鱼豆腐等海鲜食材设计',
    ingredients: ['蒜蓉', '葱花', '香菜', '香油', '蚝油', '白芝麻', '小米辣'],
  ),
  SauceRecipe(
    id: 's5',
    name: '潮汕沙茶碟',
    tag: '潮汕风',
    description: '潮汕牛肉火锅灵魂伴侣，香浓回甘',
    ingredients: ['沙茶酱', '蒜蓉', '蚝油', '葱花', '白芝麻'],
  ),
];
