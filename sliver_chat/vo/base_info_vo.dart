import 'dart:math';
import 'dart:ui';

import 'package:common_base/common_base.dart';
import 'package:data_center/live_old/model/data_manager.dart';
import 'package:data_center/live_old/model/room_msg.dart';
import 'package:data_center/live_old/model/room_player.dart';
import 'package:data_center/live_old/utility/string.dart';
import 'package:data_center/utils/chat_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import '../chatcell/base_text_link.dart';

import '../chatcell/room_msg_chat.dart';

import '../custom_chat_controller.dart';

import 'nine_image_draw.dart';

//每一条显示记录对象
class BaseInfovo {
  final CustomcChatController chatController;
  final RoomMsg roomMsg;

  //基础文本颜色，
  TextStyle textStyle = TextStyle(
      color: Colors.white, fontSize: 24.sp, height: 2.5.w); //原来chat的数值
  //最终绘制的矩形。top为起始位置， heigth为当条记录的高度
  Rect? rect;

  //9宫格对象，当没有图片，也可以是纯色背景和边框。用于扩容做为背景显示
  NineImageDraw? niceImage;

  //文本内容显示。
  BaseTextLink? textLink;

  //传入房间信息roomMsg 和chatController控制器
  BaseInfovo({required this.roomMsg, required this.chatController}) {
    initData();
    resize();
  }

  //初始创建
  void initData() {
    niceImage = NineImageDraw(
      chatController: chatController,
      // url: 'https://zhaogongzi25.github.io/web001/bg_216_96.png',
      url: null,
      bgType: 2, //暂时设定2为红色
      nineBorderSize: 10,
    );
    textLink = RoomMsgChat(roomMsg, baseStyle: textStyle);
  }

  //传递点击事件
  bool hitTest(BaseInfovo vo, Offset clikPos) {
    return textLink!.hitTest(vo, clikPos);
  }

  //传递绘制方法，每个对象有自己的绘制方法，这样可以脱离组件，根据内容在自己的对像中绘制
  void draw(Canvas canvas, double ty) {
    //先绘制背景
    niceImage!.draw(this, canvas, ty);
    //绘制上层文本
    textLink!.draw(this, canvas, ty);
  }

  //记算当前cell的尺寸，用于在列表中的排序位置，所有需要显示的对象都是需要进行先记算
  void resize() {
    if (textLink == null && niceImage == null) {
      //当没有文本，也没有背景设置为空，不应该到这里，做异常赋值，真实情况可以不要做判断
      rect = Rect.fromLTWH(0, 0, 0, 0);
    } else {
      //有背景和文本 应该都是到这里
      if (niceImage != null && textLink != null) {
        rect = Rect.fromLTWH(
          0,
          0,
          textLink!.textPainter!.width +
              (niceImage!.ctxPodding + niceImage!.ctxPodding),
          textLink!.textPainter!.height +
              (niceImage!.ctxPodding + niceImage!.ctxPodding) +
              textLink!.multipleLinesH,
        );
      } else {
        //只有背景
        if (niceImage != null&&textLink==null) {
          rect = Rect.fromLTWH(
              0,
              0,
              (niceImage!.ctxPodding + niceImage!.ctxPodding),
              (niceImage!.ctxPodding + niceImage!.ctxPodding));
        }
        //只有文本
        if (textLink != null&&niceImage==null) {
          rect = Rect.fromLTWH(
            0,
            0,
            textLink!.textPainter!.width,
            textLink!.textPainter!.height + textLink!.multipleLinesH,
          );
        }
      }

    }
  }
}
