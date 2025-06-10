import 'dart:math';

import 'package:data_center/utils/sliver_chat/view/icon/base_icon.dart';
import 'package:flutter/material.dart';
import '../chatcell/room_chat_cell_vo.dart';
import 'image_load_manager.dart';

class FreeBaseIcon extends BaseIcon {
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
      //显示背景区域
      // canvas.drawRect(
      //   drawToRect!, // Draw only the visible intersection
      //   Paint()..color = Colors.green,
      // );
      //绘制底图
      int imgW = bgImage!.width;
      int imgH = bgImage!.height;
      double scale = max(imgW / drawRect.width, imgH / drawRect.height);
      Rect srcRect = Rect.fromLTWH(0.0, 0.0, imgW * 1.0, imgH * 1.0);
      Rect dstRect = Rect.fromLTWH(
        drawToRect!.left + (drawToRect!.width - imgW / scale) / 2.0,
        drawToRect!.top + (drawToRect!.height - imgH / scale) / 2.0,
        imgW / scale,
        imgH / scale,
      );
      canvas.drawImageRect(bgImage!, srcRect, dstRect, Paint());
      //绘制文本
    }
  }
}
