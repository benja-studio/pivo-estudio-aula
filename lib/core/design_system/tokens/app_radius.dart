import 'package:flutter/material.dart';

/// Corner radius tokens with continuous superellipse helpers.
class AppRadius {
  AppRadius._();

  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 28.0;
  static const double full = 999.0;

  // BorderRadius
  static const BorderRadius borderXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderFull = BorderRadius.all(Radius.circular(full));

  // Top BorderRadius (e.g. for Bottom Sheets)
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(xl),
  );

  /// Continuous superellipse border (Apple squircle approximation)
  static ShapeBorder continuousShape(
    double radius, {
    BorderSide side = BorderSide.none,
  }) {
    // Flutter's ContinuousRectangleBorder achieves smooth curvature when radius is multiplied ~1.8 - 2.0
    return ContinuousRectangleBorder(
      borderRadius: BorderRadius.circular(radius * 2.0),
      side: side,
    );
  }

  static ShapeBorder get shapeXs => continuousShape(xs);
  static ShapeBorder get shapeSm => continuousShape(sm);
  static ShapeBorder get shapeMd => continuousShape(md);
  static ShapeBorder get shapeLg => continuousShape(lg);
  static ShapeBorder get shapeXl => continuousShape(xl);
  static const ShapeBorder shapeFull = StadiumBorder();
}
