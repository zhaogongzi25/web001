
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../chatcell/room_chat_cell_vo.dart';

//基础Icon图片
class ChatBaseIcon {
  //背景图片
  ui.Image? bgImage;
  //绘制到的位置
  Rect? drawToRect;
  final String url;
  final VoidCallback? onTap;
  final RoomChatCellVo roomChatCellVo;
  ChatBaseIcon({
    required this.url,
    required this.roomChatCellVo,
    this.onTap,
  }) {
    //必须有一张底图

    initData();
  }
  bool _loadIng=false;
  void show() {
    //没有图片并没有在加载那么我就要加载图片了
     if(bgImage==null&&_loadIng==false){
       _loadIng=true;
       roomChatCellVo.chatController.getImageLocalOrNetFun(url, (ui.Image? value) {
         _loadIng=false;
         bgImage = value;
         roomChatCellVo.chatController.refreshNum++;
         roomChatCellVo.chatController.refreshUi();
       });
     }
  }
  void hide() {
    //有图我就清理；无法中断图片加载过程
     if(bgImage!=null){
       _loadIng=false;
       bgImage=null;
     }
  }
  void initData() {

  }
  bool hitTest(RoomChatCellVo vo, Offset clikPos) {
    //写法有点罗说，需要在创建的时候就算出位置
    return true;
  }
  //绘制Icon图标
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
