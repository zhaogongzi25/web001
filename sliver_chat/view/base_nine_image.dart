import 'dart:ui' as ui;
import 'package:common_base/common_base.dart';

import 'package:data_center/live_old/model/room_player.dart';
import 'package:data_center/live_old/utility/colors.dart';

import 'package:flutter/material.dart';

import '../chatcell/room_chat_text.dart';
import '../custom_chat_controller.dart';
import '../chatcell/room_chat_cell_vo.dart';
import 'image_load_manager.dart';

class BaseNineImage {
  //加载到的图像数据，用于绘制
  ui.Image? image;

  //传递控制器是为了有可能加载的背景图片是网络，需要在加载成功后，通知组件属性，见意使用本地图片这样可以不需要再请求加载
  final CustomcChatController chatController;

  //9宫格边缘宽度 设定是上下左右都是一样的拉绅方法的9宫图像 设定为20图像像素，在传入的数值也是绝对像素
  final double nineSize; //= 20.0;

  BaseNineImage({
    String? url,
    required this.nineSize,
    required this.chatController,
  }) {
    if (url != null) {
      _loadImage(url);
    }
  }
  //如果有9宫格图，没有现在绘制的是聊天对象的背景，还需要分离
  void draw(RoomChatCellVo vo, Canvas canvas, double ty) {
    if (image == null) {
      _drawRoundRedBg(canvas, vo, ty);
    } else {
      _drawVoNineGridImg(canvas, vo, Offset(0.0, vo.rect!.top - ty));
    }
  }

  //绘制9宫格单色没图背景
  void _drawRoundRedBg(Canvas canvas, RoomChatCellVo vo, double ty) {
    int vipLevel = 0;


    RoomPlayer? player =RoomChatText.getRoomPlayerByUserId(vo.roomMsg.userId);
    if (player != null) {
      vipLevel = player.vipLevel;
    }


    Color bgLineColor;
    Color bgColor;
    switch (vipLevel) {
      case 5:
        // 侯爵 - 蓝色
        bgLineColor = const Color(0xff00BFFF);
        bgColor = const Color(0x300053c4);

        break;
      case 6:
        // 公爵 -紫色
        bgLineColor = const Color(0xffff00ff);
        bgColor = const Color(0x308707c2);

        break;
      case 7:
        // 国王 -玫红
        bgLineColor = const Color(0xffff1493);
        bgColor = const Color(0x30c30e5d);

        break;
      default:
        bgLineColor = Colors.black12;
        bgColor = Colours.public_transparent_bg;

        break;
    }

    final fillPaint = Paint()
      ..color = bgColor // 黑半透明 (这里使用了 50% 透明度)
      ..style = PaintingStyle.fill; // 填充样式

    final strokePaint = Paint()
      ..color = bgLineColor // 红色边框
      ..style = PaintingStyle.stroke // 描边样式
      ..strokeWidth = 2.w; // 边框宽度


    Radius radius = Radius.circular(20.w); // 所有角都使用 20.w 的圆角
    final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          0,
          (vo.rect!.top - ty + 3.w),
          vo.rect!.width,
          vo.rect!.height - 6.w,
        ),
        radius); // 创建 RRect 对象
    canvas.drawRRect(rrect, fillPaint);
    canvas.drawRRect(rrect, strokePaint);
  }

  //绘制9宫格背景
  void _drawVoNineGridImg(Canvas canvas, RoomChatCellVo vo, Offset pos) {
    if (image != null) {
      Rect center = Rect.fromLTWH(
        nineSize,
        nineSize,
        image!.width - 2.0 * nineSize,
        image!.height - 2.0 * nineSize,
      );
      Rect dst = Rect.fromLTWH(0.0, pos.dy, vo.rect!.width, vo.rect!.height);
      final paint = ui.Paint();

      canvas.drawImageNine(image!, center, dst, paint);

 
 

    }

  }
  //加载9宫格图片
  Future<void> _loadImage(String url) async {
    ImageLoadManager.getImageLocalorNetFun(url, (ui.Image value) {
      image = value;
      chatController.refreshNum++;
      chatController.refreshUi();
    });
  }
}
