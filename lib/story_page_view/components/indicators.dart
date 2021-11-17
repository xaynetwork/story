import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story/story_page_view/story_limit_controller.dart';

import '../story_stack_controller.dart';

class Indicators extends StatefulWidget {
  const Indicators({
    Key? key,
    required this.animationController,
    required this.storyLength,
    required this.isCurrentPage,
    required this.isPaging,
    required this.indicatorStyle,
  }) : super(key: key);
  final int storyLength;
  final IndicatorStyle indicatorStyle;
  final AnimationController? animationController;
  final bool isCurrentPage;
  final bool isPaging;

  @override
  _IndicatorsState createState() => _IndicatorsState();
}

class _IndicatorsState extends State<Indicators> {
  late Animation<double> indicatorAnimation;

  @override
  void initState() {
    super.initState();
    widget.animationController!.forward();
    indicatorAnimation =
        Tween(begin: 0.0, end: 1.0).animate(widget.animationController!)
          ..addListener(() {
            setState(() {});
          });
  }

  @override
  Widget build(BuildContext context) {
    final int currentStoryIndex = context.watch<StoryStackController>().value;
    final bool isStoryEnded = context.watch<StoryLimitController>().value;
    if (!widget.isCurrentPage && widget.isPaging) {
      widget.animationController!.stop();
    }
    if (!widget.isCurrentPage &&
        !widget.isPaging &&
        widget.animationController!.value != 0) {
      widget.animationController!.value = 0;
    }
    if (widget.isCurrentPage &&
        !widget.animationController!.isAnimating &&
        !isStoryEnded) {
      widget.animationController!.forward(from: 0);
    }
    return Padding(
      padding: widget.indicatorStyle.padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          widget.storyLength,
          (index) => _Indicator(
            index: index,
            indicatorStyle: widget.indicatorStyle,
            value: (index == currentStoryIndex)
                ? indicatorAnimation.value
                : (index > currentStoryIndex)
                    ? 0
                    : 1,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    widget.animationController!.dispose();
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({
    Key? key,
    required this.index,
    required this.value,
    required this.indicatorStyle,
  }) : super(key: key);
  final int index;
  final double value;
  final IndicatorStyle indicatorStyle;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(
            left: (index == 0) ? 0 : indicatorStyle.interSpacing),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(indicatorStyle.borderRadius),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: indicatorStyle.backgroundColor,
            valueColor: indicatorStyle.valueColor,
            minHeight: indicatorStyle.minHeight,
          ),
        ),
      ),
    );
  }
}

@immutable
class IndicatorStyle {
  final double minHeight;
  final Color backgroundColor;
  final Animation<Color?> valueColor;
  final double interSpacing;
  final double borderRadius;

  /// padding of [Indicators]
  final EdgeInsetsGeometry padding;

  IndicatorStyle({
    this.minHeight = 4,
    this.interSpacing = 4,
    this.borderRadius = 8,
    Color? backgroundColor,
    this.padding =
        const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
    Animation<Color?>? valueColor,
  })  : backgroundColor = backgroundColor ?? Colors.white.withOpacity(0.4),
        valueColor = valueColor ?? AlwaysStoppedAnimation<Color>(Colors.white);
}
