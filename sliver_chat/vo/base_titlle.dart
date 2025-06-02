import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
 

import 'base_info_vo.dart';
import 'image_load_manager.dart';

class BaseTittle {
  //空格数量
  double startLeft = 0.0;

  //显示文本
  TextPainter? _labelPainter;
  //背景图片
  ui.Image? _bgImage;

  //空格文本大小
  Size? _fontRect;

  //图像偏移，默认为0,0,0,0;计算出来的文字空间再扩展
  Rect boxRect = Rect.fromLTRB(0, 0, 0, 0);

  final int titleLen;

  final bool _hideRectBg = true;


  BaseTittle({
    required String url,
    required double fontSize,
    required this.titleLen,
    Rect? roundBox,
    String? label,
  }) {
    // userLevel=level??0;
    boxRect = roundBox ?? Rect.fromLTRB(0, 0, 0, 0);
    ImageLoadManager.getImageLocalorNetFun(url, (ui.Image value) {
      _bgImage = value;
    });
    _mathFontRect(fontSize);

    if(label!=null){
      _makeLabel(label,fontSize);
    }




  }

  void _makeLabel(label,double fontSize){

    _labelPainter = TextPainter(
      text: TextSpan(text:label, style: TextStyle(fontSize: fontSize*0.80 ,color: Colors.white)),
      textDirection: TextDirection.rtl,
    )..layout(minWidth: 0, maxWidth: double.infinity);
  }

  //计算占用空间
  void _mathFontRect(double fontSize) {
    TextStyle baseStyle = TextStyle(fontSize: fontSize);
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: _getTittleStr(), style: baseStyle),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    _fontRect = textPainter.size;
  }

  double getWidth() {
    return _fontRect!.width;
  }

  String _getTittleStr() {
    String addStr = '';
    for (int i = 0; i < titleLen; i++) {
      addStr += '\u2003';
    }
    return addStr;
  }

  //将内容绘制到空格范围内容
  void draw(Canvas canvas, BaseInfovo vo, double ty) {

    if (_bgImage != null) {
      Rect drawRect = Rect.fromLTWH(
        boxRect.left,
        boxRect.top,
        _fontRect!.width + boxRect.left + boxRect.right,
        _fontRect!.height + boxRect.bottom + boxRect.top,
      );

      double ttx = vo.niceImage!.ctxPodding + startLeft;
      double tty = vo.rect!.top - ty + vo.niceImage!.ctxPodding;
      Rect toRect = Rect.fromLTWH(
        ttx - drawRect.left,
        tty - drawRect.top,
        drawRect.width,
        drawRect.height,
      );
      //显示背景区域
      // if (!_hideRectBg) {
      //   canvas.drawRect(
      //     toRect, // Draw only the visible intersection
      //     Paint()..color = MathClass.getRandomColor(),
      //   );
      // }

      //绘制底图
      int imgW = _bgImage!.width  ;
      int imgH = _bgImage!.height   ;

      double scale = max(imgW / drawRect.width, imgH / drawRect.height);
      Rect srcRect = Rect.fromLTWH(0.0, 0.0, imgW *1.0, imgH *1.0);
      Rect dstRect = Rect.fromLTWH(
        toRect.left + (toRect.width - imgW / scale) / 2.0,
        toRect.top + (toRect.height - imgH / scale) / 2.0,
        imgW / scale,
        imgH / scale,
      );
      canvas.drawImageRect(_bgImage!, srcRect, dstRect, Paint());
      //绘制文本


      if(_labelPainter!=null){

        _labelPainter?.paint(
          canvas,
          Offset(
            toRect.left +(toRect.width- _labelPainter!.width)/2.0,
            toRect.top,
          ),
        );
      }

    }
  }
}
