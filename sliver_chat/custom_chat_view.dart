import 'package:common_base/common_base.dart';
import 'package:custom_image/custom_image.dart';
import 'package:data_center/live_old/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:live/page/home/room/sliver_chat/custom_chat_render_sliver.dart';

import 'custom_cavas_widget.dart';
import 'custom_chat_controller.dart';

//显示聊天室窗口 回调控制器
class CustomChatView extends StatefulWidget {
  final void Function(CustomcChatController) onCreated;

  const CustomChatView({super.key, required this.onCreated});

  @override
  _CustomChatViewState createState() => _CustomChatViewState();
}

class _CustomChatViewState extends State<CustomChatView> with SingleTickerProviderStateMixin {
  CustomcChatController? _controller;

  Widget? _chatScrollButton;

  @override
  void initState() {
    super.initState();

    print('CustomChatView  initState');

    _controller = CustomcChatController(
      refreshUi: refreshListView,
      scrollController: ScrollController(),
      animationControl: AnimationController(
        vsync: this, // 提供 Ticker
        duration: Duration(milliseconds: 1000), //这里设置1秒是以后所有需要播放动画可以在这个范围内，参数在移动到底部可选0-1秒来确定滑动时间
      ),
    );
    // _controller!.scrollController.addListener(_onScroll);
    widget.onCreated(_controller!);
  }

  Widget _madkScrollButton() {
    if (_chatScrollButton == null) {
      _chatScrollButton = Container(
        margin: EdgeInsets.only(left: 25.w, bottom: 5.w),
        padding: EdgeInsets.only(left: 15.w, right: 20.w, top: 5.w, bottom: 5.w),
        decoration: new BoxDecoration(
          color: Color(0xEAFFFFFF), // 边色与边宽度
          shape: BoxShape.rectangle, // 默认值也是矩形
          borderRadius: new BorderRadius.circular((20.0)), // 圆角度
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            createImage("assets/common/arrow_gray_down.png", width: 20.w, height: 20.w),
            SizedBox(
              width: 5.w,
            ),
            Text(
              S.current.l_id_10003,
              style: TextStyle(color: Color(0xFF888888), fontSize: 26.sp),
            ),
          ],
        ),
      );
    }
    return _chatScrollButton!;
  }

  //当数据变化时来判断是否需要刷新ui
  void refreshListView() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_controller!.dragScrollEvent) {
      double currentOffset = _controller!.scrollController.offset;
      double maxScrollExtent = _controller!.scrollController.position.maxScrollExtent;
      if (maxScrollExtent > CustomChatRenderSliver.num001) {
        _controller!.scrollButtonState.value = !(maxScrollExtent <= currentOffset);
      }
    }
    if (notification is UserScrollNotification) {
      _controller!.dragScrollEvent = true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
            // 监听 ScrollNotification
            onNotification: _handleScrollNotification, // 注册回调函数
            child: _maskWidget()),
        ValueListenableBuilder<bool>(
          valueListenable: _controller!.scrollButtonState,
          builder: (context, value, child) {
            if (_controller!.scrollButtonState.value) {
              return Positioned(
                  bottom: 5.w,
                  child: InkWell(
                    onTap: () {
                      _controller!.dragScrollEvent = false;
                      _controller!.scrollButtonState.value = false;
                      _controller!.moveBottom();
                    },
                    child: _madkScrollButton(),
                  ));
            } else {
              return SizedBox(width: 1, height: 1);
            }
          },
        ),
        Positioned(
          right: 0,
            child: Text(
          '${_controller!.data.length}/${CustomcChatController.maxLen}',
          style: TextStyle(color: Colors.white, fontSize: 24.sp, height: 2.5.w, fontWeight: FontWeight.w400),
        ))
      ],
    );
  }

  Map<Rect, Shader> shaderCache = {};

  Shader _getOrCreateShader(Rect bounds) {
    return shaderCache.putIfAbsent(
        bounds,
        () => LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xff000000), Color(0x00000000), Colors.transparent],
              stops: [0, .1, .11],
            ).createShader(bounds));
  }

  //上部分渐变效果，原chat复制过来
  Widget _maskWidget() {
    return ShaderMask(
        // key: UniqueKey(),
        shaderCallback: (Rect bounds) {
          Shader shader = _getOrCreateShader(bounds);
          return shader;
        },
        blendMode: BlendMode.dstOut,
        child: _listRender());
  }

  Widget _listRender() {
    return CustomScrollView(
      controller: _controller!.scrollController,
      slivers: <Widget>[
        CustomCavasWidget(
          data: _controller!.data,
          refreshNum: _controller!.refreshNum,
          totalExtent: _controller!.getTotalHeight(), // 每个方块高150
        ),
      ],
    );
  }
}
