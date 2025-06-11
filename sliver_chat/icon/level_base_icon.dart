import 'package:common_base/common_base.dart';
import 'package:flutter/material.dart';

import '../chatcell/room_chat_cell_vo.dart';
import 'head_base_icon.dart';

//前排定制显示等级的图标
class LevelBaseIcon extends HeadBaseIcon {
  final int level;
  //显示文本
  TextPainter? _labelPainter;
  final TextStyle textStyle;
  LevelBaseIcon({
    required super.url,
    required super.iconLen,
    required super.boxRect,
    required super.roomChatCellVo,
    required this.level,
    required this.textStyle,
  });
  //绘制文本因为在Icon上基本上都有指定偏移，如果需要对应的排序方法，如等级，其它排序，需要对应该相对位置进行微调
  void draw(Canvas canvas, RoomChatCellVo vo, double ty) {
    super.draw(canvas, vo, ty);
    if ( drawToRect != null) {

      Offset labelPos= Offset(12.w, 3.w);
      if (level < 10) {
        labelPos= Offset(16.w, 3.w);
      } else if (level > 90 && level < 100) {
        labelPos= Offset(15.w, 3.w);
      } else if (level >= 100) {
        labelPos= Offset(18.w, 3.w);
      }
      _makeTextPainter();
      //微调等级坐标
      _labelPainter?.paint(
        canvas,
        Offset(
          drawToRect!.left + (drawToRect!.width - _labelPainter!.width) / 2.0 + labelPos.dx,
          drawToRect!.top + labelPos.dy,
        ),
      );
    }
  }
  void _makeTextPainter(){
    if(_labelPainter!=null){
      return;
    }
    _labelPainter = TextPainter(
      text: TextSpan(
          text: level.toString(),
          style: textStyle.copyWith(
              decoration: TextDecoration.none, fontWeight: FontWeight.bold, fontSize: 20.sp, color: Colors.white)),
      textDirection: TextDirection.rtl,
    )..layout(minWidth: 0, maxWidth: double.infinity);
  }


}
