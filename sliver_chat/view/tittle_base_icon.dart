import 'package:common_base/common_base.dart';
import 'package:flutter/material.dart';
import 'package:live/page/home/room/sliver_chat/view/head_base_icon.dart';

import '../chatcell/room_chat_cell_vo.dart';

class TittleBaseIcon extends HeadBaseIcon {
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

  //绘制文本因为在Icon上基本上都有指定偏移，如果需要对应的排序方法，如等级，其它排序，需要对应该相对位置进行微调
  void draw(Canvas canvas, RoomChatCellVo vo, double ty) {
    super.draw(canvas, vo, ty);
    if (_labelPainter != null && drawToRect != null) {
      //微调等级坐标
      _labelPainter?.paint(
        canvas,
        Offset(
          drawToRect!.left +
              (drawToRect!.width - _labelPainter!.width) / 2.0 +
              pos.dx,
          drawToRect!.top + pos.dy,
        ),
      );
    }
  }

  

  //创建文本对象 //这里用的字号，暂为基础文本的0.8. 这个数值需要预定。倒底应该显示为多大比例，还是固定数字
  void _makeLabel(label) {
    try {
      _labelPainter = TextPainter(
        text: TextSpan(
            text: label,
            style: textStyle.copyWith(
                decoration: TextDecoration.none,
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
                color: Colors.white)),
        textDirection: TextDirection.rtl,
      )..layout(minWidth: 0, maxWidth: double.infinity);
    } catch (e) {

      print('不应该到这   TittleBaseIcon');
    } finally {

    }

  }
}
