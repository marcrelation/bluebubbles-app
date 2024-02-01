import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final Animatable<Offset> _kRightMiddleTween = Tween<Offset>(
  begin: const Offset(1.0, 0.0),
  end: Offset.zero,
);

/// Provides an iOS-style page transition animation.
///
/// The page slides in from the right and exits in reverse. It also shifts to the left in
/// a parallax motion when another page enters to cover it.
class CustomCupertinoPageTransition extends StatelessWidget {
  /// Creates an iOS-style page transition.
  ///
  ///  * `primaryRouteAnimation` is a linear route animation from 0.0 to 1.0
  ///    when this screen is being pushed.
  ///  * `secondaryRouteAnimation` is a linear route animation from 0.0 to 1.0
  ///    when another screen is being pushed on top of this one.
  ///  * `linearTransition` is whether to perform the transitions linearly.
  ///    Used to precisely track back gesture drags.
  CustomCupertinoPageTransition({
    super.key,
    required Animation<double> primaryRouteAnimation,
    required this.child,
    required bool linearTransition,
  }) : _primaryPositionAnimation =
        (linearTransition
            ? primaryRouteAnimation
            : CurvedAnimation(
          // The curves below have been rigorously derived from plots of native
          // iOS animation frames. Specifically, a video was taken of a page
          // transition animation and the distance in each frame that the page
          // moved was measured. A best fit bezier curve was the fitted to the
          // point set, which is linearToEaseIn. Conversely, easeInToLinear is the
          // reflection over the origin of linearToEaseIn.
          parent: primaryRouteAnimation,
          curve: Curves.linearToEaseOut,
          reverseCurve: Curves.easeInToLinear,
        )
        ).drive(_kRightMiddleTween),
        _primaryShadowAnimation =
        (linearTransition
            ? primaryRouteAnimation
            : CurvedAnimation(
          parent: primaryRouteAnimation,
          curve: Curves.linearToEaseOut,
        )
        ).drive(_CupertinoEdgeShadowDecoration.kTween);

  // When this page is coming in to cover another page.
  final Animation<Offset> _primaryPositionAnimation;
  final Animation<Decoration> _primaryShadowAnimation;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    final TextDirection textDirection = Directionality.of(context);
    return SlideTransition(
      position: _primaryPositionAnimation,
      textDirection: textDirection,
      child: DecoratedBoxTransition(
        decoration: _primaryShadowAnimation,
        child: child,
      ),
    );
  }
}

// A custom [Decoration] used to paint an extra shadow on the start edge of the
// box it's decorating. It's like a [BoxDecoration] with only a gradient except
// it paints on the start side of the box instead of behind the box.
class _CupertinoEdgeShadowDecoration extends Decoration {
  const _CupertinoEdgeShadowDecoration._([this._colors]);

  static DecorationTween kTween = DecorationTween(
    begin: const _CupertinoEdgeShadowDecoration._(), // No decoration initially.
    end: const _CupertinoEdgeShadowDecoration._(
      // Eyeballed gradient used to mimic a drop shadow on the start side only.
      <Color>[
        Color(0x04000000),
        Color(0x00000000),
      ],
    ),
  );

  // Colors used to paint a gradient at the start edge of the box it is
  // decorating.
  //
  // The first color in the list is used at the start of the gradient, which
  // is located at the start edge of the decorated box.
  //
  // If this is null, no shadow is drawn.
  //
  // The list must have at least two colors in it (otherwise it would not be a
  // gradient).
  final List<Color>? _colors;

  // Linearly interpolate between two edge shadow decorations decorations.
  //
  // The `t` argument represents position on the timeline, with 0.0 meaning
  // that the interpolation has not started, returning `a` (or something
  // equivalent to `a`), 1.0 meaning that the interpolation has finished,
  // returning `b` (or something equivalent to `b`), and values in between
  // meaning that the interpolation is at the relevant point on the timeline
  // between `a` and `b`. The interpolation can be extrapolated beyond 0.0 and
  // 1.0, so negative values and values greater than 1.0 are valid (and can
  // easily be generated by curves such as [Curves.elasticInOut]).
  //
  // Values for `t` are usually obtained from an [Animation<double>], such as
  // an [AnimationController].
  //
  // See also:
  //
  //  * [Decoration.lerp].
  static _CupertinoEdgeShadowDecoration? lerp(
      _CupertinoEdgeShadowDecoration? a,
      _CupertinoEdgeShadowDecoration? b,
      double t,
      ) {
    if (a == null && b == null) {
      return null;
    }
    if (a == null) {
      return b!._colors == null ? b : _CupertinoEdgeShadowDecoration._(b._colors!.map<Color>((Color color) => Color.lerp(null, color, t)!).toList());
    }
    if (b == null) {
      return a._colors == null ? a : _CupertinoEdgeShadowDecoration._(a._colors!.map<Color>((Color color) => Color.lerp(null, color, 1.0 - t)!).toList());
    }
    assert(b._colors != null || a._colors != null);
    // If it ever becomes necessary, we could allow decorations with different
    // length' here, similarly to how it is handled in [LinearGradient.lerp].
    assert(b._colors == null || a._colors == null || a._colors!.length == b._colors!.length);
    return _CupertinoEdgeShadowDecoration._(
      <Color>[
        for (int i = 0; i < b._colors!.length; i += 1)
          Color.lerp(a._colors?[i], b._colors?[i], t)!,
      ],
    );
  }

  @override
  _CupertinoEdgeShadowDecoration lerpFrom(Decoration? a, double t) {
    if (a is _CupertinoEdgeShadowDecoration) {
      return _CupertinoEdgeShadowDecoration.lerp(a, this, t)!;
    }
    return _CupertinoEdgeShadowDecoration.lerp(null, this, t)!;
  }

  @override
  _CupertinoEdgeShadowDecoration lerpTo(Decoration? b, double t) {
    if (b is _CupertinoEdgeShadowDecoration) {
      return _CupertinoEdgeShadowDecoration.lerp(this, b, t)!;
    }
    return _CupertinoEdgeShadowDecoration.lerp(this, null, t)!;
  }

  @override
  _CupertinoEdgeShadowPainter createBoxPainter([ VoidCallback? onChanged ]) {
    return _CupertinoEdgeShadowPainter(this, onChanged);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _CupertinoEdgeShadowDecoration
        && other._colors == _colors;
  }

  @override
  int get hashCode => _colors.hashCode;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<Color>('colors', _colors));
  }
}

/// A [BoxPainter] used to draw the page transition shadow using gradients.
class _CupertinoEdgeShadowPainter extends BoxPainter {
  _CupertinoEdgeShadowPainter(
      this._decoration,
      VoidCallback? onChange,
      ) : assert(_decoration._colors == null || _decoration._colors!.length > 1),
        super(onChange);

  final _CupertinoEdgeShadowDecoration _decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final List<Color>? colors = _decoration._colors;
    if (colors == null) {
      return;
    }

    // The following code simulates drawing a [LinearGradient] configured as
    // follows:
    //
    // LinearGradient(
    //   begin: AlignmentDirectional(0.90, 0.0), // Spans 5% of the page.
    //   colors: _decoration._colors,
    // )
    //
    // A performance evaluation on Feb 8, 2021 showed, that drawing the gradient
    // manually as implemented below is more performant than relying on
    // [LinearGradient.createShader] because compiling that shader takes a long
    // time. On an iPhone XR, the implementation below reduced the worst frame
    // time for a cupertino page transition of a newly installed app from ~95ms
    // down to ~30ms, mainly because there's no longer a need to compile a
    // shader for the LinearGradient.
    //
    // The implementation below divides the width of the shadow into multiple
    // bands of equal width, one for each color interval defined by
    // `_decoration._colors`. Band x is filled with a gradient going from
    // `_decoration._colors[x]` to `_decoration._colors[x + 1]` by drawing a
    // bunch of 1px wide rects. The rects change their color by lerping between
    // the two colors that define the interval of the band.

    // Shadow spans 5% of the page.
    final double shadowWidth = 0.05 * configuration.size!.width;
    final double shadowHeight = configuration.size!.height;
    final double bandWidth = shadowWidth / (colors.length - 1);

    final TextDirection? textDirection = configuration.textDirection;
    assert(textDirection != null);
    final double start;
    final double shadowDirection; // -1 for ltr, 1 for rtl.
    switch (textDirection!) {
      case TextDirection.rtl:
        start = offset.dx + configuration.size!.width;
        shadowDirection = 1;
        break;
      case TextDirection.ltr:
        start = offset.dx;
        shadowDirection = -1;
        break;
    }

    int bandColorIndex = 0;
    for (int dx = 0; dx < shadowWidth; dx += 1) {
      if (dx ~/ bandWidth != bandColorIndex) {
        bandColorIndex += 1;
      }
      final Paint paint = Paint()
        ..color = Color.lerp(colors[bandColorIndex], colors[bandColorIndex + 1], (dx % bandWidth) / bandWidth)!;
      final double x = start + shadowDirection * dx;
      canvas.drawRect(Rect.fromLTWH(x - 1.0, offset.dy, 1.0, shadowHeight), paint);
    }
  }
}