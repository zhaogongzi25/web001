import 'dart:math';
import 'dart:ui' as ui;
import 'package:common_base/common_base.dart';
import 'package:flutter/material.dart';
import '../chatcell/room_chat_cell_vo.dart';
import 'image_load_manager.dart';

class EndBaseIcon {
  //起始位置，后续逐个叠加在文本的开始使用.
  double startLeft = 0.0;

  //背景图片
  ui.Image? _bgImage;

  //空格文本大小
  Size? fontRect;

  //图像偏移，默认为0,0,0,0;计算出来的文字空间再扩展
  final Rect boxRect;



  //是否绘制测试的背景区域颜色， 用于调整当前字号，正式版本删除绘制测试区域的方法，
  bool _hideRectBg = true;

  final VoidCallback? onTap;

  EndBaseIcon({
    required String url,
    required this.boxRect,
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
 print(clikPos);
    LineMetrics lineMetrics =
        vo.textLink!.lines![vo.textLink!.lines!.length - 1];

    double ty = vo.ctxPodding.top +
        vo.textLink!.multipleLinesH / 2.0 +
        lineMetrics.baseline -
        drawToRect!.height;


    Rect testRect = Rect.fromLTWH(
      drawToRect!.left,
      ty,
      drawToRect!.width,
      drawToRect!.height,
    );

    if(testRect.contains(clikPos)){
      onTap!();
    }
    return true;
  }

  //获取Icon的宽度，
  double getWidth() {
    return fontRect!.width;
  }


  //绘制的区域，这是在列表表中对应该布局坐标
  Rect? drawToRect;

  //将内容绘制到空格范围内容
  void draw(Canvas canvas, RoomChatCellVo vo, double ty) {
    if (_bgImage != null) {
      Rect drawRect = Rect.fromLTWH(
        boxRect.left,
        boxRect.top,
        boxRect.width  ,
        boxRect.height  ,
      );

      LineMetrics lineMetrics =
          vo.textLink!.lines![vo.textLink!.lines!.length - 1];

      double ttx = vo.ctxPodding.left + lineMetrics.width;
      double tty = vo.rect!.top -
          ty +
          vo.ctxPodding.top +
          lineMetrics.baseline -
          drawRect.height;

      drawToRect = Rect.fromLTWH(
        ttx + drawRect.left+vo.textLink!.fontBaseLeft,
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

      Rect srcRect = Rect.fromLTWH(0.0, 0.0, imgW * 1.0, imgH * 1.0);

      canvas.drawImageRect(_bgImage!, srcRect, drawToRect!, Paint());
      //绘制文本
    }
  }
}
