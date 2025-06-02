import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:live/page/home/room/sliver_chat/chatcell/text_link_region.dart';

import '../vo/base_info_vo.dart';
import '../vo/base_titlle.dart';

class BaseTextLink {
  // String headstr = '';
  // int headLen = 0;

  //基础文本最大宽度
  double maxWidth = 250.0;

  //存放头部标签一般一个，也有可能会多个，
  List<BaseTittle> _headImageArr = [];

  //存放头部标签一般一个，也有可能会多个，
  List<BaseTittle> _endImageArr = [];

bool hide=true;

  //链接对象
  List<TextLinkRegion>? linkRegions;

  //文本
  TextPainter? textPainter;

  //文本内容
  String? textContent;

  //链接内容
  List<Map<String, dynamic>>? links;

  //基础文本颜色，
  TextStyle baseStyle = TextStyle(color: Colors.white, fontSize: 14.0,  wordSpacing: 0.0  );

  BaseTextLink() {
    initData();
    _buildToPainter(textContent!, links!);
  }

  void initData() {
    textContent =
        '第一个链接这是一段包含  ';
    links = [
    
    ];
  }

  //添加头部对象，会和文本空格结合
  void addHeadImageArr(BaseTittle baseTittle) {
    _headImageArr.add(baseTittle);
  }

  //添加头部对象，会和文本空格结合
  void addEndImageArr(BaseTittle baseTittle) {
    _endImageArr.add(baseTittle);
  }


  int getHeadTitleFontLen() {
    int len = 0;
    for (BaseTittle baseTittle in _headImageArr) {
      len += baseTittle.titleLen;
    }
    return len;
  }

  //获取头部的空格文本
  String getHeadEmptyStr() {
    String addStr = '';
    for (int i = 0; i < getHeadTitleFontLen(); i++) {
      addStr += '\u2003';
    }
    return addStr;
  }

  //点击测试
  bool hitTest(BaseInfovo vo, Offset clikpos) {
    final Offset pointInTextLayout = Offset(
      clikpos.dx - vo.niceImage!.ctxPodding, // corresponds to dx
      clikpos.dy - vo.niceImage!.ctxPodding, // corresponds to dy
    );
    final TextPosition textPosition = vo.textLink!.textPainter!
        .getPositionForOffset(pointInTextLayout);
    final int clickedCharacterIndex = textPosition.offset;
    TextLinkRegion? clickedLink;
    for (final linkRegion in vo.textLink!.linkRegions!) {
      if (clickedCharacterIndex >= linkRegion.startCharacterIndex &&
          clickedCharacterIndex < linkRegion.endCharacterIndex) {
        clickedLink = linkRegion;
        break; // Found the link
      }
    }
    if (clickedLink != null) {
      if (clickedLink.onTap == null) {
        if (kDebugMode) {
          print('点击中cell id ${vo.skipId}    click  : ${clickedLink.linkData}');
        }
      } else {
        if (kDebugMode) {
          print('点击中cell id ${vo.skipId}   ');
        }
        clickedLink.onTap?.call();
      }
    }
    return true;
  }

  void _buildToPainter(String str, List<Map<String, dynamic>> arr) {
    //通过空格的数量来确定文本显示的缩进 ，也预留出来用于显示头部标签
    String addStr = getHeadEmptyStr();
    String text = addStr + str;
    List<Map<String, dynamic>> linkarr = arr;
    final spanAndRegionData = buildSpansAndRegions(
      fullText: text,
      baseStyle: baseStyle,
      linkDefinitions: linkarr,
    );
    List<InlineSpan> textSpans = spanAndRegionData.item1;
    linkRegions = spanAndRegionData.item2;
    textPainter = TextPainter(
      text: TextSpan(children: textSpans),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: maxWidth);
  }

  void draw(BaseInfovo vo, Canvas canvas, double ty) {
    _drawBaseTextLink(canvas, vo, ty);
    double statIndex = 0.0;
    for (BaseTittle baseTittle in _headImageArr) {
      baseTittle.startLeft = statIndex;
      baseTittle.draw(canvas, vo, ty);
      statIndex += baseTittle.getWidth();
    }
  }

  void _drawBaseTextLink(Canvas canvas, BaseInfovo vo, double ty) {
    vo.textLink!.textPainter!.paint(
      canvas,
      Offset(
        vo.niceImage!.ctxPodding,
        vo.niceImage!.ctxPodding + vo.rect!.top - ty,
      ),
    );
  }

  static String getRandomUserName() {
    List<String> items = [
      '张三',
      '李四',
      '王五',
      '小甜甜',
      '姐妹双飞',
      '泡椒娃娃',
      '风华美人',
      '沪上阿姨',
      '天上人间',
    ];
    Random random = Random();
    int randomIndex = random.nextInt(items.length); // 范围是 [0, items.length)
    return items[randomIndex];
  }

}
