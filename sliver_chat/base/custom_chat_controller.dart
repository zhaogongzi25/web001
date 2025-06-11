import 'dart:math';
import 'dart:ui' as ui;

import 'package:data_center/live_old/model/data_manager.dart';
import 'package:data_center/live_old/model/room_msg.dart';
import 'package:data_center/live_old/utility/string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_net/download_mgr.dart';

import 'model_pack.dart';
import '../chatcell/room_chat_cell_vo.dart';



class CustomcChatController {
  final Map<String, ui.Image> _imageMap = {};

  void getImageLocalorNetFun(String url, Function(ui.Image?) calBackfun) async {
    ui.Image? bImg;
    // await Future.delayed(Duration(seconds:  Random().nextInt(5)));
    if (_imageMap.containsKey(url)) {
      bImg = _imageMap[url];
    } else {
      // print('加载图片  $url');
      if (url.contains("https:") || url.contains("http:")) {
        String? localUrl = await downloadMgr.downloadLite(url);
        if (localUrl != null) {
          bImg = await _loadLocal(localUrl);
        }
      } else {
        bImg = await _loadLocal(url);
      }
    }
    if (bImg != null) {
      _imageMap.addEntries(
        <String, ui.Image>{url: bImg}.entries,
      );
    }
    calBackfun(bImg);
  }

  Future<ui.Image?> _loadLocal(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      return frameInfo.image;
    } catch (e) {
      return null;
    }
  }

  num _easeInOut(double t) {
    return t < 0.5 ? 2 * pow(t, 2) : -1 + (4 - 2 * t) * t;
  }

  List<RoomChatCellVo> data = [];
  bool dragScrollEvent = false;

  //刷新变量，用于改变让updateRenderObject能够更新到变化才会刷行ui
  int refreshNum = 0;

  //标记动画的滑动方向，是否移动到地步
  bool _animationMoveBottom = true;

  //是否显示滑到底部按钮
  final ValueNotifier<bool> scrollButtonState = ValueNotifier<bool>(false);

  //播放开始时间
  double _startTm = 0.0;

  //播放的开始位置，
  double _startMovePosition = 0.0;

  final double width;

  final AnimationController animationControl;
  final ScrollController scrollController;
  final Function refreshUi;
  final ModelPack modelPack;

  CustomcChatController({
    required this.scrollController, // 需要传入 ScrollController
    required this.animationControl, // 需要传入 AnimationController
    required this.refreshUi, // 需要传入 setState 或类似的刷新函数
    required this.modelPack, //
    required this.width, //
  }) {
    maxLen = dataMgr.getConfig(ConfigKeys.livechatnumyh_open) ?? 200;
    animationControl.addListener(() {
      // 确保 ScrollController 已经 attached 到一个 Scrollable
      if (scrollController.hasClients) {
        // 确保 ScrollController 已经知道了内容尺寸 (即 ListView 已经渲染)
        if (scrollController.position.hasContentDimensions) {
          // 获取 ListView 的最大可滚动范围 (底部位置)
          double moveToPos = 0;
          double maxScrollExtent = scrollController.position.maxScrollExtent;
          if (_animationMoveBottom) {
            moveToPos = maxScrollExtent;
            _startMovePosition = min(
              _startMovePosition,
              moveToPos,
            ); //起始位置不能大于底部位置
          }

          double tm = (animationControl.value - _startTm) / (1.0 - _startTm);
          // 如果计算出的相对进度 >= 0 (避免 startTm = 1.0 导致问题)
          if (tm >= 0) {
            // 计算从开始位置到最大滚动范围的总距离
            double lenH = moveToPos - _startMovePosition;
            // 使用缓动函数计算当前应该滚动到的目标位置
            double toY = (lenH) * _easeInOut(tm) + _startMovePosition;
            // 将 ListView 滚动到计算出的位置 (非动画滚动，由 AnimationController 驱动)
            scrollController.jumpTo(toY);
            // print(toY);
          }
        }
      }
    });
    animationControl.reset();
    animationControl.forward(from: 0);
  }


  void dispose() {
    data.clear();
    animationControl.dispose();
    scrollController.dispose();
  }

  //总列表的高度，因为记录中都有进行了逐条排序，只需要最后一个的位置和高度就得到总长度，不需要逐个相加，
  double getTotalHeight() {
    double h = 0.0;
    for (RoomChatCellVo temp in data) {
      h += temp.rect.height;
    }
    return h;
  }

  void pushRoomMsg(RoomMsg roomMsg) {
    RoomChatCellVo addVo = RoomChatCellVo(
      chatController: this,
      roomMsg: roomMsg,
      modelPack: modelPack,
      width: width,
    );
    _clearOldData();
    data.add(addVo);
    resetListPosAll();
  }

  //刷新重新统计高度叠加
  int _startTotalIdx = 0;

  void resetListPosAll() {
    int beginIdx = -1;
    double baseTop = 0.0;
    //取到开始要重新遍历的位置，便重新遍历就不必要多次重置
    if (_startTotalIdx > 0 && _startTotalIdx < data.length) {
      RoomChatCellVo beGinVo = data[_startTotalIdx - 1];
      if (beGinVo.rect.height != 0) {
        baseTop = beGinVo.rect.top + beGinVo.rect.height; //起始位置为上一个的位置加上一个位置的高度得到开始的位置
      } else {
        _startTotalIdx = 0;
      }
    }
    //其实应该是自行遍历全部，以下逻辑是为了如果以有高度的内容之前的就不再相加，在大数据之后可以减少运算
    //简单的逻辑就是对所有的位置从上到下进行一次遍历，考虑到大量数据的时间记录之前的计算好的位置就不必要重复再相加
    for (int i = _startTotalIdx; i < data.length; i++) {
      RoomChatCellVo vo = data[i];
      vo.rect = Rect.fromLTWH(0.0, baseTop, vo.rect.width, vo.rect.height);
      baseTop += vo.rect.height;
      if (vo.rect.height == 0) {
        if (beginIdx == -1) {
          beginIdx = max(i, 0);
        }
      }
    }
    // print('重新计算高度。 开始 $_startTotalIdx   没好的beginIdx $beginIdx       数量 $num    还有$noRight 没好');
    if (beginIdx == -1) {
      _startTotalIdx = max(data.length - 1, 0);
    } else {
      _startTotalIdx = max(beginIdx - 1, 0);
    }

    if (!animationControl.isAnimating && !scrollButtonState.value) {
      dragScrollEvent = false; //需要将手势状态归零，因为当前的是在底部
      moveBottom();
    }

    refreshUi();
  }

  //清理超出的数量，删除前部分， 当超过1000记录删除前面100条
  static int maxLen = 10000;

  void _clearOldData() {
    int killNum = min(1000, (maxLen / 10).toInt());
    if (data.length >= maxLen) {
      _startTotalIdx = 0;
      double killHeight = 0;
      while (data.length > maxLen - killNum) {
        killHeight += data[0].rect.height;
        data.removeAt(0);
      }
      //有删除记录那我们将重置所有显示记录的位置，因为删除前部分数据所有位置前移
      //计算所有对象当前的位置和对应的高度，这里需要优化，不是每一个都是要全刷新，可以优化
      resetListPosAll();
      if (scrollController.hasClients) {
        if (scrollController.position.hasContentDimensions) {
          _startMovePosition = scrollController.position.pixels - killHeight;
          scrollController.jumpTo(max(_startMovePosition, 0));
        }
      }
    }
  }

  //移到到底部，
  void moveBottom({double? time}) {
    _animationMoveBottom = true;
    _starAnimation(time: time ?? 0.25); //默认滑动时间为0.25秒
  }

  //设定动画的播放时间，用于驱动列表的位置，
  void _starAnimation({required double time}) {
    // 设置动画开始的进度值，并限制在 0.0 到 1.0 之间
    if (scrollController.hasClients) {
      if (time > 1.0 || time <= 0) {
        if (kDebugMode) {
          print("time = $time   滚动时间约束在   （0.0-1.0）秒内   ");
        }
      }
      _startTm = 1.0 - time;
      _startTm = min(max(_startTm, 0.0), 1.0);
      // 记录当前滚动位置作为动画的起始位置
      if (scrollController.position.hasPixels) {
        _startMovePosition = scrollController.position.pixels;
      } else {
        // 如果还没有像素，说明列表还没渲染，起始位置为 0
        _startMovePosition = 0.0;
      }
      animationControl.forward(from: _startTm);
    }
  }
}
