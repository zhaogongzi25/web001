import 'package:common_base/common_base.dart';

import 'package:data_center/live_old/model/room_msg.dart';
import 'package:flutter/material.dart';
import '../view/base_text_link.dart';
import 'model_pack.dart';
import 'room_chat_text.dart';
import '../custom_chat_controller.dart';
import '../view/base_nine_image.dart';

//每一条显示记录对象
class RoomChatCellVo {
  //内容距离边缘区域值 左上右下 可以设置不一样的值

  // padding: EdgeInsets.only(
  // top: 5.w,
  // bottom: 5.w,
  // left: 12.w,
  // right: isShouldWrap! ? 16.w : 8.w),
  Rect ctxPodding = Rect.fromLTRB(12.w, 8.w, 16.w, 8.w);

  //基础文本颜色，字号，行距，
  //   height ??= 2.5.w;  //默认
  TextStyle textStyle =
      TextStyle(color: Colors.white, fontSize: 24.sp, height: 2.5.w, fontWeight: FontWeight.w400); //原来chat的数值

  //最终绘制的矩形。top为起始位置， height为当条记录的高度
  Rect? rect;

  //9宫格对象，当没有图片，也可以是纯色背景和边框。用于扩容做为背景显示
  BaseNineImage? niceImage;

  //文本内容显示。
  BaseTextLink? textLink;

  //和chatController控制器
  final CustomcChatController chatController;

  //传入房间的聊天信息
  final RoomMsg roomMsg;

  final ModelPack modelPack;

  final double width;


  int idnum=9;
  static int  skipNum=0;
  //传入房间信息roomMsg 和chatController控制器
  RoomChatCellVo({required this.roomMsg, required this.modelPack, required this.width, required this.chatController}) {
    idnum=skipNum++;
    initData();
    resize();
  }


  void dispose() {
    // print('dispose  RoomChatCellVo');
  }

  //初始创建
  void initData() {
    niceImage = BaseNineImage(
      chatController: chatController,
      // url: 'https://zhaogongzi25.github.io/web001/bg_216_96.png',
      nineSize: 10, //只能是像素，不需要.w
    );

    textLink = RoomChatText(

      roomMsg: roomMsg,
      modelPack: modelPack,
      textStyle: textStyle,
      maxWidth: width - ctxPodding.left - ctxPodding.right,
    );
  }

  //传递点击事件
  bool hitTest(RoomChatCellVo vo, Offset clikPos) {
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
    if (niceImage != null && textLink != null && textLink!.textPainter != null) {
      Offset wh = textLink!.getDrawRect();
      rect = Rect.fromLTWH(
        0, //初始先设定为0.组织后第一个的宽度，再变量所有记录修改位置用于显示
        0,
        wh.dx + (ctxPodding.left + ctxPodding.right),
        wh.dy + (ctxPodding.top + ctxPodding.bottom),
      );
    } else {
      //现在都是设定有背景和文本的方法 不会出现到这里的显示内容
      rect = Rect.fromLTWH(0, 0, 0, 0);
    }
  }
}
