import 'package:common_base/common_base.dart';
import 'package:data_center/utils/sliver_chat/base/custom_text_link_region.dart';

import 'package:flutter/material.dart';

import '../../../live_old/utility/colors.dart';
import '../chatcell/room_chat_cell_vo.dart';
import '../icon/end_base_icon.dart';
import '../icon/free_base_icon.dart';
import '../icon/head_base_icon.dart';

//基本文本包含富文本点击的文本对象，描述文本显示内容，和点击事件的内容
class CustomBaseTextLink {
  //基础文本最大宽度
  //多行文本和单行的高度偏移。如多行我们会让记录网往小一点显示，
  double multipleLinesH = 0.w;
  double fontBaseLeft = 0.w;

  //存放头部标签一般一个，也有可能会多个，
  final List<HeadBaseIcon> _headImageArr = [];

  //存放尾部标签一般一个，也有可能会多个，
  final List<EndBaseIcon> _endImageArr = [];

  final List<FreeBaseIcon> _freeImage = [];

  //标记是否显示
  // bool hide = true;

  //链接对象
  List<CustomTextLinkRegion>? linkRegions;

  //文本Painter
  TextPainter? textPainter;

  //最终显示文本内容是包含了链接信息的内容
  // String? _textContent;




  //文本行数列表，layout后才能有数据
  List<LineMetrics>? contentLines;

  //链接内容
  List<Map<String, dynamic>> textLinks = [];


  final double maxWidth;
  final RoomChatCellVo roomChatCellVo;
  TextStyle? baseStyle;

  CustomBaseTextLink({required TextStyle textStyle, required this.roomChatCellVo, required this.maxWidth}) {
    baseStyle = textStyle;
    initData();
  }
  void initData() {

  }
  //添加头部对象，会和文本空格结合
  void addIconTittleToHead(HeadBaseIcon baseTittle) {
    _headImageArr.add(baseTittle);
  }
  //添加尾部对象，会和文本空格结合
  void addEndImageArr(EndBaseIcon baseTittle) {
    _endImageArr.add(baseTittle);
  }

  //添加尾部对象，会和文本空格结合
  void addFreeImageArr(FreeBaseIcon baseTittle) {
    _freeImage.add(baseTittle);
  }

  //获得头部共有的Icon图标占用的文本宽度，用于显示文本缩进位置
  double _getHeadTitleFontLen() {
    double len = 0;
    for (HeadBaseIcon baseTittle in _headImageArr) {
      len += baseTittle.iconLen;
    }
    return len;
  }
  //获取头部的空格文本
  String _getHeadEmptyStr() {
    String addStr = '';
    double len = _getHeadTitleFontLen();
    for (int i = 0; i < len.floor(); i++) {
      addStr += RoomChatCellVo.sampleSpace;
    }
    return addStr;
  }
  //点击测试
  bool hitTest(RoomChatCellVo vo, Offset clikpos) {
    final Offset pointInTextLayout = Offset(
      clikpos.dx - vo.ctxPodding.left, // corresponds to dx
      clikpos.dy - vo.ctxPodding.top - multipleLinesH / 2.0, // corresponds to dy
    );
    final TextPosition textPosition = vo.textLink!.textPainter!.getPositionForOffset(pointInTextLayout);
    final int clickedCharacterIndex = textPosition.offset;
    CustomTextLinkRegion? clickedLink;
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
        return true;
      }
    }
    for (EndBaseIcon endBaseIcon in _endImageArr) {
      endBaseIcon.hitTest(vo, clikpos);
    }
    return false;
  }
  //修改文本内容，需要重置组件尺寸
  void setTextContentToRander(String value){

    _buildToPainter(value, textLinks);
    //重制对象的尺寸
    roomChatCellVo.resetSize();

  }
  //将文本排列
  void _buildToPainter(String str, List<Map<String, dynamic>> arr) {
    //通过空格的数量来确定文本显示的缩进 ，也预留出来用于显示头部标签
    String addStr = _getHeadEmptyStr();
    String text = addStr + str;
    List<Map<String, dynamic>> linkArr = arr;
    final spanAndRegionData = buildSpansAndRegions(
      fullText: text,
      baseStyle: baseStyle!,
      linkDefinitions: linkArr,
    );
    List<InlineSpan> textSpans = spanAndRegionData.item1;
    linkRegions = spanAndRegionData.item2;
    textPainter = TextPainter(
      text: TextSpan(children: textSpans),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: maxWidth);
    contentLines = textPainter?.computeLineMetrics();
    multipleLinesH = contentLines!.length > 1 ? -2.w : 0.w;
  }
  void draw(RoomChatCellVo vo, Canvas canvas, double ty) {
    _drawBaseTextLink(canvas, vo, ty);
    //绘制开头的icon列表，因第个独立，它们并不知到排列顺序，需要逐个计算起始位置
    double startLeft = 0.0;
    //绘制前排图标，并需要累加排列直接多个
    for (HeadBaseIcon baseTittle in _headImageArr) {
      baseTittle.startLeft = startLeft;
      baseTittle.draw(canvas, vo, ty);
      startLeft += baseTittle.getWidth();
    }
    double endLeft = 0.0;
    //行尾接图片，支持多个，
    for (EndBaseIcon endBaseIcon in _endImageArr) {
      endBaseIcon.startLeft = endLeft;
      endBaseIcon.draw(canvas, vo, ty);
    }
    //显示自由排列图标
    for (FreeBaseIcon freeBaseIcon in _freeImage) {
      freeBaseIcon.draw(canvas, vo, ty);
    }
  }

  //绘制文本信息
  void _drawBaseTextLink(Canvas canvas, RoomChatCellVo vo, double ty) {
    if (textPainter != null) {
      textPainter!.paint(
        canvas,
        Offset(
          vo.ctxPodding.left + fontBaseLeft,
          vo.ctxPodding.top + vo.rect.top - ty + multipleLinesH / 2.0,
        ),
      );
    }
  }

  //获取文本的高宽度
  Offset getDrawRect() {
    return Offset(
      textPainter!.width + fontBaseLeft,
      textPainter!.height + multipleLinesH,
    );
  }
}
