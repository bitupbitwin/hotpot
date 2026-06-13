import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/default_items.dart';
import '../models/hotpot_item.dart';
import '../models/selected_hotpot_item.dart';
import '../services/custom_item_store.dart';
import '../services/feedback_service.dart';
import '../services/food_recognition_service.dart';
import '../services/selected_item_store.dart';
import '../widgets/hotpot_item_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _bg = Color(0xFF121212);
  static const Color _panel = Color(0xFF1A1A1A);

  final ImagePicker _picker = ImagePicker();
  final FoodRecognitionService _recognitionService = FoodRecognitionService();
  final CustomItemStore _customItemStore = CustomItemStore();
  final SelectedItemStore _selectedItemStore = SelectedItemStore();
  final Map<String, SelectedHotpotItem> _selectedItems = {};
  final List<HotpotItem> _customItems = [];
  Timer? _ticker;

  String _selectedCategory = hotpotCategories.first;
  int _customSeed = 0;

  List<String> get _categories {
    if (_customItems.isEmpty) return hotpotCategories;
    return [...hotpotCategories, '自定义'];
  }

  List<HotpotItem> get _catalog => [...defaultItems, ..._customItems];

  List<HotpotItem> get _visibleItems {
    if (_selectedCategory == '全部') return _catalog;
    if (_selectedCategory == '已点') {
      return _sortedSelectedItems.map((selected) => selected.item).toList();
    }
    if (_selectedCategory == '推荐') {
      return defaultItems.take(10).toList();
    }
    return _catalog
        .where((item) => item.category == _selectedCategory)
        .toList();
  }

  List<SelectedHotpotItem> get _sortedSelectedItems {
    final items = _selectedItems.values.toList();
    items.sort(_compareSelectedItems);
    return items;
  }

  int _compareSelectedItems(SelectedHotpotItem a, SelectedHotpotItem b) {
    final aRank = _selectedSortRank(a);
    final bRank = _selectedSortRank(b);
    final rankCompare = aRank.compareTo(bRank);
    if (rankCompare != 0) return rankCompare;
    return a.item.targetSeconds.compareTo(b.item.targetSeconds);
  }

  int _selectedSortRank(SelectedHotpotItem selected) {
    if (selected.startedAt == null) return selected.item.targetSeconds + 100000;
    switch (selected.state) {
      case HotpotState.overcooked:
        return -100000 - selected.overtimeSeconds;
      case HotpotState.ready:
        return -50000 - selected.overtimeSeconds;
      case HotpotState.counting:
        return selected.remainingSeconds;
      case HotpotState.idle:
        return selected.item.targetSeconds + 100000;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCustomItems();
    _loadSelectedItems();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted &&
          _selectedItems.values.any((item) => item.startedAt != null)) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _loadCustomItems() async {
    final items = await _customItemStore.loadItems();
    if (!mounted) return;
    setState(() {
      _customItems
        ..clear()
        ..addAll(items);
      _customSeed = items.length;
    });
  }

  Future<void> _loadSelectedItems() async {
    final items = await _selectedItemStore.loadItems();
    if (!mounted) return;
    setState(() {
      _selectedItems
        ..clear()
        ..addEntries(
          items.map((selected) => MapEntry(selected.item.id, selected)),
        );
      if (_selectedItems.isNotEmpty) {
        _selectedCategory = '已点';
      }
    });
  }

  void _persistSelectedItems() {
    _selectedItemStore.saveItems(_selectedItems.values.toList());
  }

  void _toggleItem(HotpotItem item) {
    setState(() {
      if (_selectedItems.containsKey(item.id)) {
        _selectedItems.remove(item.id);
      } else {
        _selectedItems[item.id] = SelectedHotpotItem(item: item);
      }
    });
    _persistSelectedItems();
  }

  void _addItems(Iterable<HotpotItem> items) {
    setState(() {
      for (final item in items) {
        final selected = _selectedItems[item.id];
        _selectedItems[item.id] = SelectedHotpotItem(
          item: item,
          quantity: (selected?.quantity ?? 0) + 1,
        );
      }
    });
    _persistSelectedItems();
  }

  void _clearSelectedItems() {
    setState(_selectedItems.clear);
    _persistSelectedItems();
  }

  void _startOrResetTimer(HotpotItem item) {
    final selected = _selectedItems[item.id];
    if (selected == null) return;

    FeedbackService.stop();
    setState(() {
      _selectedItems[item.id] = selected.startedAt == null
          ? selected.copyWith(startedAt: DateTime.now())
          : selected.copyWith(clearStartedAt: true);
    });
    _persistSelectedItems();
  }

  Future<void> _pickAndRecognizeImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (!mounted || image == null) return;

    final hintText = await _askRecognitionHints(image.name);
    if (!mounted || hintText == null) return;

    final userNames = _recognitionService.parseInputNames(hintText);
    final result = await _recognitionService.recognizeImage(
      image: image,
      catalog: _catalog,
      userHints: userNames,
    );
    if (!mounted) return;

    final confirmedItems = await _confirmRecognizedItems(result.matchedItems);
    if (!mounted || confirmedItems == null) return;

    final missingNames = <String>{
      if (confirmedItems.isEmpty && userNames.isEmpty) '未识别食材',
      ...result.unmatchedNames,
    }.toList();

    _addItems(confirmedItems);

    if (missingNames.isNotEmpty) {
      await _showMissingItemsDialog(missingNames);
    } else {
      _showMessage('已加入 ${result.matchedItems.length} 个识别到的食材');
    }
  }

  Future<List<HotpotItem>?> _confirmRecognizedItems(List<HotpotItem> items) {
    final checkedIds = items.map((item) => item.id).toSet();
    return showDialog<List<HotpotItem>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('确认识别结果'),
          content: SizedBox(
            width: double.maxFinite,
            child: items.isEmpty
                ? const Text('没有匹配到已收录食材，可以继续手动补录。')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return CheckboxListTile(
                        value: checkedIds.contains(item.id),
                        onChanged: (checked) {
                          setDialogState(() {
                            if (checked == true) {
                              checkedIds.add(item.id);
                            } else {
                              checkedIds.remove(item.id);
                            }
                          });
                        },
                        title: Text(item.name),
                        subtitle: Text(
                          '${item.category} · 推荐 ${_formatSeconds(item.targetSeconds)}',
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  items.where((item) => checkedIds.contains(item.id)).toList(),
                );
              },
              child: const Text('加入已点'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _askRecognitionHints(String fileName) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认照片里的食材'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '已选择：$fileName',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: '可补充识别到的食材',
                hintText: '例如：毛肚、肥牛、金针菇',
              ),
              minLines: 1,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('开始识别'),
          ),
        ],
      ),
    );
  }

  Future<void> _showMissingItemsDialog(List<String> missingNames) async {
    for (final name in missingNames) {
      if (!mounted) return;
      final customItem = await _askCustomItem(name);
      if (customItem != null) {
        await _saveCustomItem(customItem);
        _addItems([customItem]);
      }
    }
  }

  Future<void> _saveCustomItem(HotpotItem customItem) async {
    _customItems.removeWhere((item) => item.name == customItem.name);
    _customItems.add(customItem);
    await _customItemStore.saveItems(_customItems);
    if (!mounted) return;
    setState(() {
      if (!_categories.contains(_selectedCategory)) {
        _selectedCategory = '已点';
      }
    });
  }

  Future<void> _showCustomItemManager() async {
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('自定义食材'),
          content: SizedBox(
            width: double.maxFinite,
            child: _customItems.isEmpty
                ? const Text('还没有自定义食材。')
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: _customItems.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _customItems[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text(
                          '推荐 ${_formatSeconds(item.targetSeconds)}',
                        ),
                        trailing: IconButton(
                          tooltip: '删除',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            setState(() {
                              _customItems.removeAt(index);
                              _selectedItems.remove(item.id);
                              if (_selectedCategory == '自定义' &&
                                  _customItems.isEmpty) {
                                _selectedCategory = '全部';
                              }
                            });
                            setDialogState(() {});
                            await _customItemStore.saveItems(_customItems);
                            _persistSelectedItems();
                          },
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
            FilledButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await Future<void>.delayed(Duration.zero);
                if (!mounted) return;
                await _addCustomItemManually();
              },
              icon: const Icon(Icons.add),
              label: const Text('新增'),
            ),
          ],
        ),
      ),
    );
  }

  Future<HotpotItem?> _askCustomItem(String initialName) {
    final nameController = TextEditingController(
      text: initialName == '未识别食材' ? '' : initialName,
    );
    final secondsController = TextEditingController(text: '60');

    return showDialog<HotpotItem>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('未收录食材'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: '食材名字',
                hintText: '例如：鸭血',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: secondsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '倒计时秒数',
                hintText: '例如：90',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('跳过'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              final seconds = int.tryParse(secondsController.text.trim());
              if (name.isEmpty || seconds == null || seconds <= 0) return;
              _customSeed++;
              Navigator.pop(
                context,
                HotpotItem(
                  id: 'custom_$_customSeed',
                  name: name,
                  category: '自定义',
                  targetSeconds: seconds,
                  emoji: '',
                ),
              );
            },
            child: const Text('加入已点'),
          ),
        ],
      ),
    );
  }

  Future<void> _addCustomItemManually() async {
    final item = await _askCustomItem('');
    if (item == null) return;
    await _saveCustomItem(item);
    _addItems([item]);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    if (minutes > 0) {
      return '$minutes:${rest.toString().padLeft(2, '0')}';
    }
    return '${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selectedItems.length;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _panel,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '🍲 火锅捞捞',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Row(
          children: [
            _CategoryRail(
              categories: _categories,
              selectedCategory: _selectedCategory,
              selectedCount: selectedCount,
              onChanged: (category) {
                setState(() => _selectedCategory = category);
              },
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _HeaderBar(
                      selectedCount: selectedCount,
                      onPickImage: _pickAndRecognizeImage,
                      onManageCustom: _showCustomItemManager,
                      onClear: selectedCount == 0 ? null : _clearSelectedItems,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                      child: Text(
                        _selectedCategory == '已点' ? '已点菜品' : _selectedCategory,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  if (_selectedCategory == '已点')
                    _SelectedTimerSliver(
                      items: _sortedSelectedItems,
                      onRemove: _toggleItem,
                      onTimerTap: _startOrResetTimer,
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 28),
                      sliver: SliverGrid.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              mainAxisExtent: 48,
                            ),
                        itemCount: _visibleItems.length,
                        itemBuilder: (context, index) {
                          final item = _visibleItems[index];
                          return _MenuItemTile(
                            item: item,
                            selected: _selectedItems.containsKey(item.id),
                            quantity: _selectedItems[item.id]?.quantity ?? 0,
                            onTap: () => _toggleItem(item),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRail extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final int selectedCount;
  final ValueChanged<String> onChanged;

  const _CategoryRail({
    required this.categories,
    required this.selectedCategory,
    required this.selectedCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      color: const Color(0xFF171717),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = category == selectedCategory;
          final label = category == '已点' && selectedCount > 0
              ? '已点\n$selectedCount'
              : category;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onChanged(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFFFCC00)
                      : const Color(0xFF222222),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.black : Colors.white,
                    fontSize: 12,
                    height: 1.15,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onPickImage;
  final VoidCallback onManageCustom;
  final VoidCallback? onClear;

  const _HeaderBar({
    required this.selectedCount,
    required this.onPickImage,
    required this.onManageCustom,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '已选 $selectedCount 道',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton.filledTonal(
            tooltip: '上传照片识别',
            onPressed: onPickImage,
            icon: const Icon(Icons.photo_camera_back_outlined),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: '管理自定义食材',
            onPressed: onManageCustom,
            icon: const Icon(Icons.playlist_add_outlined),
          ),
          IconButton(
            tooltip: '清空已点',
            onPressed: onClear,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
    );
  }
}

class _SelectedTimerSliver extends StatelessWidget {
  final List<SelectedHotpotItem> items;
  final ValueChanged<HotpotItem> onRemove;
  final ValueChanged<HotpotItem> onTimerTap;

  const _SelectedTimerSliver({
    required this.items,
    required this.onRemove,
    required this.onTimerTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
          child: Container(
            height: 96,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF1D1D1D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '从左侧分类选择食材后，这里会显示已点菜品',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 28),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 10,
          childAspectRatio: 0.72,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) => _SelectedTimerCard(
          selected: items[index],
          onRemove: onRemove,
          onTimerTap: onTimerTap,
        ),
      ),
    );
  }
}

class _SelectedTimerCard extends StatelessWidget {
  final SelectedHotpotItem selected;
  final ValueChanged<HotpotItem> onRemove;
  final ValueChanged<HotpotItem> onTimerTap;

  const _SelectedTimerCard({
    required this.selected,
    required this.onRemove,
    required this.onTimerTap,
  });

  @override
  Widget build(BuildContext context) {
    final item = selected.item;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Center(
          child: HotpotItemWidget(
            key: ValueKey(item.id),
            item: item,
            diameter: 92,
            displayState: selected.state,
            remainingSeconds: selected.remainingSeconds,
            overtimeSeconds: selected.overtimeSeconds,
            onTapOverride: () => onTimerTap(item),
            onLongPressOverride: () => onTimerTap(item),
          ),
        ),
        if (selected.quantity > 1)
          Positioned(
            left: 2,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFCC00),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'x${selected.quantity}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        Positioned(
          right: 0,
          top: 0,
          child: IconButton.filled(
            visualDensity: VisualDensity.compact,
            iconSize: 14,
            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
            onPressed: () => onRemove(item),
            icon: const Icon(Icons.close),
          ),
        ),
      ],
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  final HotpotItem item;
  final bool selected;
  final int quantity;
  final VoidCallback onTap;

  const _MenuItemTile({
    required this.item,
    required this.selected,
    required this.quantity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF332A00) : const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  _MenuAvatar(item: item, size: 34),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (quantity > 1)
                          Text(
                            'x$quantity',
                            style: const TextStyle(
                              color: Color(0xFFFFCC00),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Icon(
                selected ? Icons.check_circle : Icons.add_circle_outline,
                color: selected ? const Color(0xFFFFCC00) : Colors.grey[600],
                size: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _MenuAvatar extends StatelessWidget {
  final HotpotItem item;
  final double size;

  const _MenuAvatar({required this.item, this.size = 42});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: const Color(0xFF2A2A2A),
        alignment: Alignment.center,
        child: item.imagePath == null
            ? Text(
                item.emoji.isEmpty ? item.name : item.emoji,
                maxLines: item.emoji.isEmpty ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: item.emoji.isEmpty ? 9 : (size * 0.55),
                  fontWeight: item.emoji.isEmpty
                      ? FontWeight.w800
                      : FontWeight.normal,
                ),
              )
            : Image.asset(
                item.imagePath!,
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
