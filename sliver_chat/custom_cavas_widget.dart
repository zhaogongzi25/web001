// --- 4. 定义一个 Widget 来创建和配置 RenderCustomColorBlocks ---

import 'package:flutter/cupertino.dart';

import 'custom_chat_render_sliver.dart';
import 'chatcell/room_chat_cell_vo.dart';

class CustomCavasWidget extends SingleChildRenderObjectWidget {
  // 构造函数：接收用于配置 RenderSliver 的属性
  const CustomCavasWidget({
    Key? key,
    required this.totalExtent, // Sliver 的逻辑总高度（内容高度），用于 scrollExtent
    required this.refreshNum, // 一个刷新标记，当数据变化时更新此值可以触发 RenderSliver 的重绘/布局
    required this.data, // 要在 Sliver 中渲染的数据列表
  }) : super(key: key); // 调用父类构造函数

  // 定义接收并存储配置属性的 final 字段
  final List<RoomChatCellVo> data;
  final double totalExtent;
  final int refreshNum;


  @override
  CustomChatRenderSliver createRenderObject(BuildContext context) {
    // 创建并返回我们的自定义 RenderSliver
    return CustomChatRenderSliver(
      totalExtent: totalExtent, // 传递总内容高度
      refrishnum: refreshNum,   // 传递刷新标记
      data: data,               // 传递数据列表
    );
  }


  @override
  void updateRenderObject(
      BuildContext context,
      CustomChatRenderSliver renderObject, // 现有的 RenderObject 实例
      ) {
    // 检查 blockExtent 是否改变，如果改变了，更新 RenderObject 的属性 这是列表总长度，用于显示滑动总长
    if (renderObject.totalExtent != totalExtent) {
      renderObject.totalExtent = totalExtent;
    }
    //当一定要刷新绘制，现在主要是处理，当列表长度忆变化，绘制也结束后，新加载的图片才准备好，我们就需要再次进行绘制，
    if (renderObject.refreshNum != refreshNum) {
      renderObject.refreshNum = refreshNum;

    }

  }

}
