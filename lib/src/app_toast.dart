import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_toast_position.dart';
import 'app_toast_style.dart';
import 'app_toast_type.dart';

class AppToast {
  static OverlayEntry? _current;

  static void show(
    BuildContext context, {
    required String title,
    String? description,
    AppToastType type = AppToastType.info,
    AppToastPosition position = AppToastPosition.top,
    Duration duration = const Duration(seconds: 3),
    bool glass = false,
    AppToastStyle? style,
    IconData? icon,
    Widget? iconWidget,
  }) {
    _current?.remove();
    _current = null;

    final overlay = Overlay.of(context);
    final bool isIOS = Platform.isIOS;

    final (defaultIcon, color) = switch (type) {
      AppToastType.info => (
          isIOS ? CupertinoIcons.info : Icons.info_outline,
          Colors.blue,
        ),
      AppToastType.success => (
          isIOS ? CupertinoIcons.checkmark_circle : Icons.check_circle_outline,
          Colors.green,
        ),
      AppToastType.error => (
          isIOS ? CupertinoIcons.xmark_circle : Icons.cancel_outlined,
          Colors.red,
        ),
      AppToastType.warning => (
          isIOS
              ? CupertinoIcons.exclamationmark_triangle
              : Icons.warning_amber_outlined,
          Colors.orange,
        ),
    };

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _AppToastWidget(
        title: title,
        description: description,
        icon: icon ?? defaultIcon,
        iconWidget: iconWidget,
        color: color,
        duration: duration,
        position: position,
        glass: glass,
        style: style,
        onDismiss: () {
          entry.remove();
          if (_current == entry) _current = null;
        },
      ),
    );

    _current = entry;
    overlay.insert(entry);
  }
}

class _AppToastWidget extends StatefulWidget {
  final String title;
  final String? description;
  final IconData icon;
  final Widget? iconWidget;
  final Color color;
  final Duration duration;
  final AppToastPosition position;
  final bool glass;
  final AppToastStyle? style;
  final VoidCallback onDismiss;

  const _AppToastWidget({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.duration,
    required this.position,
    required this.glass,
    required this.onDismiss,
    this.iconWidget,
    this.style,
  });

  @override
  State<_AppToastWidget> createState() => _AppToastWidgetState();
}

class _AppToastWidgetState extends State<_AppToastWidget>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  double _dragX  = 0;
  bool _dragging = false;
  bool _done     = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacity = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    final begin = widget.position == AppToastPosition.bottom
        ? const Offset(0, 0.3)
        : const Offset(0, -0.3);

    _slide = Tween<Offset>(begin: begin, end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );

    _entryController.forward();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(widget.duration, _dismiss);
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _dismiss() async {
    if (_done || !mounted) return;
    _done = true;
    _cancelTimer();
    await _entryController.reverse();
    if (mounted) widget.onDismiss();
  }

  void _onDragStart(DragStartDetails _) {
    _dragging = true;
    _cancelTimer();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (!_dragging || _done) return;
    setState(() => _dragX += d.delta.dx);
  }

  void _onDragEnd(DragEndDetails d) {
    if (!_dragging || _done) return;
    _dragging = false;

    final sw       = MediaQuery.of(context).size.width;
    final velocity = d.velocity.pixelsPerSecond.dx;

    if (_dragX.abs() > sw * 0.3 || velocity.abs() > 600) {
      _flyOut();
    } else {
      setState(() => _dragX = 0);
      _startTimer();
    }
  }

  Future<void> _flyOut() async {
    if (_done || !mounted) return;
    _done = true;
    _cancelTimer();

    final sw     = MediaQuery.of(context).size.width;
    final target = _dragX > 0 ? sw + 100 : -(sw + 100);

    final flyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    final flyAnim = Tween<double>(begin: _dragX, end: target).animate(
      CurvedAnimation(parent: flyController, curve: Curves.easeIn),
    );

    flyAnim.addListener(() {
      if (mounted) setState(() => _dragX = flyAnim.value);
    });

    await flyController.forward();
    flyController.dispose();

    if (mounted) widget.onDismiss();
  }

  @override
  void dispose() {
    _cancelTimer();
    _entryController.dispose();
    super.dispose();
  }

  double get _radius => widget.style?.borderRadius ?? (widget.glass ? 16 : 12);

  Color get _bgColor {
    if (widget.style?.backgroundColor != null) {
      return widget.style!.backgroundColor!;
    }
    return widget.glass
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.white;
  }

  Color get _borderColor {
    if (widget.style?.borderColor != null) return widget.style!.borderColor!;
    return widget.glass
        ? Colors.white.withValues(alpha: 0.3)
        : Colors.grey.shade200;
  }

  Color get _titleColor =>
      widget.style?.titleColor ??
      (widget.glass ? Colors.white : Colors.black87);

  Color get _descColor =>
      widget.style?.descriptionColor ??
      (widget.glass
          ? Colors.white.withValues(alpha: 0.75)
          : Colors.grey.shade600);

  Color get _closeColor =>
      widget.style?.closeIconColor ??
      (widget.glass
          ? Colors.white.withValues(alpha: 0.6)
          : Colors.grey.shade400);

  Color get _iconBgColor =>
      widget.style?.iconBackgroundColor ??
      widget.color.withValues(alpha: widget.glass ? 0.2 : 0.1);

  double get _iconSize  => widget.style?.iconSize ?? 20;
  EdgeInsets get _padding =>
      widget.style?.padding ??
      const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: _iconBgColor, shape: BoxShape.circle),
      child: widget.iconWidget ??
          Icon(widget.icon, color: widget.color, size: _iconSize),
    );
  }

  Widget _buildContent() {
    return Row(
      children: [
        _buildIcon(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _titleColor,
                ),
              ),
              if (widget.description != null) ...[
                const SizedBox(height: 2),
                Text(
                  widget.description!,
                  style: TextStyle(fontSize: 12, color: _descColor),
                ),
              ],
            ],
          ),
        ),
        GestureDetector(
          onTap: _dismiss,
          child: Icon(Icons.close, size: 16, color: _closeColor),
        ),
      ],
    );
  }

  Widget _buildGlass() {
    final sigma = widget.style?.blurSigma ?? 18;
    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: Container(
          padding: _padding,
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(
              color: _borderColor,
              width: widget.style?.borderWidth ?? 1,
            ),
          ),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildSolid() {
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(
          color: _borderColor,
          width: widget.style?.borderWidth ?? 1,
        ),
        boxShadow: widget.style?.boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: _buildContent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq       = MediaQuery.of(context);
    final isBottom = widget.position == AppToastPosition.bottom;
    final dragFade = (1.0 - (_dragX.abs() / 150).clamp(0.0, 1.0));

    return Positioned(
      top:    isBottom ? null : mq.padding.top + 8,
      bottom: isBottom ? mq.padding.bottom + 24 : null,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _opacity,
        child: SlideTransition(
          position: _slide,
          child: GestureDetector(
            onTap: _dismiss,
            onHorizontalDragStart:  _onDragStart,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd:    _onDragEnd,
            child: Transform.translate(
              offset: Offset(_dragX, 0),
              child: Opacity(
                opacity: dragFade,
                child: Material(
                  color: Colors.transparent,
                  child: widget.glass ? _buildGlass() : _buildSolid(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}