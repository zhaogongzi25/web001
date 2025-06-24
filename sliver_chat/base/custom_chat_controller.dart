import 'dart:async';
import 'dart:io';
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
  void getImageLocalOrNetFun(String url, Function(ui.Image?, bool?) calBackFun) {
    if (url.contains("https:") || url.contains("http:")) {
      getImageByMd5netImage(url, calBackFun);
    } else {
      _getUiImageFromAsset(url, calBackFun);
    }
  }
  void getImageByMd5netImage(String netUrl,Function(ui.Image?, bool?) calBackFun) async{

    String? imagePath = await downloadMgr.downloadLite(netUrl);
    if (imagePath != null) {

      final ImageProvider provider =FileImage(File(imagePath));
      // 2. 获取 ImageConfiguration
      // 如果没有提供 context 或 configuration，使用默认配置
      final ImageConfiguration config = ImageConfiguration(); // 使用默认配置，可能没有正确的 scale
      // 3. 解析 ImageProvider，获取 ImageStream
      final ImageStream stream = provider.resolve(config);
      // 使用 Compl_getUiImageFromAsseteter 来管理 future 的完成

      // 4. 添加监听器到 ImageStream
      // ImageStreamListener 的 onImage 回调会在图片加载并解码完成后触发
      ImageStreamListener? listener; // Use late final for listener reference
      listener = ImageStreamListener(
            (ImageInfo imageInfo, bool synchronousCall) {
          // 图片成功加载！imageInfo 包含 ui.Image 对象
          // 移除监听器以防止内存泄漏（很重要！）
          stream.removeListener(listener!);
          // 完成 future

          calBackFun(imageInfo.image, false);
        },
        onError: (Object exception, StackTrace? stackTrace) {
          // 图片加载或解码失败
          stream.removeListener(listener!);
          // 完成 future 并抛出错误

          print('Error loading image: $exception');
        },
      );
      // 开始监听
      stream.addListener(listener);

    }
  }
  //跳过imageCache
  void getImageLocalOrNetFunNoCache(String url, Function(ui.Image?, bool?) calBackFun) async {
    if (url.contains("https:") || url.contains("http:")) {
      ui.Image? bImg = await _loadNetimage(url);
      calBackFun(bImg, true);
    } else {
      ui.Image? bImg = await _loadLocalImage(url);
      calBackFun(bImg, true);
    }
  }

  void _getUiImageFromAsset(String assetPath, Function(ui.Image?, bool?) calBackFun) async {
    // 1. 创建 AssetImage
    final ImageProvider provider = AssetImage(assetPath);
    // 2. 获取 ImageConfiguration
    // 如果没有提供 context 或 configuration，使用默认配置
    final ImageConfiguration config = ImageConfiguration(); // 使用默认配置，可能没有正确的 scale
    // 3. 解析 ImageProvider，获取 ImageStream
    final ImageStream stream = provider.resolve(config);
    // 使用 Completer 来管理 future 的完成

    // 4. 添加监听器到 ImageStream
    // ImageStreamListener 的 onImage 回调会在图片加载并解码完成后触发
        ImageStreamListener? listener; // Use late final for listener reference
      listener = ImageStreamListener(
      (ImageInfo imageInfo, bool synchronousCall) {
        // 图片成功加载！imageInfo 包含 ui.Image 对象
        // 移除监听器以防止内存泄漏（很重要！）
        stream.removeListener(listener!);
        // 完成 future

        calBackFun(imageInfo.image, false);
      },
      onError: (Object exception, StackTrace? stackTrace) {
        // 图片加载或解码失败
        stream.removeListener(listener!);
        // 完成 future 并抛出错误

        print('Error loading image: $exception');
      },
    );
    // 开始监听
    stream.addListener(listener);
    // 5. Stream might complete immediately if image is in cache
    // Await the completer's future
    // If the image was already available in the cache (synchronousCall is true),
    // The listener might have already completed the completer before addListener returns.
    // Await ensures we wait for the result regardless.
  }

  //加载网上图片
  Future<ui.Image?> _loadNetimage(String netUrl) async {
    try {
      String? imagePath = await downloadMgr.downloadLite(netUrl);
      if (imagePath != null) {
        File imageFile = File(imagePath);
        if (await imageFile.exists()) {
          final Uint8List bytes = await imageFile.readAsBytes();
          final ui.Codec codec = await ui.instantiateImageCodec(bytes);
          final ui.FrameInfo frameInfo = await codec.getNextFrame();
          return frameInfo.image;
        }
      }
    } catch (e) {}
    return null;
  }

//加载本地图片
  Future<ui.Image?> _loadLocalImage(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      return frameInfo.image;
    } catch (e) {}
    return null;
  }

  num _easeInOut(double t) {
    return t < 0.5 ? 2 * pow(t, 2) : -1 + (4 - 2 * t) * t;
  }

  //存放聊天列表
  List<RoomChatCellVo> data = [];

  //是否为手势滑动状态
  bool dragScrollEvent = false;

  //刷新变量，用于改变让updateRenderObject能够更新到变化才会刷行ui会一直变化+1，
  int refreshNum = 0;

  //标记动画的滑动方向，是否移动到底部
  bool _animationMoveBottom = true;

  //是否显示滑到底部按钮
  final ValueNotifier<bool> scrollButtonState = ValueNotifier<bool>(false);

  //播放开始时间
  double _startTm = 0.0;

  //播放的开始位置，
  double _startMovePosition = 0.0;

  //聊天框的宽度用于限制文本的换行
  final double width;

  final AnimationController animationControl;
  final ScrollController scrollController;
  final Function refreshUi;
  final ModelPack modelPack;

  CustomcChatController({
    required this.scrollController,
    required this.animationControl,
    required this.refreshUi,
    required this.modelPack,
    required this.width,
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

  //添加Msg到内存

  //向聊天框中推入聊天对象，
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

//removeMsgBySender
  void removeMsgBySender(int userId) {
    for (var i = 0; i < data.length; i++) {
      if (data[i].roomMsg.userId == userId) {
        data.removeAt(i);
        i--;
      }
    }
    resetListPosAll();
  }

  //重置位置和高度，会从_startTotalIdx开始往后叠加下去，如果不考虑性能直接从第一个开始，
  void resetListPosAll() {
    int beginIdx = -1;
    double baseTop = 0.0;
    int haveTextLInkNum = 0;
    for (int i = 0; i < data.length; i++) {
      RoomChatCellVo vo = data[i];
      if (vo.textLink != null) {
        haveTextLInkNum++;
      }
      vo.rect = Rect.fromLTWH(0.0, baseTop, vo.rect.width, vo.rect.height);
      //特殊标记，因为是从第一个向后累加位置，

      if (vo.rect.height > 0) {
        vo.hasScenePostion = true;
      }
      if (beginIdx == -1 && vo.rect.height == 0) {
        beginIdx = i;
      }
      baseTop += vo.rect.height;
    }

    // print('当前显示对象。  开始有位置没更新的beginIdx。$beginIdx   -- 显示  $haveTextLInkNum / ${data.length}');
    // print('重新计算高度。 开始 $_startTotalIdx   没好的beginIdx $beginIdx       数量 $num    还有$noRight 没好');

    if (!animationControl.isAnimating && !scrollButtonState.value) {
      dragScrollEvent = false; //需要将手势状态归零，因为当前的是在底部
      moveBottom();
    }

    refreshUi();
  }

  //清理超出的数量，删除前部分， 当超过1000记录删除前面100条
  static int maxLen = 10000;

  //判断是否需要清理数据
  void _clearOldData() {
    int killNum = min(1000, (maxLen / 10).toInt()); //得到每次删除的数里，见意写入固定值，要比总数小，
    if (data.length >= maxLen) {
      double killHeight = 0;
      while (data.length > maxLen - killNum) {
        killHeight += data[0].rect.height;
        data.removeAt(0);
      }
      //删除前部份数据，需要重置所有对象的位置从0开始

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
