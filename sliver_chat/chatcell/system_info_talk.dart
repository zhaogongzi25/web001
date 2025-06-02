//聊天消息

import 'dart:math';

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../vo/base_info_vo.dart';
import 'base_text_link.dart';

class SystemInfoTalk extends BaseTextLink {
  @override
  void initData() {

    textContent =
        '通知今天是我12:00开始服务器重启，可能会中断时间在15分钟，给大家造成困扰，深表歉意[查看通知] 还有更多内容等着大家去找到真内容';
    links = [
      {
        'text': '[查看通知]',
        'onTap': () {
          if (kDebugMode) {
            print('点中了查看通知');
          }
        },
        'color': Colors.green,
      },
    ];
  }

  @override
  void draw(BaseInfovo vo, Canvas canvas, double ty) {
    super.draw(vo, canvas, ty);
    _drawUserLevel(canvas, vo, ty);
  }

  void _drawUserLevel(Canvas canvas, BaseInfovo vo, double ty) {
    final paint =
        Paint()
          ..color =
              Colors
                  .redAccent // 设置颜色
          ..style = PaintingStyle.fill; // 设置绘制样式: fill (填充) 或 stroke (描边)
    final radius = Radius.circular(8);

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        vo.niceImage!.ctxPodding,
        vo.rect!.top - ty + vo.niceImage!.ctxPodding,
        70,
        24,
      ),
      radius,
    );
    canvas.drawRRect(rect, paint);

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: '系统通知',
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: 70);
    textPainter.paint(canvas, Offset(rect.left + 5, rect.top));
  }
}
