import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import '../chatcell/room_chat_cell_vo.dart';
import 'chat_base_icon.dart';


class EndBaseIcon extends ChatBaseIcon {
  //起始位置，后续逐个叠加在文本的开始使用.
  double startLeft = 0.0;
  //图像偏移，默认为0,0,0,0;计算出来的文字空间再扩展
  final Rect boxRect;
  EndBaseIcon({
    required super.url,
    required super.onTap,
    required super.roomChatCellVo,
    required this.boxRect,

  });
  @override
  bool hitTest(RoomChatCellVo vo, ui.Offset clikPos) {
    LineMetrics lineMetrics = vo.textLink!.contentLines![vo.textLink!.contentLines!.length - 1];
    double ty = vo.ctxPodding.top + vo.textLink!.multipleLinesH / 2.0 + lineMetrics.baseline - drawToRect!.height;
    Rect testRect = Rect.fromLTWH(
      drawToRect!.left,
      ty,
      drawToRect!.width,
      drawToRect!.height,
    );
    // print(clikPos);
    // print(testRect);
    if (testRect.contains(clikPos)) {
      onTap!();
    }
    return true;
  }

  @override
  void draw(ui.Canvas canvas, RoomChatCellVo vo, double ty) {
    if (bgImage != null && vo.textLink!.contentLines != null) {
      Rect drawRect = Rect.fromLTWH(
        boxRect.left,
        boxRect.top,
        boxRect.width,
        boxRect.height,
      );
      LineMetrics lineMetrics = vo.textLink!.contentLines![vo.textLink!.contentLines!.length - 1];
      double ttx = vo.ctxPodding.left + lineMetrics.width;
      double tty = vo.rect.top - ty + vo.ctxPodding.top + lineMetrics.baseline - drawRect.height;

      drawToRect = Rect.fromLTWH(
        ttx + drawRect.left + vo.textLink!.fontBaseLeft,
        tty + drawRect.top + vo.textLink!.multipleLinesH / 2.0,
        drawRect.width,
        drawRect.height,
      );

    }
    super.draw(canvas, vo, ty);
  }
}
