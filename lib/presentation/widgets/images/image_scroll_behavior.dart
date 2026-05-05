import 'package:flutter/material.dart';

class ImageScrollBehavior extends StatefulWidget {
  final Widget child;

  const ImageScrollBehavior({super.key, required this.child});

  @override
  State<ImageScrollBehavior> createState() => _ImageScrollBehaviorState();
}

class _ImageScrollBehaviorState extends State<ImageScrollBehavior> {
  ScrollPosition? _position;
  double _parallaxOffset = 0.0;
  double _zoomScale = 1.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Remove old listener if any
    _position?.removeListener(_onScroll);
    
    // Get the current scrollable
    final scrollable = Scrollable.maybeOf(context);
    if (scrollable != null) {
      _position = scrollable.position;
      _position?.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;

    // Expert Judgement: Instead of complex velocity tracking which causes GC churn,
    // we use the position of this specific widget relative to the viewport.
    final renderObject = context.findRenderObject();
    if (renderObject == null || !renderObject.attached) return;

    final RenderBox box = renderObject as RenderBox;
    final ScrollableState? scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) return;

    // Get position relative to viewport
    final offsetToScrollable = box.localToGlobal(Offset.zero, ancestor: scrollable.context.findRenderObject());
    final viewportHeight = scrollable.position.viewportDimension;
    
    // Calculate how far we are from the center of the viewport (-1.0 to 1.0)
    final distanceFromCenter = (offsetToScrollable.dy + (box.size.height / 2)) - (viewportHeight / 2);
    final normalizedDistance = (distanceFromCenter / (viewportHeight / 2)).clamp(-1.0, 1.0);

    // Expert Judgement: Parallax factor of 0.3 (30%) feels premium and grounded. 
    // 50% often feels too disconnected from the card frame.
    final newParallaxOffset = -normalizedDistance * (box.size.height * 0.3);
    
    // Zoom slightly when near the center of the screen
    // 1.0x at edges, up to 1.05x at center
    final zoomFactor = 1.0 + (0.05 * (1.0 - normalizedDistance.abs()));

    if ((_parallaxOffset - newParallaxOffset).abs() > 0.5 || (_zoomScale - zoomFactor).abs() > 0.005) {
      setState(() {
        _parallaxOffset = newParallaxOffset;
        _zoomScale = zoomFactor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If animations are disabled for accessibility, return child directly
    if (MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }

    return RepaintBoundary(
      child: ClipRect(
        child: Transform(
          transform: Matrix4.identity()
            ..translate(0.0, _parallaxOffset, 0.0)
            ..scale(_zoomScale, _zoomScale),
          alignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
  }
}
