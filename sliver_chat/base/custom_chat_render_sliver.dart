import 'dart:math';
import 'package:flutter/rendering.dart';

import '../chatcell/room_chat_cell_vo.dart';

// --- 1. 定义自定义的 RenderSliver ---
class CustomChatRenderSliver extends RenderSliver {
  // 修正: extends
  CustomChatRenderSliver({
    required double totalExtent,
    required int refrishnum,
    required List<RoomChatCellVo> data,
  })  : _data = data,
        _refreshNum = refrishnum,
        _totalExtent = totalExtent;

  //存放所有记录的数组，当删除前排数据，需要重新按顺序重置所有对象的位置，现在是自动删除，逐个添加所以不可以人工修改数组
  final List<RoomChatCellVo> _data;

  int _refreshNum;

  int get refreshNum => _refreshNum;

  //刷新变化装太值，布局已计算好，但图片或其它数据还在准备中，当图片和数据准备好后，需要刷新列表的渲染，需要通过markNeedsLayout（）
  set refreshNum(int value) {
    if (_refreshNum == value) return;
    _refreshNum = value;

    markNeedsLayout();
  }

  double _totalExtent;

  double get totalExtent => _totalExtent;

  //列表总高度
  set totalExtent(double value) {
    if (_totalExtent == value) return;
    _totalExtent = value;
    markNeedsLayout();
  }

  //本来应该是大于0这个和支持滑动的0.001互补 这个0.001
  static double num001 = 0.001;

  @override
  void performLayout() {
    double scrollExtent = _totalExtent;

    final double paintExtent = min(
      scrollExtent - constraints.scrollOffset,
      constraints.remainingPaintExtent,
    ).clamp(0.0, constraints.remainingPaintExtent);

    geometry = SliverGeometry(
      scrollExtent: max(
        _totalExtent,
        constraints.remainingPaintExtent + CustomChatRenderSliver.num001,
      ),
      //0.001是始终让组件接受滑动事件，因为当内容小于视口时原本不支持滑动事件
      // paintOrigin: recalculatedPaintOrigin,
      paintExtent: paintExtent,
      layoutExtent: paintExtent,
      maxPaintExtent: paintExtent,
      hitTestExtent: paintExtent,
      hasVisualOverflow: scrollExtent > constraints.remainingPaintExtent ||
          constraints.scrollOffset > 0, // Content can be above or below viewport
    );
  }

  // --- Hit Testing ---
  @override
  bool hitTest(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    //区域判断

    final bool isHit = geometry!.hitTestExtent > 0 &&
        mainAxisPosition >= 0.0 &&
        mainAxisPosition < geometry!.hitTestExtent &&
        crossAxisPosition >= 0.0 &&
        crossAxisPosition < constraints.crossAxisExtent;
    if (isHit) {
      result.add(
        SliverHitTestEntry(
          this,
          mainAxisPosition: mainAxisPosition,
          crossAxisPosition: crossAxisPosition,
        ),
      );
      return true; // We've found a target
    } else {
      return false;
    }
  }

  //记录是否可以判断点击事件，如果有滑动就取消
  double _downPosTy = 0.0;

  @override
  void handleEvent(PointerEvent event, SliverHitTestEntry entry) {
    final double ty = constraints.scrollOffset;
    final double hitMainAxis = entry.mainAxisPosition;
    final double hitCrossAxis = entry.crossAxisPosition;
    if (event is PointerDownEvent) {
      _downPosTy = ty;

    } else if (event is PointerMoveEvent) {
    } else if (event is PointerUpEvent) {
      //有移动将不执行点击事件
      if ((_downPosTy - ty).abs() > 0.0) {
        return;
      }


      // print('ty $ty  hitMainAxis $hitMainAxis  hitCrossAxis$hitCrossAxis ');
      for (RoomChatCellVo vo in _data) {
        double toy = vo.rect.top - ty;
        if (!(hitMainAxis > toy   && hitMainAxis < (toy + vo.rect.height) )) {
          //上下边界超出，跳过
          continue;
        }
        if (hitCrossAxis < vo.ctxPodding.left || hitCrossAxis > vo.width - vo.ctxPodding.right) {
          //左右边界超出，跳过
          continue;
        }
        final Offset clikPos = Offset(
          hitCrossAxis, // corresponds to dx
          hitMainAxis - toy, // corresponds to dy
        );
        //向选中的cell传递点击事件
        vo.hitTest(vo, clikPos);
        return;
      }
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (geometry!.paintExtent <= 0.0) {
      return;
    }

    final double ty = constraints.scrollOffset - offset.dy;
    final double th = constraints.viewportMainAxisExtent;
    for (RoomChatCellVo infoVo in _data) {
      if ((infoVo.rect.top - ty + infoVo.rect.height) < 0 || (infoVo.rect.top - ty) > th) {
        //超出视窗的将跳过不绘制
        continue;
      }
      //绘制传递到对应对象自行绘制
      infoVo.draw(context.canvas, ty);
    }
  }
}
