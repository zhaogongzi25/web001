
import 'dart:math';

import 'package:common_base/common_base.dart';
import 'package:data_center/utils/sliver_chat/view/icon/base_icon.dart';
import 'package:flutter/material.dart';
import '../chatcell/room_chat_cell_vo.dart';

//前排icon,是需要叠加到文本内容的缩进位关联
class HeadBaseIcon extends BaseIcon {
  //起始位置，后续逐个叠加在文本的开始使用.
  double startLeft = 0.0;
  //图像偏移，默认为0,0,0,0;计算出来的文字空间再扩展
  final Rect boxRect;
  //设定图片占用的文字宽度。用的是空格数量，和字号关联，做到图片和文字同比static String sampleSpace='\u2002'; //一个空字符的宽度
  final int titleLen;

  HeadBaseIcon({
    required super.url,
    required this.titleLen,
    required this.boxRect,
    required super.roomChatCellVo,
  });

  //获取Icon的宽度， 这将用来累加前排Icon宽度
  double getWidth() {
    double tw = RoomChatCellVo.sampleCodeWidth ?? 20.w; //应该到这里都算好了，
    return tw * titleLen;
  }

  //绘制con图标
  void draw(Canvas canvas, RoomChatCellVo vo, double ty) {
    if (bgImage != null) {
      Rect drawRect = Rect.fromLTWH(
        boxRect.left,
        boxRect.top,
        boxRect.width,
        boxRect.height,
      );
      double ttx = vo.ctxPodding.left + startLeft;
      double tty = vo.rect.top - ty + vo.ctxPodding.top;
      drawToRect = Rect.fromLTWH(
        ttx + drawRect.left,
        tty + drawRect.top + vo.textLink!.multipleLinesH / 2.0,
        boxRect.width,
        boxRect.height,
      );

        // canvas.drawRect(
        //   Rect.fromLTWH(
        //     ttx,
        //     tty,
        //     getWidth(),
        //     32.w,
        //   ), // Draw only the visible intersection
        //   Paint()..color = Color(0xFF000000 | Random().nextInt(0xFFFFFF + 1)),
        // );



    }

    super.draw(canvas, vo, ty);

  }
}
