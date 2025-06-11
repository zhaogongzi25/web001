import 'package:common_base/common_base.dart';

import 'package:data_center/live_old/model/room_msg.dart';
import 'package:flutter/material.dart';

import 'model_pack.dart';
import 'room_chat_text.dart';
import '../view/base_text_link.dart';
import '../custom_chat_controller.dart';


//每一条显示记录对象
class RoomChatCellVo {
  //内容距离边缘区域值 左上右下 可以设置不一样的值
  Rect ctxPodding = Rect.fromLTRB(12.w, 8.w, 16.w, 8.w);

  //基础文本颜色，字号，行距，
  TextStyle textStyle =
      TextStyle(color: Colors.white, fontSize: 24.sp, height: 2.5.w, fontWeight: FontWeight.w400); //原来chat的数值
  //一个空字符的宽度
  static String sampleSpace = '\u2002';

  //一个空字符的宽度
  static double? sampleCodeWidth;

  //最终绘制的矩形。top为起始位置， height为当条记录的高度
  Rect rect = Rect.fromLTWH(0, 0, 0, 0);


  //文本内容显示。
  BaseTextLink? textLink;

  //和chatController控制器
  final CustomcChatController chatController;

  //传入房间的聊天信息
  final RoomMsg roomMsg;

  //数据对象包，存放要向下传递的model
  final ModelPack modelPack;

  // RoomPlayer? voPlayer;

  //传入聊天框宽度， 最能设置每行最大自动换行
  final double width;

  //传入房间信息roomMsg 和chatController控制器
  RoomChatCellVo({required this.roomMsg, required this.modelPack, required this.width, required this.chatController}) {
    _initSampleKongGeWidth();
    //显示文本内容，
    textLink = RoomChatText(
      roomChatCellVo: this,
      textStyle: textStyle,
      maxWidth: width - ctxPodding.left - ctxPodding.right,
    );
    resetSize();
  }

//使用显示的文字来计算一次一个空格的宽度，用于填充第一行的行进位置
  void _initSampleKongGeWidth() {
    if (RoomChatCellVo.sampleCodeWidth == null) {
      TextStyle baseStyle = textStyle;
      TextPainter textPainter = TextPainter(
        text: TextSpan(text: RoomChatCellVo.sampleSpace, style: baseStyle),
        textDirection: TextDirection.ltr,
      )..layout(minWidth: 0, maxWidth: double.infinity);
      RoomChatCellVo.sampleCodeWidth = textPainter.width;
      // print('读算一次空格宽度');
    }
  }

  //传递点击事件
  bool hitTest(RoomChatCellVo vo, Offset clikPos) {
    return textLink!.hitTest(vo, clikPos);
  }

  //传递绘制方法，每个对象有自己的绘制方法，这样可以脱离组件，根据内容在自己的对像中绘制
  void draw(Canvas canvas, double ty) {
    if (rect.height > 0 && rect.width > 0) {

      textLink!.draw(this, canvas, ty);
    }
  }

  //记算当前cell的尺寸，用于在列表中的排序位置，所有需要显示的对象都是需要进行先记算
  void resetSize() {
    if (textLink != null && textLink!.textPainter != null) {
      Offset wh = textLink!.getDrawRect();
      rect = Rect.fromLTWH(
        0, //初始先设定为0.组织后第一个的宽度，再变量所有记录修改位置用于显示
        0,
        wh.dx + (ctxPodding.left + ctxPodding.right),
        wh.dy + (ctxPodding.top + ctxPodding.bottom),
      );
      chatController.resetListPosAll();
    }
  }
}
