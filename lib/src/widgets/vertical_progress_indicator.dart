
import 'package:flutter/material.dart';

const double _kVerticalProgressIndicatorWidth = 8.0;
const int _kIndeterminateLinearDuration = 1800;

class VerticalProgressIndicator extends ProgressIndicator {
  /// Creates a linear progress indicator.
  ///
  /// {@macro flutter.material.progressIndicator.parameters}
  const VerticalProgressIndicator({
    Key key,
    double value,
    Color backgroundColor,
    Animation<Color> valueColor,
    String semanticsLabel,
    String semanticsValue,
  }) : super(
          key: key,
          value: value,
          backgroundColor: backgroundColor,
          valueColor: valueColor,
          semanticsLabel: semanticsLabel,
          semanticsValue: semanticsValue,
        );

  @override
  _VerticslProgressIndicatorState createState() =>
      _VerticslProgressIndicatorState();
}

class _VerticslProgressIndicatorState extends State<VerticalProgressIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: _kIndeterminateLinearDuration),
      vsync: this,
    );
    if (widget.value == null) _controller.repeat();
  }

  @override
  void didUpdateWidget(VerticalProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_controller.isAnimating)
      _controller.repeat();
    else if (widget.value != null && _controller.isAnimating)
      _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildIndicator(BuildContext context, double animationValue,
      TextDirection textDirection) {
    return Semantics(
      label: widget.semanticsLabel,
      value: widget.semanticsValue,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: _kVerticalProgressIndicatorWidth,
          minHeight: double.infinity,
        ),
        child: CustomPaint(
          painter: _VerticalProgressIndicatorPainter(
            backgroundColor:
                widget.backgroundColor ?? Theme.of(context).backgroundColor,
            valueColor: Colors.amber,
            value: widget.value, // may be null
            animationValue:
                animationValue, // ignored if widget.value is not null
            textDirection: textDirection,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);

    if (widget.value != null)
      return _buildIndicator(context, _controller.value, textDirection);

    return AnimatedBuilder(
      animation: _controller.view,
      builder: (BuildContext context, Widget child) {
        return _buildIndicator(context, _controller.value, textDirection);
      },
    );
  }
}

class _VerticalProgressIndicatorPainter extends CustomPainter {
  const _VerticalProgressIndicatorPainter({
    this.backgroundColor,
    this.valueColor,
    this.value,
    this.animationValue,
    @required this.textDirection,
  }) : assert(textDirection != null);

  final Color backgroundColor;
  final Color valueColor;
  final double value;
  final double animationValue;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, paint);

    paint.color = valueColor;

    void drawBar(double x, double dy) {
      if (dy <= 0.0) return;
      canvas.drawRect(Offset(0.0, size.height) & Size(size.width, -dy), paint);
    }

    if (value != null) {
      print(value);
      drawBar(0.0, value.clamp(0.0, 1.0) * size.height as double);
      drawBar(0.0, size.height * .01);
    }
  }

  @override
  bool shouldRepaint(_VerticalProgressIndicatorPainter oldPainter) {
    return oldPainter.backgroundColor != backgroundColor ||
        oldPainter.valueColor != valueColor ||
        oldPainter.value != value ||
        oldPainter.animationValue != animationValue ||
        oldPainter.textDirection != textDirection;
  }
}
