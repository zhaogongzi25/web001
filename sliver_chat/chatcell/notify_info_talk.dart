//聊天消息

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../vo/base_info_vo.dart';
import 'base_text_link.dart';

class NotifyInfoTalk extends BaseTextLink {
  int liveNum = 0;
  Rect? _genTouRect;

  @override
  void initData() {
    String userName = BaseTextLink.getRandomUserName();
    String moneystr = "${Random().nextInt(100) + 10}元";
    textContent =
        '用户$userName：\n欢迎大家来这里玩欢迎大家来这里玩欢迎大家来这里玩在一分快三无法中，已成功下注了$moneystr ';
    links = [
      {
        'text': userName,
        'onTap': () {
          if (kDebugMode) {
            print('点中了$userName 的头像');
          }
        },
        'color': Colors.green,
      },
      {
        'text': '一分快三',
        'onTap': () {
          if (kDebugMode) {
            print('点中了。一分快三  你是否要跟$userName  学习');
          }
        },
        'color': Colors.orangeAccent,
      },
      {
        'text': moneystr,
        'onTap': () {
          if (kDebugMode) {
            print('确定是$moneystr钱的');
          }
        },
        'color': Colors.yellow,
      },
    ];
  }

  @override
  bool hitTest(BaseInfovo vo, Offset clikpos) {
    bool temp = super.hitTest(vo, clikpos);
    if (_genTouRect!.contains(clikpos)) {
      print('点中了 ${vo.skipId} 跟投');
      return true;
    }
    return temp;
  }

  @override
  void draw(BaseInfovo vo, Canvas canvas, double ty) {
    // TODO: implement draw
    super.draw(vo, canvas, ty);

    _drawUserLevel(canvas, vo, ty);

    _genTouRect = _drawEndLindRedBgPoint(canvas, vo, ty);
  }

  Rect _drawEndLindRedBgPoint(Canvas canvas, BaseInfovo vo, double ty) {
    final paint =
        Paint()
          ..color =
              Colors
                  .red // 设置颜色
          ..style = PaintingStyle.fill; // 设置绘制样式: fill (填充) 或 stroke (描边)
    final radius = Radius.circular(8);
    List<ui.LineMetrics> lineMetrics =
        vo.textLink!.textPainter!.computeLineMetrics();
    ui.LineMetrics endLineMetrics = lineMetrics[lineMetrics.length - 1];

    Rect drawRect = Rect.fromLTWH(
      vo.niceImage!.ctxPodding + endLineMetrics.left + endLineMetrics.width + 6,

      vo.niceImage!.ctxPodding + endLineMetrics.baseline - 12,
      41,
      21,
    );

    RRect rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        drawRect.left,
        (vo.rect!.top - ty) + drawRect.top,
        drawRect.width,
        drawRect.height,
      ),
      radius,
    );

    canvas.drawRRect(rect, paint);

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: '跟投',
        style: TextStyle(color: Colors.white, fontSize: 15),
      ),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: 250);

    textPainter.paint(canvas, Offset(rect.left + 5, rect.top - 2));

    return drawRect;
  }

  void _drawUserLevel(Canvas canvas, BaseInfovo vo, double ty) {
    final paint =
        Paint()
          ..color =
              Colors
                  .orange // 设置颜色
          ..style = PaintingStyle.fill; // 设置绘制样式: fill (填充) 或 stroke (描边)
    final radius = Radius.circular(8);

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        vo.niceImage!.ctxPodding,
        vo.rect!.top - ty + vo.niceImage!.ctxPodding,
        40,
        24,
      ),
      radius,
    );
    canvas.drawRRect(rect, paint);

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: '系统',
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: 250);

    textPainter.paint(canvas, Offset(rect.left + 5, rect.top));
  }
}
