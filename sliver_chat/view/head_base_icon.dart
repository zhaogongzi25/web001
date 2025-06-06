import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../chatcell/room_chat_cell_vo.dart';
import 'image_load_manager.dart';

class HeadBaseIcon {
  //起始位置，后续逐个叠加在文本的开始使用.
  double startLeft = 0.0;

  //背景图片
  ui.Image? _bgImage;

  //空格文本大小
  Size? fontRect;

  //图像偏移，默认为0,0,0,0;计算出来的文字空间再扩展
  final Rect boxRect;

  //设定图片占用的文字宽度。用的是空格数量，和字号关联，做到图片和文字同比
  final int titleLen;

  //文字的字号
  final TextStyle textStyle;

  //是否绘制测试的背景区域颜色， 用于调整当前字号，正式版本删除绘制测试区域的方法，
  bool _hideRectBg = true;

  HeadBaseIcon({
    required String url,
    required this.textStyle,
    required this.titleLen,
    required this.boxRect,
  }) {
    ImageLoadManager.getImageLocalorNetFun(url, (ui.Image value) {
      _bgImage = value;
    });
    _mathIconUseRect();
    initData();
  }

  void initData() {}

  //计算占用空间矩形，用于绘制对应该图标和文本内容的前部空格
  void _mathIconUseRect() {

    try {
      TextStyle baseStyle = textStyle;
      TextPainter textPainter = TextPainter(
        text: TextSpan(text: _getTittleStr(), style: baseStyle),
        textDirection: TextDirection.ltr,
      )..layout(minWidth: 0, maxWidth: double.infinity);
      fontRect = textPainter.size;
    } catch (e) {
      print('查看数据');
      print('不应该到这');
    } finally {

    }
  }

  //获取Icon的宽度，
  double getWidth() {
    return fontRect!.width;
  }

  //传入TittleLen来标记图标的宽度，将和本字号关联，做到同比缩放
  String _getTittleStr() {
    String addStr = '';
    for (int i = 0; i < titleLen; i++) {
      addStr += '\u2003';
    }
    return addStr;
  }

  //绘制的区域，这是在列表表中对应该布局坐标
  Rect? drawToRect;

  //将内容绘制到空格范围内容
  void draw(Canvas canvas, RoomChatCellVo vo, double ty) {
    if (_bgImage != null) {
      Rect drawRect = Rect.fromLTWH(
        boxRect.left,
        boxRect.top,
        fontRect!.width + boxRect.left + boxRect.right,
        fontRect!.height + boxRect.top + boxRect.bottom,
      );
      double ttx = vo.ctxPodding.left + startLeft;
      double tty = vo.rect!.top - ty + vo.ctxPodding.top;
      drawToRect = Rect.fromLTWH(
        ttx - drawRect.left,
        tty - drawRect.top + vo.textLink!.multipleLinesH / 2.0,
        drawRect.width,
        drawRect.height,
      );
      //显示背景区域
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
