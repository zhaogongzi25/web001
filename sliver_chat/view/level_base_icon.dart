import 'dart:io';
import 'dart:ui';

import 'package:common_base/common_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:live/page/home/room/sliver_chat/view/tittle_base_icon.dart';

import '../chatcell/room_chat_cell_vo.dart';
import 'head_base_icon.dart';

class LevelBaseIcon extends HeadBaseIcon {
  final int level;
  final Offset pos;

  LevelBaseIcon({
    required super.url,
    required super.textStyle,
    required super.titleLen,
    required super.boxRect,
    required this.level,
    required this.pos,
  });

  //显示文本
  TextPainter? _labelPainter;

  void initData() {
    _makeLabel(level);
  }

  //绘制文本因为在Icon上基本上都有指定偏移，如果需要对应的排序方法，如等级，其它排序，需要对应该相对位置进行微调
  void draw(Canvas canvas, RoomChatCellVo vo, double ty) {
    super.draw(canvas, vo, ty);
    if (_labelPainter != null && drawToRect != null) {
      //微调等级坐标
      double rVal =25.w;
      int lv = level;
      double rw = (rVal / 2).w;
      if (lv < 10) {
        if (Platform.isAndroid) {
          rw = 18.w;
        } else {
          rw = 15.w;
        }
      } else if (lv > 90 && lv < 100) {
        rw = 18.w;
      }
      _labelPainter?.paint(
        canvas,
        Offset(
          drawToRect!.left + drawToRect!.width - rw-30.w,
          drawToRect!.top + pos.dy,
        ),


      );
    }
  }


  //创建文本对象 //这里用的字号，暂为基础文本的0.8. 这个数值需要预定。倒底应该显示为多大比例，还是固定数字
  void _makeLabel(level) {
    _labelPainter = TextPainter(
      text: TextSpan(
          text: "${level}",
          style: textStyle.copyWith(
              decoration: TextDecoration.none,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
              color: Colors.white)),
      textDirection: TextDirection.rtl,
    )..layout(minWidth: 0, maxWidth: double.infinity);
  }
}
