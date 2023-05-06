// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'button_style.dart';
import 'colors.dart';
import 'constants.dart';
import 'ink_well.dart';
import 'material.dart';
import 'material_state.dart';
import 'theme_data.dart';

/// The base [StatefulWidget] class for buttons whose style is defined by a [ButtonStyle] object.
///
/// Concrete subclasses must override [defaultStyleOf] and [themeStyleOf].
///
/// See also:
///  * [ElevatedButton], a filled button whose material elevates when pressed.
///  * [FilledButton], a filled button that doesn't elevate when pressed.
///  * [FilledButton.tonal], a filled button variant that uses a secondary fill color.
///  * [OutlinedButton], a button with an outlined border and no fill color.
///  * [TextButton], a button with no outline or fill color.
///  * <https://m3.material.io/components/buttons/overview>, an overview of each of
///    the Material Design button types and how they should be used in designs.
abstract class ButtonStyleButton extends StatefulWidget {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const ButtonStyleButton({
    super.key,
    required this.onPressed,
    required this.onLongPress,
    required this.onHover,
    required this.onFocusChange,
    required this.style,
    required this.focusNode,
    required this.autofocus,
    required this.clipBehavior,
    this.statesController,
    required this.child,
  }) : assert(autofocus != null),
       assert(clipBehavior != null);

  /// Called when the button is tapped or otherwise activated.
  ///
  /// If this callback and [onLongPress] are null, then the button will be disabled.
  ///
  /// See also:
  ///
  ///  * [enabled], which is true if the button is enabled.
  final VoidCallback? onPressed;

  /// Called when the button is long-pressed.
  ///
  /// If this callback and [onPressed] are null, then the button will be disabled.
  ///
  /// See also:
  ///
  ///  * [enabled], which is true if the button is enabled.
  final VoidCallback? onLongPress;

  /// Called when a pointer enters or exits the button response area.
  ///
  /// The value passed to the callback is true if a pointer has entered this
  /// part of the material and false if a pointer has exited this part of the
  /// material.
  final ValueChanged<bool>? onHover;

  /// Handler called when the focus changes.
  ///
  /// Called with true if this widget's node gains focus, and false if it loses
  /// focus.
  final ValueChanged<bool>? onFocusChange;

  /// Customizes this button's appearance.
  ///
  /// Non-null properties of this style override the corresponding
  /// properties in [themeStyleOf] and [defaultStyleOf]. [MaterialStateProperty]s
  /// that resolve to non-null values will similarly override the corresponding
  /// [MaterialStateProperty]s in [themeStyleOf] and [defaultStyleOf].
  ///
  /// Null by default.
  final ButtonStyle? style;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.none], and must not be null.
  final Clip clipBehavior;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// {@macro flutter.material.inkwell.statesController}
  final MaterialStatesController? statesController;

  /// Typically the button's label.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  /// Returns a non-null [ButtonStyle] that's based primarily on the [Theme]'s
  /// [ThemeData.textTheme] and [ThemeData.colorScheme].
  ///
  /// The returned style can be overridden by the [style] parameter and
  /// by the style returned by [themeStyleOf]. For example the default
  /// style of the [TextButton] subclass can be overridden with its
  /// [TextButton.style] constructor parameter, or with a
  /// [TextButtonTheme].
  ///
  /// Concrete button subclasses should return a ButtonStyle that
  /// has no null properties, and where all of the [MaterialStateProperty]
  /// properties resolve to non-null values.
  ///
  /// See also:
  ///
  ///  * [themeStyleOf], Returns the ButtonStyle of this button's component theme.
  @protected
  ButtonStyle defaultStyleOf(BuildContext context);

  /// Returns the ButtonStyle that belongs to the button's component theme.
  ///
  /// The returned style can be overridden by the [style] parameter.
  ///
  /// Concrete button subclasses should return the ButtonStyle for the
  /// nearest subclass-specific inherited theme, and if no such theme
  /// exists, then the same value from the overall [Theme].
  ///
  /// See also:
  ///
  ///  * [defaultStyleOf], Returns the default [ButtonStyle] for this button.
  @protected
  ButtonStyle? themeStyleOf(BuildContext context);

  /// Whether the button is enabled or disabled.
  ///
  /// Buttons are disabled by default. To enable a button, set its [onPressed]
  /// or [onLongPress] properties to a non-null value.
  bool get enabled => onPressed != null || onLongPress != null;

  @override
  State<ButtonStyleButton> createState() => _ButtonStyleState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('enabled', value: enabled, ifFalse: 'disabled'));
    properties.add(DiagnosticsProperty<ButtonStyle>('style', style, defaultValue: null));
    properties.add(DiagnosticsProperty<FocusNode>('focusNode', focusNode, defaultValue: null));
  }

  /// Returns null if [value] is null, otherwise `MaterialStatePropertyAll<T>(value)`.
  ///
  /// A convenience method for subclasses.
  static MaterialStateProperty<T>? allOrNull<T>(T? value) => value == null ? null : MaterialStatePropertyAll<T>(value);

  /// Returns an interpolated value based on the [textScaleFactor] parameter:
  ///
  ///  * 0 - 1 [geometry1x]
  ///  * 1 - 2 lerp([geometry1x], [geometry2x], [textScaleFactor] - 1)
  ///  * 2 - 3 lerp([geometry2x], [geometry3x], [textScaleFactor] - 2)
  ///  * otherwise [geometry3x]
  ///
  /// A convenience method for subclasses.
  static EdgeInsetsGeometry scaledPadding(
    EdgeInsetsGeometry geometry1x,
    EdgeInsetsGeometry geometry2x,
    EdgeInsetsGeometry geometry3x,
    double textScaleFactor,
  ) {
    assert(geometry1x != null);
    assert(geometry2x != null);
    assert(geometry3x != null);
    assert(textScaleFactor != null);

    if (textScaleFactor <= 1) {
      return geometry1x;
    } else if (textScaleFactor >= 3) {
      return geometry3x;
    } else if (textScaleFactor <= 2) {
      return EdgeInsetsGeometry.lerp(geometry1x, geometry2x, textScaleFactor - 1)!;
    }
    return EdgeInsetsGeometry.lerp(geometry2x, geometry3x, textScaleFactor - 2)!;
  }
}

/// The base [State] class for buttons whose style is defined by a [ButtonStyle] object.
///
/// See also:
///
///  * [ButtonStyleButton], the [StatefulWidget] subclass for which this class is the [State].
///  * [ElevatedButton], a filled button whose material elevates when pressed.
///  * [FilledButton], a filled ButtonStyleButton that doesn't elevate when pressed.
///  * [OutlinedButton], similar to [TextButton], but with an outline.
///  * [TextButton], a simple button without a shadow.
class _ButtonStyleState extends State<ButtonStyleButton> with TickerProviderStateMixin {
  AnimationController? controller;
  double? elevation;
  Color? backgroundColor;
  MaterialStatesController? internalStatesController;

  void handleStatesControllerChange() {
    // Force a rebuild to resolve MaterialStateProperty properties
    setState(() { });
  }

  MaterialStatesController get statesController => widget.statesController ?? internalStatesController!;

  void initStatesController() {
    if (widget.statesController == null) {
      internalStatesController = MaterialStatesController();
    }
    statesController.update(MaterialState.disabled, !widget.enabled);
    statesController.addListener(handleStatesControllerChange);
  }

  @override
  void initState() {
    super.initState();
    initStatesController();
  }

  @override
  void didUpdateWidget(ButtonStyleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.statesController != oldWidget.statesController) {
      oldWidget.statesController?.removeListener(handleStatesControllerChange);
      if (widget.statesController != null) {
        internalStatesController?.dispose();
        internalStatesController = null;
      }
      initStatesController();
    }
    if (widget.enabled != oldWidget.enabled) {
      statesController.update(MaterialState.disabled, !widget.enabled);
      if (!widget.enabled) {
        // The button may have been disabled while a press gesture is currently underway.
        statesController.update(MaterialState.pressed, false);
      }
    }
  }

  @override
  void dispose() {
    statesController.removeListener(handleStatesControllerChange);
    internalStatesController?.dispose();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle? widgetStyle = widget.style;
    final ButtonStyle? themeStyle = widget.themeStyleOf(context);
    final ButtonStyle defaultStyle = widget.defaultStyleOf(context);
    assert(defaultStyle != null);

    T? effectiveValue<T>(T? Function(ButtonStyle? style) getProperty) {
      final T? widgetValue  = getProperty(widgetStyle);
      final T? themeValue   = getProperty(themeStyle);
      final T? defaultValue = getProperty(defaultStyle);
      return widgetValue ?? themeValue ?? defaultValue;
    }

    T? resolve<T>(MaterialStateProperty<T>? Function(ButtonStyle? style) getProperty) {
      return effectiveValue(
        (ButtonStyle? style) {
          return getProperty(style)?.resolve(statesController.value);
        },
      );
    }

    final double? resolvedElevation = resolve<double?>((ButtonStyle? style) => style?.elevation);
    final TextStyle? resolvedTextStyle = resolve<TextStyle?>((ButtonStyle? style) => style?.textStyle);
    Color? resolvedBackgroundColor = resolve<Color?>((ButtonStyle? style) => style?.backgroundColor);
    final Color? resolvedForegroundColor = resolve<Color?>((ButtonStyle? style) => style?.foregroundColor);
    final Color? resolvedShadowColor = resolve<Color?>((ButtonStyle? style) => style?.shadowColor);
    final Color? resolvedSurfaceTintColor = resolve<Color?>((ButtonStyle? style) => style?.surfaceTintColor);
    final EdgeInsetsGeometry? resolvedPadding = resolve<EdgeInsetsGeometry?>((ButtonStyle? style) => style?.padding);
    final Size? resolvedMinimumSize = resolve<Size?>((ButtonStyle? style) => style?.minimumSize);
    final Size? resolvedFixedSize = resolve<Size?>((ButtonStyle? style) => style?.fixedSize);
    final Size? resolvedMaximumSize = resolve<Size?>((ButtonStyle? style) => style?.maximumSize);
    final Color? resolvedIconColor = resolve<Color?>((ButtonStyle? style) => style?.iconColor);
    final double? resolvedIconSize = resolve<double?>((ButtonStyle? style) => style?.iconSize);
    final BorderSide? resolvedSide = resolve<BorderSide?>((ButtonStyle? style) => style?.side);
    final OutlinedBorder? resolvedShape = resolve<OutlinedBorder?>((ButtonStyle? style) => style?.shape);

    final MaterialStateMouseCursor mouseCursor = _MouseCursor(
      (Set<MaterialState> states) => effectiveValue((ButtonStyle? style) => style?.mouseCursor?.resolve(states)),
    );

    final MaterialStateProperty<Color?> overlayColor = MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) => effectiveValue((ButtonStyle? style) => style?.overlayColor?.resolve(states)),
    );

    final VisualDensity? resolvedVisualDensity = effectiveValue((ButtonStyle? style) => style?.visualDensity);
    final MaterialTapTargetSize? resolvedTapTargetSize = effectiveValue((ButtonStyle? style) => style?.tapTargetSize);
    final Duration? resolvedAnimationDuration = effectiveValue((ButtonStyle? style) => style?.animationDuration);
    final bool? resolvedEnableFeedback = effectiveValue((ButtonStyle? style) => style?.enableFeedback);
    final AlignmentGeometry? resolvedAlignment = effectiveValue((ButtonStyle? style) => style?.alignment);
    final Offset densityAdjustment = resolvedVisualDensity!.baseSizeAdjustment;
    final InteractiveInkFeatureFactory? resolvedSplashFactory = effectiveValue((ButtonStyle? style) => style?.splashFactory);

    BoxConstraints effectiveConstraints = resolvedVisualDensity.effectiveConstraints(
      BoxConstraints(
        minWidth: resolvedMinimumSize!.width,
        minHeight: resolvedMinimumSize.height,
        maxWidth: resolvedMaximumSize!.width,
        maxHeight: resolvedMaximumSize.height,
      ),
    );
    if (resolvedFixedSize != null) {
      final Size size = effectiveConstraints.constrain(resolvedFixedSize);
      if (size.width.isFinite) {
        effectiveConstraints = effectiveConstraints.copyWith(
          minWidth: size.width,
          maxWidth: size.width,
        );
      }
      if (size.height.isFinite) {
        effectiveConstraints = effectiveConstraints.copyWith(
          minHeight: size.height,
          maxHeight: size.height,
        );
      }
    }

    // Per the Material Design team: don't allow the VisualDensity
    // adjustment to reduce the width of the left/right padding. If we
    // did, VisualDensity.compact, the default for desktop/web, would
    // reduce the horizontal padding to zero.
    final double dy = densityAdjustment.dy;
    final double dx = math.max(0, densityAdjustment.dx);
    final EdgeInsetsGeometry padding = resolvedPadding!
      .add(EdgeInsets.fromLTRB(dx, dy, dx, dy))
      .clamp(EdgeInsets.zero, EdgeInsetsGeometry.infinity); // ignore_clamp_double_lint

    // If an opaque button's background is becoming translucent while its
    // elevation is changing, change the elevation first. Material implicitly
    // animates its elevation but not its color. SKIA renders non-zero
    // elevations as a shadow colored fill behind the Material's background.
    if (resolvedAnimationDuration! > Duration.zero
        && elevation != null
        && backgroundColor != null
        && elevation != resolvedElevation
        && backgroundColor!.value != resolvedBackgroundColor!.value
        && backgroundColor!.opacity == 1
        && resolvedBackgroundColor.opacity < 1
        && resolvedElevation == 0) {
      if (controller?.duration != resolvedAnimationDuration) {
        controller?.dispose();
        controller = AnimationController(
          duration: resolvedAnimationDuration,
          vsync: this,
        )
        ..addStatusListener((AnimationStatus status) {
          if (status == AnimationStatus.completed) {
            setState(() { }); // Rebuild with the final background color.
          }
        });
      }
      resolvedBackgroundColor = backgroundColor; // Defer changing the background color.
      controller!.value = 0;
      controller!.forward();
    }
    elevation = resolvedElevation;
    backgroundColor = resolvedBackgroundColor;

    final Widget result = ConstrainedBox(
      constraints: effectiveConstraints,
      child: Material(
        elevation: resolvedElevation!,
        textStyle: resolvedTextStyle?.copyWith(color: resolvedForegroundColor),
        shape: resolvedShape!.copyWith(side: resolvedSide),
        color: resolvedBackgroundColor,
        shadowColor: resolvedShadowColor,
        surfaceTintColor: resolvedSurfaceTintColor,
        type: resolvedBackgroundColor == null ? MaterialType.transparency : MaterialType.button,
        animationDuration: resolvedAnimationDuration,
        clipBehavior: widget.clipBehavior,
        child: InkWell(
          onTap: widget.onPressed,
          onLongPress: widget.onLongPress,
          onHover: widget.onHover,
          mouseCursor: mouseCursor,
          enableFeedback: resolvedEnableFeedback,
          focusNode: widget.focusNode,
          canRequestFocus: widget.enabled,
          onFocusChange: widget.onFocusChange,
          autofocus: widget.autofocus,
          splashFactory: resolvedSplashFactory,
          overlayColor: overlayColor,
          highlightColor: Colors.transparent,
          customBorder: resolvedShape.copyWith(side: resolvedSide),
          statesController: statesController,
          child: IconTheme.merge(
            data: IconThemeData(color: resolvedIconColor ?? resolvedForegroundColor, size: resolvedIconSize),
            child: Padding(
              padding: padding,
              child: Align(
                alignment: resolvedAlignment!,
                widthFactor: 1.0,
                heightFactor: 1.0,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );

    final Size minSize;
    switch (resolvedTapTargetSize!) {
      case MaterialTapTargetSize.padded:
        minSize = Size(
          kMinInteractiveDimension + densityAdjustment.dx,
          kMinInteractiveDimension + densityAdjustment.dy,
        );
        assert(minSize.width >= 0.0);
        assert(minSize.height >= 0.0);
        break;
      case MaterialTapTargetSize.shrinkWrap:
        minSize = Size.zero;
        break;
    }

    return Semantics(
      container: true,
      button: true,
      enabled: widget.enabled,
      child: _InputPadding(
        minSize: minSize,
        child: result,
      ),
    );
  }
}

class _MouseCursor extends MaterialStateMouseCursor {
  const _MouseCursor(this.resolveCallback);

  final MaterialPropertyResolver<MouseCursor?> resolveCallback;

  @override
  MouseCursor resolve(Set<MaterialState> states) => resolveCallback(states)!;

  @override
  String get debugDescription => 'ButtonStyleButton_MouseCursor';
}

/// A widget to pad the area around a [ButtonStyleButton]'s inner [Material].
///
/// Redirect taps that occur in the padded area around the child to the center
/// of the child. This increases the size of the button and the button's
/// "tap target", but not its material or its ink splashes.
class _InputPadding extends SingleChildRenderObjectWidget {
  const _InputPadding({
    super.child,
    required this.minSize,
  });

  final Size minSize;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderInputPadding(minSize);
  }

  @override
  void updateRenderObject(BuildContext context, covariant _RenderInputPadding renderObject) {
    renderObject.minSize = minSize;
  }
}

class _RenderInputPadding extends RenderShiftedBox {
  _RenderInputPadding(this._minSize, [RenderBox? child]) : super(child);

  Size get minSize => _minSize;
  Size _minSize;
  set minSize(Size value) {
    if (_minSize == value) {
      return;
    }
    _minSize = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    if (child != null) {
      return math.max(child!.getMinIntrinsicWidth(height), minSize.width);
    }
    return 0.0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (child != null) {
      return math.max(child!.getMinIntrinsicHeight(width), minSize.height);
    }
    return 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (child != null) {
      return math.max(child!.getMaxIntrinsicWidth(height), minSize.width);
    }
    return 0.0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (child != null) {
      return math.max(child!.getMaxIntrinsicHeight(width), minSize.height);
    }
    return 0.0;
  }

  Size _computeSize({required BoxConstraints constraints, required ChildLayouter layoutChild}) {
    if (child != null) {
      final Size childSize = layoutChild(child!, constraints);
      final double height = math.max(childSize.width, minSize.width);
      final double width = math.max(childSize.height, minSize.height);
      return constraints.constrain(Size(height, width));
    }
    return Size.zero;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _computeSize(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.dryLayoutChild,
    );
  }

  @override
  void performLayout() {
    size = _computeSize(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.layoutChild,
    );
    if (child != null) {
      final BoxParentData childParentData = child!.parentData! as BoxParentData;
      childParentData.offset = Alignment.center.alongOffset(size - child!.size as Offset);
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, { required Offset position }) {
    if (super.hitTest(result, position: position)) {
      return true;
    }
    final Offset center = child!.size.center(Offset.zero);
    return result.addWithRawTransform(
      transform: MatrixUtils.forceToPoint(center),
      position: center,
      hitTest: (BoxHitTestResult result, Offset position) {
        assert(position == center);
        return child!.hitTest(result, position: center);
      },
    );
  }
}
