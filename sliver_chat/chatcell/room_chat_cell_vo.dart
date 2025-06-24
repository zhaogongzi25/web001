import 'package:common_base/common_base.dart';

import 'package:data_center/live_old/model/room_msg.dart';
import 'package:flutter/material.dart';

import '../base/custom_chat_controller.dart';
import '../base/model_pack.dart';
import 'room_chat_text.dart';
import '../base/custom_base_text_link.dart';

//每一条显示记录对象
class RoomChatCellVo {
  //最终绘制的矩形。top为起始位置， height为当条记录的高度
  Rect rect = Rect.fromLTWH(0, 0, 0, 0);

  //内容距离边缘区域值 左上右下 可以设置不一样的值
  Rect? ctxPodding ;

  //基础文本颜色，字号，行距，
  TextStyle? textStyle  ; //原来chat的数值

  // TextStyle textStyle =
  // TextStyle(color: Colors.white, fontSize: 24.sp, height: 2.5.w, fontWeight: FontWeight.w400); //原来chat的数值
  //一个空字符的宽度
  static String sampleSpace = '\u2002';

  //一个空字符的宽度
  static double? sampleCodeWidth;




  //文本内容显示。
  CustomBaseTextLink? textLink;

  //和chatController控制器
  final CustomcChatController chatController;

  //传入房间的聊天信息
  final RoomMsg roomMsg;

  //数据对象包，存放要向下传递的model
  final ModelPack modelPack;

  //传入聊天框宽度， 最能设置每行最大自动换行
  final double width;

  int id = 0;

  //传入房间信息roomMsg 和chatController控制器
  RoomChatCellVo({required this.roomMsg, required this.modelPack, required this.width, required this.chatController}) {
    _initSampleKongGeWidth();
    //显示文本内容，
    id = chatController.data.length;

    _resetCellWidget();
  }

//使用显示的文字来计算一次一个空格的宽度，用于填充第一行的行进位置
  void _initSampleKongGeWidth() {
    if (RoomChatCellVo.sampleCodeWidth == null) {
        ctxPodding = Rect.fromLTRB(12.w, 8.w, 16.w, 8.w);

      //基础文本颜色，字号，行距，
        textStyle = TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.w400); //原来chat的数值


      TextPainter textPainter = TextPainter(
        text: TextSpan(text: RoomChatCellVo.sampleSpace, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout(minWidth: 0, maxWidth: double.infinity);
      RoomChatCellVo.sampleCodeWidth = textPainter.width;
      // print('读算一次空格宽度');
    }
  }

  //重置对象内组件，这个是要配合显示和隐藏。
  void _resetCellWidget() {
    if (textLink == null) {
      //内容距离边缘区域值 左上右下 可以设置不一样的值
        ctxPodding = Rect.fromLTRB(12.w, 8.w, 16.w, 8.w);

      //基础文本颜色，字号，行距，
        textStyle = TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.w400); //原来chat的数值
      textLink = RoomChatText(
        roomChatCellVo: this,
        textStyle: textStyle!,
        maxWidth: width - ctxPodding!.left - ctxPodding!.right,
      );

      resetSize();
    }
  }

  //传递点击事件
  bool hitTest(RoomChatCellVo vo, Offset clikPos) {
    if (textLink != null) {
      return textLink!.hitTest(vo, clikPos);
    } else {
      return false;
    }
  }

  //传递绘制方法，每个对象有自己的绘制方法，这样可以脱离组件，根据内容在自己的对像中绘制
  void draw(Canvas canvas, double ty) {
    if (rect.height > 0 && rect.width > 0 && textLink != null) {
      textLink!.draw(this, canvas, ty);
    }
  }

  void show() {
    if (textLink == null) {
      _resetCellWidget();
    }
    textLink!.showBmp();
  }

  //拥有整体坐标-->标记是否进行了队列排序
  bool hasScenePostion = false;

  void hide() {
      if (textLink != null && rect.height>0&&hasScenePostion) {
        // textLink!.dispose();
        textLink = null;
        ctxPodding =null;
        textStyle =null;
        // print('清理  $id');
      }

  }

  //记算当前cell的尺寸，用于在列表中的排序位置，所有需要显示的对象都是需要进行先记算


  void resetSize() {
    if (textLink != null && textLink!.textPainter != null&&rect.height==0) {
      Offset wh = textLink!.getDrawRect();
      rect = Rect.fromLTWH(
        rect.left, //初始先设定为0.组织后第一个的宽度，再变量所有记录修改位置用于显示
        rect.top,
        wh.dx + (ctxPodding!.left + ctxPodding!.right),
        wh.dy + (ctxPodding!.top + ctxPodding!.bottom),
      );

      chatController.resetListPosAll();
    }
  }
}
