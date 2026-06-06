import 'package:flutter/material.dart';
import '../models/sauce_recipe.dart';
import '../data/default_sauces.dart';

const _kTabooOptions = ['香菜', '葱花', '花生', '腐乳', '小米辣', '香油', '蒜蓉'];

class SeasoningScreen extends StatelessWidget {
  final Set<String> tabooItems;
  final List<SauceRecipe> customSauces;
  final ValueChanged<String> onToggleTaboo;
  final ValueChanged<SauceRecipe> onAddCustomSauce;
  final ValueChanged<String> onRemoveCustomSauce;

  const SeasoningScreen({
    super.key,
    required this.tabooItems,
    required this.customSauces,
    required this.onToggleTaboo,
    required this.onAddCustomSauce,
    required this.onRemoveCustomSauce,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '🥣 调料',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader('忌口设置'),
            const SizedBox(height: 4),
            const Text(
              '选中后，含该食材的蘸料方案将标红提示',
              style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _kTabooOptions.map((item) {
                final selected = tabooItems.contains(item);
                return FilterChip(
                  label: Text(item),
                  selected: selected,
                  onSelected: (_) => onToggleTaboo(item),
                  labelStyle: TextStyle(
                    color: selected ? const Color(0xFFFF3B30) : const Color(0xFFCCCCCC),
                    fontSize: 13,
                  ),
                  backgroundColor: const Color(0xFF1E1E1E),
                  selectedColor: const Color(0xFF3D1A1A),
                  checkmarkColor: const Color(0xFFFF3B30),
                  side: BorderSide(
                    color: selected
                        ? const Color(0xFFFF3B30).withValues(alpha: 0.6)
                        : const Color(0xFF333333),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  showCheckmark: true,
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            _SectionHeader('推荐蘸料方案'),
            const SizedBox(height: 4),
            const Text(
              '经网络资料验证的经典配方，按个人口味调整比例',
              style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 12),
            ...defaultSauces.map((recipe) => _SauceCard(
              recipe: recipe,
              tabooItems: tabooItems,
            )),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _SectionHeader('我的蘸料'),
                TextButton.icon(
                  onPressed: () => _showAddDialog(context),
                  icon: const Icon(Icons.add, size: 18, color: Color(0xFFFFCC00)),
                  label: const Text(
                    '新增方案',
                    style: TextStyle(color: Color(0xFFFFCC00), fontSize: 13),
                  ),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (customSauces.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: const Column(
                  children: [
                    Text('🍶', style: TextStyle(fontSize: 32)),
                    SizedBox(height: 8),
                    Text('还没有自定义方案', style: TextStyle(color: Color(0xFF555555), fontSize: 13)),
                    Text('点右上角"新增方案"创建属于你的蘸料', style: TextStyle(color: Color(0xFF444444), fontSize: 12)),
                  ],
                ),
              )
            else
              ...customSauces.map((recipe) => _SauceCard(
                recipe: recipe,
                tabooItems: tabooItems,
                onDelete: () => onRemoveCustomSauce(recipe.id),
              )),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final ingCtrl = TextEditingController();

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: const Color(0xFF242424),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF333333)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF333333)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFFCC00)),
      ),
      hintStyle: const TextStyle(color: Color(0xFF555555), fontSize: 13),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('新增蘸料方案', style: TextStyle(color: Colors.white, fontSize: 17)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: inputDecoration.copyWith(hintText: '方案名称（如：我的特调）'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ingCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 3,
              decoration: inputDecoration.copyWith(
                hintText: '食材列表，用逗号分隔\n例：芝麻酱，蒜蓉，香油，葱花',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消', style: TextStyle(color: Color(0xFF888888))),
          ),
          TextButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final ings = ingCtrl.text
                  .split(RegExp(r'[，,]'))
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();
              if (name.isNotEmpty && ings.isNotEmpty) {
                onAddCustomSauce(SauceRecipe(
                  id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  tag: '自定义',
                  description: '',
                  ingredients: ings,
                  isCustom: true,
                ));
                Navigator.pop(ctx);
              }
            },
            child: const Text('保存', style: TextStyle(color: Color(0xFFFFCC00), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ).then((_) {
      nameCtrl.dispose();
      ingCtrl.dispose();
    });
  }
}

class _SauceCard extends StatelessWidget {
  final SauceRecipe recipe;
  final Set<String> tabooItems;
  final VoidCallback? onDelete;

  const _SauceCard({required this.recipe, required this.tabooItems, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final hasTaboo = recipe.ingredients.any((i) => tabooItems.contains(i));

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasTaboo
              ? const Color(0xFFFF3B30).withValues(alpha: 0.35)
              : const Color(0xFF2A2A2A),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                recipe.name,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              _TagBadge(recipe.tag, isCustom: recipe.isCustom),
              if (hasTaboo) ...[
                const SizedBox(width: 6),
                const _TagBadge('含忌口', isWarning: true),
              ],
              const Spacer(),
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.delete_outline, size: 18, color: Color(0xFF555555)),
                ),
            ],
          ),
          if (recipe.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              recipe.description,
              style: const TextStyle(color: Color(0xFF777777), fontSize: 12),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: recipe.ingredients.map((ing) {
              final isTaboo = tabooItems.contains(ing);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isTaboo ? const Color(0xFF3A1818) : const Color(0xFF242424),
                  borderRadius: BorderRadius.circular(4),
                  border: isTaboo
                      ? Border.all(color: const Color(0xFFFF3B30).withValues(alpha: 0.4))
                      : null,
                ),
                child: Text(
                  ing,
                  style: TextStyle(
                    fontSize: 12,
                    color: isTaboo ? const Color(0xFFFF6B60) : const Color(0xFF999999),
                    decoration: isTaboo ? TextDecoration.lineThrough : null,
                    decorationColor: const Color(0xFFFF3B30),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TagBadge extends StatelessWidget {
  final String label;
  final bool isCustom;
  final bool isWarning;

  const _TagBadge(this.label, {this.isCustom = false, this.isWarning = false});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    if (isWarning) {
      bg = const Color(0xFF3D1A1A);
      fg = const Color(0xFFFF6B60);
    } else if (isCustom) {
      bg = const Color(0xFF1A2D1A);
      fg = const Color(0xFF4CD964);
    } else {
      bg = const Color(0xFF2A2A1A);
      fg = const Color(0xFFFFCC00);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w500)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFFFFCC00),
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }
}
