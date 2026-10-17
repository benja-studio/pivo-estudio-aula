import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';
import 'package:aula/core/design_system/tokens/app_motion.dart';
import 'package:aula/core/design_system/tokens/app_radius.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';
import 'package:aula/core/utils/haptic_feedback_helper.dart';
import 'package:aula/core/utils/physics_helpers.dart';

/// Draggable, interruptible bottom sheet using physical spring simulation,
/// momentum projection and rubber-banding.
class SpringSheet extends StatefulWidget {
  const SpringSheet({
    super.key,
    required this.child,
    this.snapFractions = const [0.45, 0.88],
    this.initialFractionIndex = 0,
    this.onDismiss,
    this.title,
    this.headerAction,
  });

  final Widget child;
  final List<double> snapFractions;
  final int initialFractionIndex;
  final VoidCallback? onDismiss;
  final String? title;
  final Widget? headerAction;

  /// Convenience show method for modal bottom sheet presentation
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    List<double> snapFractions = const [0.5, 0.9],
    int initialFractionIndex = 0,
    String? title,
    Widget? headerAction,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      enableDrag: false,
      builder: (context) => SpringSheet(
        snapFractions: snapFractions,
        initialFractionIndex: initialFractionIndex,
        title: title,
        headerAction: headerAction,
        onDismiss: () => Navigator.of(context).pop(),
        child: child,
      ),
    );
  }

  @override
  State<SpringSheet> createState() => _SpringSheetState();
}

class _SpringSheetState extends State<SpringSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _currentHeightFraction = 0.5;
  double _overshoot = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentHeightFraction = widget.snapFractions[widget.initialFractionIndex];
    _controller = AnimationController.unbounded(
      vsync: this,
      value: _currentHeightFraction,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(double targetFraction, {double velocity = 0.0}) {
    if (!mounted) return;

    final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations) {
      if (targetFraction <= 0.05) {
        widget.onDismiss?.call();
      } else {
        _controller.value = targetFraction;
      }
      return;
    }

    final simulation = SpringSimulation(
      AppMotion.sheetSpring,
      _controller.value,
      targetFraction,
      velocity,
    );

    _controller.animateWith(simulation).whenComplete(() {
      if (targetFraction <= 0.05 && mounted) {
        widget.onDismiss?.call();
      }
    });
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _isDragging = true;
    _controller.stop();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details, double screenHeight) {
    if (!_isDragging || screenHeight <= 0) return;

    final deltaFraction = -details.primaryDelta! / screenHeight;
    final maxSnap = widget.snapFractions.last;
    final newFraction = _controller.value + deltaFraction;

    if (newFraction > maxSnap) {
      _overshoot += details.primaryDelta!;
      final resistedOvershoot = rubberband(_overshoot, screenHeight);
      _controller.value = maxSnap - (resistedOvershoot / screenHeight);
    } else {
      _overshoot = 0.0;
      _controller.value = newFraction;
    }
  }

  void _onVerticalDragEnd(DragEndDetails details, double screenHeight) {
    _isDragging = false;
    final velocityPxPerSec = -details.velocity.pixelsPerSecond.dy;
    final projectedDeltaPx = project(velocityPxPerSec);
    final projectedFraction = _controller.value + (projectedDeltaPx / screenHeight);

    // If flicked downwards with strong momentum or dragged past dismissal threshold
    if (velocityPxPerSec < -800 || projectedFraction < 0.20) {
      AppHaptics.snapPoint();
      _animateTo(0.0, velocity: velocityPxPerSec / screenHeight);
      return;
    }

    // Find nearest snap point to projected position
    double nearestSnap = widget.snapFractions.first;
    double minDistance = (projectedFraction - nearestSnap).abs();

    for (final snap in widget.snapFractions) {
      final distance = (projectedFraction - snap).abs();
      if (distance < minDistance) {
        minDistance = distance;
        nearestSnap = snap;
      }
    }

    AppHaptics.snapPoint();
    _animateTo(nearestSnap, velocity: velocityPxPerSec / screenHeight);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sheetSurface = isDark
        ? AppColors.darkSurfaceElevated
        : AppColors.lightSurface;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final height = (_controller.value.clamp(0.0, 1.0) * screenHeight);

        return Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onVerticalDragStart: _onVerticalDragStart,
            onVerticalDragUpdate: (details) =>
                _onVerticalDragUpdate(details, screenHeight),
            onVerticalDragEnd: (details) =>
                _onVerticalDragEnd(details, screenHeight),
            child: Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: sheetSurface,
                borderRadius: AppRadius.sheetTop,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                    blurRadius: 28,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Grab handle pill
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 8),
                      width: 36,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkTextTertiary.withValues(alpha: 0.5)
                            : AppColors.lightTextTertiary.withValues(alpha: 0.5),
                        borderRadius: AppRadius.borderFull,
                      ),
                    ),
                  ),

                  // Header with optional title and action
                  if (widget.title != null || widget.headerAction != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          if (widget.title != null)
                            Expanded(
                              child: Text(
                                widget.title!,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          if (widget.headerAction != null) widget.headerAction!,
                        ],
                      ),
                    ),

                  // Sheet Content
                  Expanded(
                    child: SafeArea(
                      top: false,
                      bottom: true,
                      child: widget.child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
