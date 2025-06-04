import 'dart:math';

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:live/page/home/room/sliver_chat/vo/nine_image_draw.dart';

import 'vo/base_info_vo.dart';


// --- 1. 定义自定义的 RenderSliver ---
class CustomChatRenderSliver extends RenderSliver {
  // 修正: extends
  CustomChatRenderSliver({
    required double blockExtent,
    required int refrishnum,
    required List<BaseInfoVo> data,
  }) : _data = data,
       _refreshnum = refrishnum,
       _blockExtent = blockExtent;

  final List<BaseInfoVo> _data;

  int _refreshnum;

  int get refreshNum => _refreshnum;

  set refreshNum(int value) {
    if (_refreshnum == value) return;
    _refreshnum = value;

    markNeedsLayout();
  }

  double _blockExtent;

  double get blockExtent => _blockExtent;

  set blockExtent(double value) {
    if (_blockExtent == value) return;
    _blockExtent = value;
    markNeedsLayout();
  }

  // --- 2. performLayout 方法: 使用 SliverConstraints 计算 SliverGeometry ---
  @override
  void performLayout() {
    double scrollExtent = _blockExtent;

    final double paintExtent = min(
      scrollExtent - constraints.scrollOffset,
      constraints.remainingPaintExtent,
    ).clamp(0.0, constraints.remainingPaintExtent);

    final double layoutExtent =
        paintExtent; // min(paintExtent, constraints.remainingCacheExtent); // Could use cache extent here

    final double recalculatedPaintOrigin = min(0.0, constraints.scrollOffset);

    geometry = SliverGeometry(
      scrollExtent: max(scrollExtent,constraints.remainingPaintExtent+0.001,), //0.001是始终让组件接受滑动事件，因为当内容小于视口时原本不支持滑动事件
      paintOrigin: recalculatedPaintOrigin,
      paintExtent: paintExtent,
      layoutExtent: layoutExtent,
      maxPaintExtent: scrollExtent,
      hitTestExtent: paintExtent,
      hasVisualOverflow:
          scrollExtent > constraints.remainingPaintExtent ||
          constraints.scrollOffset >
              0, // Content can be above or below viewport
    );
  }

  // --- Hit Testing ---
  @override
  bool hitTest(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    // mainAxisPosition: position along the scrolling axis, relative to the start of the sliver's *content*.
    // crossAxisPosition: position along the extent axis, relative to the start of the sliver's painting area.
    // 1. Check if the hit point is within the visible paint area of the sliver.
    // The hitTestExtent is the area checked by the framework before calling this.
    // We need to confirm it's within our laid-out text height relevant to the *current viewport*.
    final bool isHit =
        geometry!.hitTestExtent > 0 &&
        mainAxisPosition >= 0.0 &&
        mainAxisPosition < geometry!.hitTestExtent &&
        crossAxisPosition >= 0.0 &&
        crossAxisPosition < constraints.crossAxisExtent;
    if (isHit) {
      result.add(
        SliverHitTestEntry(
          this,
          // Pass the hit coordinates relative to the sliver's paint origin.
          mainAxisPosition: mainAxisPosition,
          crossAxisPosition: crossAxisPosition,
        ),
      );

      return true; // We've found a target
    }
    return false; // No hit in this sliver
  }


  @override
  void handleEvent(PointerEvent event, SliverHitTestEntry entry) {
    if (event is PointerUpEvent) {
      final double ty = constraints.scrollOffset;
      final double th = constraints.viewportMainAxisExtent;
      final double hitMainAxis = entry.mainAxisPosition;
      final double hitCrossAxis = entry.crossAxisPosition;
      for (BaseInfoVo vo in _data) {
        double voY = vo.rect!.top - ty;
        if (!(hitMainAxis > voY + vo.ctxPodding.top &&
            hitMainAxis <
                (voY + vo.rect!.height) - vo.ctxPodding.bottom)) {
          continue;
        }
        if (hitCrossAxis < vo.ctxPodding.top ||
            hitCrossAxis > vo.rect!.width - vo.ctxPodding.bottom) {
          continue;
        }
        final Offset clikPos = Offset(
          hitCrossAxis, // corresponds to dx
          hitMainAxis - voY, // corresponds to dy
        );
        vo.hitTest(vo, clikPos);
      }
    }
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
  }
  //用于记录绘制数里，用于监测显示，最后可以删除掉

  @override
  void paint(PaintingContext context, Offset offset) {
    if (geometry!.paintExtent <= 0.0) {
      return;
    }
    final double ty = constraints.scrollOffset-offset.dy;
    final double th = constraints.viewportMainAxisExtent;

    for (BaseInfoVo infoVo in _data) {
      if ((infoVo.rect!.top - ty + infoVo.rect!.height) < 0 ||
          (infoVo.rect!.top - ty) > th) {
        continue;
      }


      if (infoVo.niceImage != null) {
        context.canvas.drawRect(
          Rect.fromLTWH(
            infoVo.ctxPodding.left,
            infoVo.rect!.top - ty + infoVo.ctxPodding.top,
            infoVo.textLink!.textPainter!.width,
            infoVo.textLink!.textPainter!.height,
          ), // Draw only the visible intersection
          Paint()..color = Colors.transparent,
        );
      } else {
        context.canvas.drawRect(
          Rect.fromLTWH(
            0,
            infoVo.rect!.top - ty,
            infoVo.rect!.width,
            infoVo.rect!.height,
          ), // Draw only the visible intersection
          Paint()..color = Colors.red,
        );
      }
      infoVo.draw(context.canvas, ty);
    }
  }
}
