import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:aula/core/design_system/tokens/app_motion.dart';


/// Instantaneous physical press feedback widget conforming to Apple design principles.
///
/// Reacts on pointer-down (zero artificial delay), scales down to 0.97, cancels gracefully
/// with a 10px hysteresis threshold if dragged outside, and uses a SpringSimulation
/// originating from the exact current value.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.targetScale = AppMotion.pressScale,
    this.hapticOnTap = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final double targetScale;
  final bool hapticOnTap;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Offset? _pointerDownPosition;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(
      vsync: this,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(double target, {double velocity = 0.0}) {
    if (!mounted) return;

    final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations) {
      _controller.value = target;
      return;
    }

    final simulation = SpringSimulation(
      AppMotion.pressSpring,
      _controller.value,
      target,
      velocity,
    );
    _controller.animateWith(simulation);
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!widget.enabled || widget.onTap == null && widget.onLongPress == null) return;
    _pointerDownPosition = event.position;
    _isPressed = true;
    _animateTo(widget.targetScale);
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_isPressed || _pointerDownPosition == null) return;
    final delta = (event.position - _pointerDownPosition!).distance;
    if (delta > AppMotion.pressHysteresisPx) {
      _isPressed = false;
      _animateTo(1.0);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!_isPressed) return;
    _isPressed = false;
    _animateTo(1.0);
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (!_isPressed) return;
    _isPressed = false;
    _animateTo(1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      behavior: HitTestBehavior.opaque,
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        onLongPress: widget.enabled ? widget.onLongPress : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _controller.value,
              alignment: Alignment.center,
              child: child,
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
