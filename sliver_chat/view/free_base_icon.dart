import 'dart:math';
import 'dart:ui' as ui;
import 'package:common_base/common_base.dart';
import 'package:flutter/material.dart';
import '../chatcell/room_chat_cell_vo.dart';
import 'image_load_manager.dart';

class FreeBaseIcon {


  //背景图片
  ui.Image? _bgImage;

  //是否绘制测试的背景区域颜色， 用于调整当前字号，正式版本删除绘制测试区域的方法，
  bool _hideRectBg = true;

  final VoidCallback? onTap;

  final Rect drawRect;

  FreeBaseIcon({
    required String url,
    required this.drawRect,
    this.onTap,
  }) {
    ImageLoadManager.getImageLocalorNetFun(url, (ui.Image value) {
      _bgImage = value;
    });

    initData();
  }

  void initData() {}


  bool hitTest(RoomChatCellVo vo, Offset clikPos) {
    //写法有点罗说，需要在创建的时候就算出位置

    return true;
  }



  //绘制的区域，这是在列表表中对应该布局坐标
  Rect? drawToRect;

  //将内容绘制到空格范围内容
  void draw(Canvas canvas, RoomChatCellVo vo, double ty) {
    if (_bgImage != null) {

      double ttx = vo.ctxPodding.left ;
      double tty = vo.rect!.top -
          ty +
          vo.ctxPodding.top  ;

      drawToRect = Rect.fromLTWH(
        ttx + drawRect.left,
        tty + drawRect.top + vo.textLink!.multipleLinesH / 2.0,
        drawRect.width,
        drawRect.height,
      );
      //显示背景区域
      // _hideRectBg = false;
      if (!_hideRectBg) {
        canvas.drawRect(
          drawToRect!, // Draw only the visible intersection
          Paint()..color = Colors.green,
        );
      }
      //绘制底图
      int imgW = _bgImage!.width;
      int imgH = _bgImage!.height;
      double scale = max(imgW / drawRect.width, imgH / drawRect.height);
      Rect srcRect = Rect.fromLTWH(0.0, 0.0, imgW * 1.0, imgH * 1.0);
      Rect dstRect = Rect.fromLTWH(
        drawToRect!.left + (drawToRect!.width - imgW / scale) / 2.0,
        drawToRect!.top + (drawToRect!.height - imgH / scale) / 2.0,
        imgW / scale,
        imgH / scale,
      );
      canvas.drawImageRect(_bgImage!, srcRect, dstRect, Paint());
      //绘制文本
    }
  }
}
