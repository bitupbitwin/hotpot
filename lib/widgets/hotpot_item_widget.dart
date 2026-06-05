import 'dart:async';
import 'package:flutter/material.dart';
import '../models/hotpot_item.dart';
import '../services/feedback_service.dart';

class HotpotItemWidget extends StatefulWidget {
  final HotpotItem item;
  final double diameter;
  final HotpotState? displayState;
  final int? remainingSeconds;
  final int? overtimeSeconds;
  final VoidCallback? onTapOverride;
  final VoidCallback? onLongPressOverride;

  const HotpotItemWidget({
    super.key,
    required this.item,
    this.diameter = 130,
    this.displayState,
    this.remainingSeconds,
    this.overtimeSeconds,
    this.onTapOverride,
    this.onLongPressOverride,
  });

  @override
  State<HotpotItemWidget> createState() => _HotpotItemWidgetState();
}

class _HotpotItemWidgetState extends State<HotpotItemWidget>
    with SingleTickerProviderStateMixin {
  HotpotState _state = HotpotState.idle;
  int _remaining = 0; // 剩余秒数
  int _overtime = 0; // 超时秒数
  Timer? _timer;
  late final AnimationController _blink;

  static const Color kYellow = Color(0xFFFFCC00);
  static const Color kYellowDim = Color(0xFF7A6300);
  static const Color kGreen = Color(0xFF4CD964);
  static const Color kRed = Color(0xFFFF3B30);

  bool get _isExternallyControlled => widget.displayState != null;

  HotpotState get _displayState => widget.displayState ?? _state;

  int get _displayRemaining => widget.remainingSeconds ?? _remaining;

  int get _displayOvertime => widget.overtimeSeconds ?? _overtime;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void didUpdateWidget(covariant HotpotItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _reset();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _blink.dispose();
    super.dispose();
  }

  // ---------- 状态机 ----------

  void _onTap() {
    if (_isExternallyControlled) {
      widget.onTapOverride?.call();
      return;
    }
    if (_state == HotpotState.idle) {
      _start();
    } else {
      _reset(); // 煮制中/熟透/超时 时再次点击 = 捞出重置
    }
  }

  void _start() {
    FeedbackService.tapFeedback();
    setState(() {
      _state = HotpotState.counting;
      _remaining = widget.item.targetSeconds;
      _overtime = 0;
    });
    _applyAnimationForState();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_state == HotpotState.counting) {
          _remaining--;
          if (_remaining <= 0) {
            _remaining = 0;
            _state = HotpotState.ready;
            _applyAnimationForState();
            FeedbackService.perfectAlarm();
          }
        } else if (_state == HotpotState.ready) {
          _overtime++;
          if (_overtime >= 60) {
            _state = HotpotState.overcooked;
            _applyAnimationForState();
            FeedbackService.urgentAlarm();
          }
        } else if (_state == HotpotState.overcooked) {
          _overtime++;
          if (_overtime % 15 == 0) {
            FeedbackService.urgentAlarm(); // 持续超时，周期性催促
          }
        }
      });
    });
  }

  void _reset() {
    _timer?.cancel();
    FeedbackService.stop();
    setState(() {
      _state = HotpotState.idle;
      _remaining = 0;
      _overtime = 0;
    });
    _applyAnimationForState();
  }

  /// 根据状态设置闪烁频率与循环方式
  void _applyAnimationForState() {
    _blink.stop();
    switch (_state) {
      case HotpotState.idle:
        _blink.value = 0;
        break;
      case HotpotState.counting:
        _blink.duration = const Duration(milliseconds: 500);
        _blink.repeat(reverse: true);
        break;
      case HotpotState.ready:
        _blink.duration = const Duration(milliseconds: 1400);
        _blink.repeat(reverse: true); // 柔和呼吸
        break;
      case HotpotState.overcooked:
        _blink.duration = const Duration(milliseconds: 200);
        _blink.repeat(reverse: true); // 高频疯狂闪烁
        break;
    }
  }

  // ---------- 颜色 / 文本计算 ----------

  Color _ringColor(double t) {
    switch (_displayState) {
      case HotpotState.idle:
        return Colors.black;
      case HotpotState.counting:
        return Color.lerp(kYellowDim, kYellow, t)!;
      case HotpotState.ready:
        return Color.lerp(kGreen.withValues(alpha: 0.55), kGreen, t)!;
      case HotpotState.overcooked:
        return Color.lerp(Colors.transparent, kRed, t)!;
    }
  }

  String _fmt(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0) {
      return '$m:${s.toString().padLeft(2, '0')}';
    }
    return '${s}s';
  }

  /// 中央叠加层文本（null 表示不显示）
  Widget? _centerOverlay() {
    switch (_displayState) {
      case HotpotState.idle:
        return null;
      case HotpotState.counting:
        return _positionedOverlayText(
          topText: _fmt(_displayRemaining),
          topColor: Colors.white,
        );
      case HotpotState.ready:
        return AnimatedBuilder(
          animation: _blink,
          builder: (context, child) => Opacity(
            opacity: 0.9,
            child: _positionedOverlayText(
              topText: _fmt(_displayOvertime),
              bottomText: '可吃!',
              topColor: Colors.white,
              bottomColor: Colors.white,
              topScale: 0.29,
              topOffsetScale: 0.09,
              bottomOffsetScale: 0.02,
            ),
          ),
        );
      case HotpotState.overcooked:
        return _positionedOverlayText(
          topText: _fmt(_displayOvertime),
          bottomText: '太老了!',
          topColor: Colors.white,
          bottomColor: kRed,
          topScale: 0.29,
          topOffsetScale: 0.09,
          bottomOffsetScale: 0.02,
        );
    }
  }

  Widget _positionedOverlayText({
    required String topText,
    required Color topColor,
    String? bottomText,
    Color bottomColor = Colors.white,
    double topScale = 0.3,
    double topOffsetScale = 0.04,
    double bottomOffsetScale = 0,
  }) {
    final d = widget.diameter;
    return SizedBox(
      width: d,
      height: d,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: d * topOffsetScale,
            left: d * 0.08,
            right: d * 0.08,
            child: Text(
              topText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: topColor.withValues(alpha: 0.9),
                fontSize: d * topScale,
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),
          ),
          if (bottomText != null)
            Positioned(
              bottom: d * bottomOffsetScale,
              left: d * 0.08,
              right: d * 0.08,
              child: Text(
                bottomText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: bottomColor.withValues(alpha: 0.9),
                  fontSize: d * 0.22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------- 食材图片 / emoji ----------

  Widget _avatar() {
    final d = widget.diameter;
    if (widget.item.imagePath != null && widget.item.imagePath!.isNotEmpty) {
      return Container(
        width: d,
        height: d,
        color: const Color(0xFF2A2A2A),
        child: Image.asset(
          widget.item.imagePath!,
          width: d,
          height: d,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => _emojiAvatar(d),
        ),
      );
    }
    return _emojiAvatar(d);
  }

  Widget _emojiAvatar(double d) {
    final showName = widget.item.emoji.isEmpty;
    return Container(
      width: d,
      height: d,
      color: const Color(0xFF2A2A2A),
      alignment: Alignment.center,
      padding: EdgeInsets.all(d * 0.12),
      child: Text(
        showName ? widget.item.name : widget.item.emoji,
        maxLines: showName ? 2 : 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: showName ? d * 0.18 : d * 0.42,
          fontWeight: showName ? FontWeight.w800 : FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.diameter;
    final overlay = _centerOverlay();

    return GestureDetector(
      onTap: _onTap,
      onLongPress: _isExternallyControlled
          ? widget.onLongPressOverride ?? widget.onTapOverride
          : _reset,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _blink,
            builder: (context, _) {
              final pulse = _isExternallyControlled
                  ? (_displayState == HotpotState.idle ? 0.0 : 1.0)
                  : _blink.value;
              final color = _ringColor(pulse);
              return Container(
                width: d + 22,
                height: d + 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: _displayState == HotpotState.idle
                      ? null
                      : [
                          BoxShadow(
                            color: color.withValues(alpha: 0.6),
                            blurRadius: 16,
                            spreadRadius: 1,
                          ),
                        ],
                ),
                child: CustomPaint(
                  painter: _RingPainter(color: color, strokeWidth: 9),
                  child: Center(
                    child: ClipOval(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _avatar(),
                          if (overlay != null)
                            Container(
                              width: d,
                              height: d,
                              color: Colors.black.withValues(alpha: 0.24),
                              alignment: Alignment.center,
                              child: overlay,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          Text(
            widget.item.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '推荐 ${_fmt(widget.item.targetSeconds)}',
            style: TextStyle(color: Colors.grey[400], fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _RingPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
