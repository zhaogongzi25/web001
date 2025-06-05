
import 'package:common_base/common_base.dart';

import 'package:flutter/material.dart';
import 'package:live/page/home/room/sliver_chat/view/text_link_region.dart';

import '../chatcell/room_chat_cell_vo.dart';
import 'end_base_icon.dart';
import 'head_base_icon.dart';

//基本文本包含富文本点击的文本对象，描述文本显示内容，和点击事件的内容
class BaseTextLink {
  // String headstr = '';
  // int headLen = 0;

  //基础文本最大宽度
  double maxWidth = 550.w;


  //多行文本和单行的高度偏移。如多行我们会让记录网往小一点显示，
  double multipleLinesH = 0.0;

  //存放头部标签一般一个，也有可能会多个，
  List<HeadBaseIcon> _headImageArr = [];

  //存放尾部标签一般一个，也有可能会多个，
  List<EndBaseIcon> _endImageArr = [];

  //标记是否显示
  // bool hide = true;

  //链接对象
  List<TextLinkRegion>? linkRegions;

  //文本Painter
  TextPainter? textPainter;

  //文本内容
  String? textContent;

  //链接内容
  List<Map<String, dynamic>> links=[];

  //文本行数列表，layout后才能有数据
  List<LineMetrics>? lines;



  final TextStyle baseStyle;

  BaseTextLink({required this.baseStyle}) {
    initData();
    _buildToPainter(textContent!, links);
  }

  void initData() {
    textContent = '测试文本';

  }

  //添加头部对象，会和文本空格结合
  void addIconTittleToHead(HeadBaseIcon baseTittle) {
    _headImageArr.add(baseTittle);
  }

  //添加尾部对象，会和文本空格结合
  void addEndImageArr(EndBaseIcon baseTittle) {
    _endImageArr.add(baseTittle);
  }

  //获得头部共有的Icon图标占用的文本宽度，用于显示文本缩进位置
  int _getHeadTitleFontLen() {
    int len = 0;
    for (HeadBaseIcon baseTittle in _headImageArr) {
      len += baseTittle.titleLen;
    }
    return len;
  }

  //获取头部的空格文本
  String _getHeadEmptyStr() {
    String addStr = '';
    for (int i = 0; i < _getHeadTitleFontLen(); i++) {
      addStr += '\u2003';
    }
    return addStr;
  }

  //点击测试
  bool hitTest(RoomChatCellVo vo, Offset clikpos) {


    final Offset pointInTextLayout = Offset(
      clikpos.dx - vo.ctxPodding.left, // corresponds to dx
      clikpos.dy - vo.ctxPodding.top - multipleLinesH / 2.0, // corresponds to dy
    );
    final TextPosition textPosition =
        vo.textLink!.textPainter!.getPositionForOffset(pointInTextLayout);
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
      if (clickedLink.onTap != null) {
        clickedLink.onTap?.call();
      }
    }
    for (EndBaseIcon endBaseIcon in _endImageArr){
      endBaseIcon.hitTest(vo, clikpos);
    }
    return true;
  }

  void _buildToPainter(String str, List<Map<String, dynamic>> arr) {
    //通过空格的数量来确定文本显示的缩进 ，也预留出来用于显示头部标签
    String addStr = _getHeadEmptyStr();
    String text = addStr + str;
    List<Map<String, dynamic>> linkArr = arr;
    final spanAndRegionData = buildSpansAndRegions(
      fullText: text,
      baseStyle: baseStyle,
      linkDefinitions: linkArr,
    );
    List<InlineSpan> textSpans = spanAndRegionData.item1;
    linkRegions = spanAndRegionData.item2;
    try {
      textPainter = TextPainter(
        text: TextSpan(children: textSpans),
        textDirection: TextDirection.ltr,
      )..layout(minWidth: 0, maxWidth: maxWidth);

      lines = textPainter?.computeLineMetrics();
      multipleLinesH = lines!.length > 1 ? -2.w : 0.w;
    } catch (e) {

      print('不应该到这  BaseTextLink');
    } finally {

    }

  }

  void draw(RoomChatCellVo vo, Canvas canvas, double ty) {
    _drawBaseTextLink(canvas, vo, ty);

    //绘制开头的icon列表，因第个独立，它们并不知到排列顺序，需要逐个计算起始位置
    double startLeft = 0.0;
    for (HeadBaseIcon baseTittle in _headImageArr) {
      baseTittle.startLeft = startLeft;
      baseTittle.draw(canvas, vo, ty);
      startLeft += baseTittle.getWidth();
    }
    startLeft = 0.0;
    for (EndBaseIcon endBaseIcon in _endImageArr) {
      endBaseIcon.startLeft = startLeft;
      endBaseIcon.draw(canvas, vo, ty);

    }
  }
  //绘制文本信息
  void _drawBaseTextLink(Canvas canvas, RoomChatCellVo vo, double ty) {
    vo.textLink!.textPainter!.paint(
      canvas,
      Offset(
        vo.ctxPodding.left,
        vo.ctxPodding.top + vo.rect!.top - ty + multipleLinesH / 2.0,
      ),
    );
  }
}
