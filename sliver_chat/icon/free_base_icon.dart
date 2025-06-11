
import 'package:data_center/utils/sliver_chat/icon/chat_base_icon.dart';
import 'package:flutter/material.dart';
import '../chatcell/room_chat_cell_vo.dart';


class FreeBaseIcon extends ChatBaseIcon {
  //绘制的区域，这是在列表表中对应该布局坐标
  final Rect drawRect;
  FreeBaseIcon({required super.url, required this.drawRect, required super.roomChatCellVo});

  //将内容绘制到空格范围内容
  void draw(Canvas canvas, RoomChatCellVo vo, double ty) {
    if (bgImage != null) {
      double ttx = vo.ctxPodding.left;
      double tty = vo.rect.top - ty + vo.ctxPodding.top;
      drawToRect = Rect.fromLTWH(
        ttx + drawRect.left,
        tty + drawRect.top + vo.textLink!.multipleLinesH / 2.0,
        drawRect.width,
        drawRect.height,
      );
    }
    super.draw(canvas, vo, ty);
  }
}
