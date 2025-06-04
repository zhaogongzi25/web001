import 'package:flutter/material.dart';
import 'package:live/page/home/room/sliver_chat/icon/base_icon.dart';

import '../vo/base_info_vo.dart';

class TittleBaseIcon extends BaseIcon {
  final String title;
  final Offset pos;

  TittleBaseIcon({
    required super.url,
    required super.textStyle,
    required super.titleLen,
    required super.boxRect,
    required this.title,
    required this.pos,
  });

  //显示文本
  TextPainter? _labelPainter;

  void initData() {
    _makeLabel(title);
  }

  void draw(Canvas canvas, BaseInfovo vo, double ty) {
    super.draw(canvas, vo, ty);

    if (_labelPainter != null) {
      //微调等级坐标
      _labelPainter?.paint(
        canvas,
        Offset(
          toRect!.left + (toRect!.width - _labelPainter!.width) / 2.0 + pos.dx,
          toRect!.top + pos.dy,
        ),
      );
    }
  }

  void _makeLabel(label) {
    _labelPainter = TextPainter(
      text:
          TextSpan(text: label, style: textStyle.copyWith(fontWeight: FontWeight.bold,fontSize: textStyle.fontSize!*0.8 ,   color: Colors.white)),
      textDirection: TextDirection.rtl,
    )..layout(minWidth: 0, maxWidth: double.infinity);
  }
}
