//聊天消息

import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../vo/base_info_vo.dart';
import 'base_text_link.dart';
import '../vo/base_titlle.dart';

//基本聊天框
class ChatTextTalk extends BaseTextLink {
  // BaseTittle? _baseTittle;
  //随机聊天内容用于生存聊天文本内容
  final String _randomBaseStr =
      '你好这是一条测试消息消息的真实性还是需要下步一步确定先不给特定长度[按钮]消息消息消息消[特赦内容]不应该只是显示这些内容[按钮]表示最后显示的可能性试消息[特 示这些内容[按钮]表示最后显示的可能性 ';

  @override
  void initData() {
    baseStyle =   baseStyle.copyWith(
      color: Colors.white,
        wordSpacing: 10.0,
        // fontSize: Random().nextDouble() * 10.0 + 12.0,
        // fontSize:18,
    );


    maxWidth = Random().nextInt(50) + 220;
    _makeHandTittle();
    _makeHandTittle();
    String userName = BaseTextLink.getRandomUserName();
    textContent = '$userName：${_randomTalkTxtStr()}';

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
    ];
    try {
      if (textContent != null) {

        int st = Random().nextInt(textContent!.length - 10);
        if (st > 1 &&
            textContent!.length > st + 8 + 2 &&
            Random().nextInt((textContent!.length / 5).toInt()) != 0) {
          String str = textContent!.substring(st, st + 8);
          links?.add({
            'text': str,
            'onTap': () {
              if (kDebugMode) {
                print('点中了  $str  ');
              }
            },
            'color': Colors.red,
          });
        }
      }
    } catch (evt) {}
  }

  void _makeHandTittle() {
    if (Random().nextBool()) {
      addHeadImageArr(
        BaseTittle(
          titleLen: 5,
          url: 'https://zhaogongzi25.github.io/web001/room_vip_btn.png',
          fontSize: baseStyle.fontSize!,
          roundBox: Rect.fromLTRB(0, 0, 0, 5),
        ),
      );
    }
    if (Random().nextBool()) {
      addHeadImageArr(
        BaseTittle(
          titleLen: 3,
          url: 'https://zhaogongzi25.github.io/web001/room_pay_bg.png',
          fontSize: baseStyle.fontSize!,
          roundBox: Rect.fromLTRB(-2, -2, -2, 4),
          label: "${Random().nextInt(200)}级",
        ),
      );
    }
  }

  @override
  bool hitTest(BaseInfovo vo, Offset pointInTextLayout) {
    bool temp = super.hitTest(vo, pointInTextLayout);
    return temp;
  }

  String _randomTalkTxtStr() {
    try {
      int ts = Random().nextInt(_randomBaseStr.length - 1);
      int es = ts + Random().nextInt(_randomBaseStr.length - 2 - ts) + 2;
      String str = _randomBaseStr.substring(ts, es);

      return str;
    } catch (e) {
      // 捕获异常并处理
      if (kDebugMode) {
        print('捕获到异常: $e');
      }
      return '捕获到异常';
    }
  }
}
