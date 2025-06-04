import 'dart:ui' as ui;
import 'package:data_center/live_old/model/data_manager.dart';
import 'package:data_center/live_old/model/room_player.dart';
import 'package:data_center/live_old/utility/colors.dart';
import 'package:data_center/live_old/utility/string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../custom_chat_controller.dart';
import 'base_info_vo.dart';
import 'image_load_manager.dart';

class NineImageDraw {
  //9宫格边缘宽度
  double ctxPodding = 5.0;
  double nineSize = 20.0;
  ui.Image? image;
  final CustomcChatController chatController;
  final int bgType;
  NineImageDraw( {
    String? url,
    required double nineBorderSize,
    required this.chatController,
    required this.bgType,
  }) {
    nineSize = nineBorderSize;
    if (url != null) {
      _loadImage(url);
    }  

  }

  void draw(BaseInfovo vo, Canvas canvas, double ty) {
    if(bgType==2){
      _drawRoundRedBg(canvas, vo, ty);
    }else{
      if (image == null) {
        _drawRoundBg(canvas, vo, ty);
      } else {
        _drawVoNineGridImg(canvas, vo, Offset(0.0, vo.rect!.top - ty));
      }
    }

  }

  //绘制9宫格单色没图背景
  void _drawRoundRedBg(Canvas canvas, BaseInfovo vo, double ty) {
    // 1. 创建一个用于填充的 Paint 对象
    // player?.vipLevel ?? 0,
    int vipLevel=0;
    RoomPlayer? player =
    dataMgr.findObj(TableNames.roomPlayer, vo.roomMsg.userId) != null
        ? dataMgr.findObj(TableNames.roomPlayer, vo.roomMsg.userId)
    as RoomPlayer
        : null;
    if (player != null) {

      vipLevel=player.vipLevel;
    }

    Color bgLineColor;
    Color bgColor;
    switch (vipLevel) {
      case 5:
      // 侯爵 - 蓝色
        bgLineColor = const Color(0xff00BFFF);
        bgColor = const Color(0x300053c4);
        // 紫色
        // bgLineColor = Color(0x808134af);
        // bgColor = Color(0x40390073);
        break;
      case 6:
      // 公爵 -紫色
        bgLineColor = const Color(0xffff00ff);
        bgColor = const Color(0x308707c2);
        // 玫红
        // bgLineColor = Color(0xffff1493);
        // bgColor = Color(0x30c30e5d);
        break;
      case 7:
      // 国王 -玫红
        bgLineColor = const Color(0xffff1493);
        bgColor = const Color(0x30c30e5d);
        // 金色
        // bgLineColor = Color(0x80feda6a);
        // bgColor = Color(0x505b4202);
        break;
      default:

          bgLineColor = Colors.black12;
          bgColor = Colours.public_transparent_bg;

        break;
    }

    final fillPaint = Paint()
      ..color = bgColor  // 黑半透明 (这里使用了 50% 透明度)
      ..style = PaintingStyle.fill;             // 填充样式
    // 2. 创建一个用于描边的 Paint 对象 (边框)
    final strokePaint = Paint()
      ..color =bgLineColor                  // 红色边框
      ..style = PaintingStyle.stroke           // 描边样式
      ..strokeWidth = 1.0;                   // 边框宽度


    // 定义圆角半径
    const radius = Radius.circular(15.0); // 所有角都使用 15.0 的圆角
    final rrect = RRect.fromRectAndRadius( Rect.fromLTWH(
      0,
      (vo.rect!.top - ty + 1),
      vo.rect!.width,
      vo.rect!.height - 2,
    ), radius); // 创建 RRect 对象
    // 4. 先绘制填充 (背景)
    canvas.drawRRect(rrect, fillPaint);
    // 5. 再绘制描边 (边框)
    canvas.drawRRect(rrect, strokePaint);
  }
  //绘制9宫格单色没图背景
  void _drawRoundBg(Canvas canvas, BaseInfovo vo, double ty) {
    final paint = Paint()
      ..color = const ui.Color.fromARGB(113, 19, 18, 18) // 设置颜色
      ..style = PaintingStyle.fill; // 设置绘制样式: fill (填充) 或 stroke (描边)
    final radius = Radius.circular(10);

    RRect rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        0,
        (vo.rect!.top - ty + 2),
        vo.rect!.width,
        vo.rect!.height - 4,
      ),
      radius,
    );

    canvas.drawRRect(rect, paint);
  }
  //绘制9宫格背景
  void _drawVoNineGridImg(Canvas canvas, BaseInfovo vo, Offset pos) {
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

  Future<void> _loadImage(String url) async {
    // image=await ImageLoadManager.getImageLocalorNet(url);
    ImageLoadManager.getImageLocalorNetFun(url, (ui.Image value) {
      image = value;
      chatController.refreshNum++;
      chatController.refreshUi();
    });
  }
}
