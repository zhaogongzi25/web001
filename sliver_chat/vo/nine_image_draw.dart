import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../custom_chat_controller.dart';
import 'base_info_vo.dart';
import 'image_load_manager.dart';

class NineImageDraw {
  //9宫格边缘宽度
  double ctxPodding = 15.0;
  double nineSize = 20.0;
  ui.Image? image;
  final CustomcChatController chatController;

  NineImageDraw({
    String? url,
    required double nineBorderSize,
    required this.chatController,
  }) {
    nineSize = nineBorderSize;
    if (url != null) {
      _loadImage(url);
    }  

  }

  void draw(BaseInfovo vo, Canvas canvas, double ty) {
    if (image == null) {
      _drawRoundBg(canvas, vo, ty);
    } else {
      _drawVoNineGridImg(canvas, vo, Offset(0.0, vo.rect!.top - ty));
    }
  }

  //绘制9宫格背景
  void _drawRoundBg(Canvas canvas, BaseInfovo vo, double ty) {
    final paint = Paint()
      ..color = const ui.Color.fromARGB(113, 19, 18, 18) // 设置颜色
      ..style = PaintingStyle.fill; // 设置绘制样式: fill (填充) 或 stroke (描边)
    final radius = Radius.circular(20);

    RRect rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        0,
        (vo.rect!.top - ty + 1),
        vo.rect!.width,
        vo.rect!.height - 2,
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
