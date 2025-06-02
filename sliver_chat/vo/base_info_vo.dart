import 'dart:ui';

import 'package:data_center/live_old/model/data_manager.dart';
import 'package:data_center/live_old/model/room_msg.dart';
import 'package:data_center/live_old/model/room_player.dart';
import 'package:data_center/live_old/utility/string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import '../chatcell/base_text_link.dart';
import '../chatcell/chat_text_talk.dart';
import '../chatcell/notify_info_talk.dart';
import '../chatcell/room_msg_chat.dart';
import '../chatcell/system_info_talk.dart';
import '../custom_chat_controller.dart';

import 'nine_image_draw.dart';

//每一条显示记录对象
class BaseInfovo {
  final CustomcChatController chatController;
  final RoomMsg roomMsg;

  // final int type;
  Rect? rect;
  NineImageDraw? niceImage;
  BaseTextLink? textLink;
  Color color = Colors.red;

  int skipId = 0;

  BaseInfovo({required this.roomMsg, required this.chatController}) {
    //  'https://zhaogongzi25.github.io/web001/bg_130_130.png'

    initData();

    resize();
  }

  void initData() {
    
    niceImage = NineImageDraw(
      chatController: chatController,
      // url: 'https://zhaogongzi25.github.io/web001/bg_216_96.png',
      url: null,
      nineBorderSize: 10,
    );


    RoomMsg item = roomMsg!;
    textLink = RoomMsgChat(item);
  }

  bool hitTest(BaseInfovo vo, Offset clikpos) {
    return textLink!.hitTest(vo, clikpos);
  }

  void draw(Canvas canvas, double ty) {
    if(textLink!.hide){
      return;
    }

    niceImage!.draw(this, canvas, ty);
    textLink!.draw(this, canvas, ty);
    _drawIdToCtx(canvas, this, ty);
  }

  void _drawIdToCtx(Canvas canvas, BaseInfovo vo, double ty) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: vo.skipId.toString(),
        style: TextStyle(color: Colors.black, fontSize: 15),
      ),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: 250);

    textPainter.paint(
      canvas,
      Offset(vo.rect!.width - 50 + 5, vo.rect!.top + vo.rect!.height - 30 - ty),
    );
  }

  void resize() {
    if (textLink!.hide) {
      rect = Rect.fromLTWH(
        0,
        0,
        0,
        0,
      );
    } else    if (niceImage !=null) {
      rect = Rect.fromLTWH(
        0,
        0,
        textLink!.textPainter!.width +
            (niceImage!.ctxPodding + niceImage!.ctxPodding),
        textLink!.textPainter!.height +
            (niceImage!.ctxPodding + niceImage!.ctxPodding),
      );
    }else{
       rect = Rect.fromLTWH(
        0,
        0,
        textLink!.textPainter!.width ,
             
        textLink!.textPainter!.height );
            
    }
  }
// static double getTotalheight(List<BaseInfovo> arr) {
//   double num = 0;
//   for (BaseInfovo vo in arr) {
//     num += vo.rect!.height;
//   }
//   return num;
// }
}
