import 'hotpot_item.dart';

class SelectedHotpotItem {
  final HotpotItem item;
  final int quantity;
  final DateTime? startedAt;

  const SelectedHotpotItem({
    required this.item,
    this.quantity = 1,
    this.startedAt,
  });

  HotpotState get state {
    if (startedAt == null) return HotpotState.idle;
    final elapsed = elapsedSeconds;
    if (elapsed < item.targetSeconds) return HotpotState.counting;
    if (elapsed < item.targetSeconds + 60) return HotpotState.ready;
    return HotpotState.overcooked;
  }

  int get elapsedSeconds {
    final started = startedAt;
    if (started == null) return 0;
    final seconds = DateTime.now().difference(started).inSeconds;
    return seconds < 0 ? 0 : seconds;
  }

  int get remainingSeconds {
    if (startedAt == null) return 0;
    final remaining = item.targetSeconds - elapsedSeconds;
    return remaining < 0 ? 0 : remaining;
  }

  int get overtimeSeconds {
    if (startedAt == null) return 0;
    final overtime = elapsedSeconds - item.targetSeconds;
    return overtime < 0 ? 0 : overtime;
  }

  SelectedHotpotItem copyWith({
    HotpotItem? item,
    int? quantity,
    DateTime? startedAt,
    bool clearStartedAt = false,
  }) {
    return SelectedHotpotItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      startedAt: clearStartedAt ? null : startedAt ?? this.startedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item.toJson(),
      'quantity': quantity,
      'startedAt': startedAt?.toIso8601String(),
    };
  }

  factory SelectedHotpotItem.fromJson(Map<String, dynamic> json) {
    return SelectedHotpotItem(
      item: HotpotItem.fromJson(json['item'] as Map<String, dynamic>),
      quantity: json['quantity'] as int? ?? 1,
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.tryParse(json['startedAt'] as String),
    );
  }
}
