// --- 使用 CustomColorBlocks 在 CustomScrollView 中 ---
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

import 'custom_cavas_widget.dart';
import 'custom_chat_controller.dart';


class CustomChatView extends StatefulWidget {
  final void Function(CustomcChatController) onCreated;
  const CustomChatView({super.key, required this.onCreated});

  @override
  // ignore: library_private_types_in_public_api
  _CustomChatViewState createState() =>
      _CustomChatViewState();
}

class _CustomChatViewState
    extends State<CustomChatView>
    with SingleTickerProviderStateMixin {
  CustomcChatController? _controller;

  @override
  void initState() {
    super.initState();

    _controller = CustomcChatController(
      refreshUi: refrishListView,
      scrollController: ScrollController(),
      animationControl: AnimationController(
        // 创建动画控制器用于滚动到底部
        vsync: this, // 提供 Ticker
        duration: Duration(milliseconds: 1000), // 设置动画总时长为 1 秒
      ),
    );

    widget.onCreated(_controller!);
  }

  void refrishListView() {
    // 调用 setState 触发 State 的重建，从而更新 ListView 显示新增的聊天记录
    if (mounted) {
      // setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return _listRender();
  }

  Widget _listRender() {

    return CustomScrollView(
      controller: _controller!.scrollController,
      slivers: <Widget>[
        CustomCavasWidget(
          data: _controller!.data,
          refreshNum: _controller!.refreshNum,
          blockExtent: _controller!.getTotalHeight(), // 每个方块高150
        ),
      ],
    );
  }
}
