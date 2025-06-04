import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../vo/base_info_vo.dart';
import '../vo/image_load_manager.dart';

class BaseIcon {
  //空格数量
  double startLeft = 0.0;

  //背景图片
  ui.Image? _bgImage;

  //空格文本大小
  Size? fontRect;

  //图像偏移，默认为0,0,0,0;计算出来的文字空间再扩展
  Rect boxRect = Rect.fromLTRB(0, 0, 0, 0);
   //设定图片占用的文字宽度。用的是空格数量，和字号关联，做到图片和文字同比
  final int titleLen;
  //文字的字号
  final TextStyle textStyle;

  bool hideRectBg = true;

  BaseIcon({
    required String url,
    required this.textStyle,
    required this.titleLen,
    required this.boxRect,
  }) {
    ImageLoadManager.getImageLocalorNetFun(url, (ui.Image value) {
      _bgImage = value;
    });
    _mathFontRect();

    initData();
  }

  void initData() {}

  //计算占用空间
  void _mathFontRect() {
    TextStyle baseStyle = textStyle;
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: _getTittleStr(), style: baseStyle),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    fontRect = textPainter.size;
  }

  double getWidth() {
    return fontRect!.width;
  }

  String _getTittleStr() {
    String addStr = '';
    for (int i = 0; i < titleLen; i++) {
      addStr += '\u2003';
    }
    return addStr;
  }

  Rect? toRect;

  //将内容绘制到空格范围内容
  void draw(Canvas canvas, BaseInfovo vo, double ty) {
    if (_bgImage != null) {
      Rect drawRect = Rect.fromLTWH(
        boxRect.left,
        boxRect.top,
        fontRect!.width + boxRect.left + boxRect.right,
        fontRect!.height + boxRect.bottom + boxRect.top,
      );

      double ttx = vo.niceImage!.ctxPodding + startLeft;
      double tty = vo.rect!.top - ty + vo.niceImage!.ctxPodding;
      toRect = Rect.fromLTWH(
        ttx - drawRect.left,
        tty - drawRect.top + vo.textLink!.multipleLinesH / 2.0,
        drawRect.width,
        drawRect.height,
      );

      //显示背景区域
      if (!hideRectBg) {
        canvas.drawRect(
          toRect!, // Draw only the visible intersection
          Paint()..color = Colors.green,
        );
      }

      //绘制底图
      int imgW = _bgImage!.width;
      int imgH = _bgImage!.height;

      double scale = max(imgW / drawRect.width, imgH / drawRect.height);
      Rect srcRect = Rect.fromLTWH(0.0, 0.0, imgW * 1.0, imgH * 1.0);
      Rect dstRect = Rect.fromLTWH(
        toRect!.left + (toRect!.width - imgW / scale) / 2.0,
        toRect!.top + (toRect!.height - imgH / scale) / 2.0,
        imgW / scale,
        imgH / scale,
      );
      canvas.drawImageRect(_bgImage!, srcRect, dstRect, Paint());
      //绘制文本
    }
  }
}
