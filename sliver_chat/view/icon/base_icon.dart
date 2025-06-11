import 'dart:math';
import 'dart:ui' as ui;
import 'package:common_base/common_base.dart';
import 'package:flutter/material.dart';

import '../../chatcell/room_chat_cell_vo.dart';
import '../image_load_manager.dart';

class BaseIcon {
  //背景图片
  ui.Image? bgImage;
  final VoidCallback? onTap;
  final RoomChatCellVo roomChatCellVo;
  Rect? drawToRect;
  BaseIcon({
    required String url,
    required this.roomChatCellVo,
    this.onTap,
  }) {
    initData();
    ImageLoadManager.getImageLocalorNetFun(url, (ui.Image? value) {
      bgImage = value;
      roomChatCellVo.chatController.refreshNum++;
      roomChatCellVo.chatController.refreshUi();
    });
  }
  void initData() {

  }
  bool hitTest(RoomChatCellVo vo, Offset clikPos) {
    //写法有点罗说，需要在创建的时候就算出位置
    return true;
  }

  //绘制的区域，这是在列表表中对应该布局坐标


  //将内容绘制到空格范围内容
  void draw(Canvas canvas, RoomChatCellVo vo, double ty) {
    if(bgImage!=null &&drawToRect!=null){

      // canvas.drawRect(
      //   drawToRect!,
      //   Paint()..color =Colors.white,
      // );

      Rect srcRect = Rect.fromLTWH(0.0, 0.0, bgImage!.width * 1.0, bgImage!.height * 1.0);
      canvas.drawImageRect(bgImage!, srcRect, drawToRect!, Paint());
    }


  }
}
