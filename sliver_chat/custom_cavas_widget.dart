
// --- 4. 定义一个 Widget 来创建和配置 RenderCustomColorBlocks ---
import 'package:flutter/cupertino.dart';

import 'custom_chat_render_sliver.dart';
import 'vo/base_info_vo.dart';

class CustomCavasWidget extends SingleChildRenderObjectWidget {
  const CustomCavasWidget({
    Key? key,
    required this.blockExtent,
    required this.refreshNum,
    required this.data,
  }) : super(key: key);

  final List<BaseInfoVo> data;
  final double blockExtent;
  final int refreshNum;
  @override
  CustomChatRenderSliver createRenderObject(BuildContext context) {
    return CustomChatRenderSliver(
      blockExtent: blockExtent,
      refrishnum: refreshNum,
      data: data,
    );
  }
  @override
  void updateRenderObject(
      BuildContext context,
      CustomChatRenderSliver renderObject,
      ) {
    if (renderObject.blockExtent != blockExtent) {
      renderObject.blockExtent = blockExtent;
    }
    if (renderObject.refreshNum != refreshNum) {
      renderObject.refreshNum = refreshNum;
    }

  }
}
