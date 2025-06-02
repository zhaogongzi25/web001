import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'vo/base_info_vo.dart';

class CustomcChatController {
  num _easeInOut(double t) {
    return t < 0.5 ? 2 * pow(t, 2) : -1 + (4 - 2 * t) * t;
  }

  final AnimationController animationControl;
  final ScrollController scrollController;
  final Function refreshUi;
  List<BaseInfovo> data = [];
  //刷新变量，用于改变让updateRenderObject能够更新到变化才会刷行ui
  int refreshNum = 0;

  //标记动画的滑动方向，是否移动到地步
  bool _animationMoveBottom = true;
  //播放开始时间
  double _startTm = 0.0;
  //播放的开始位置，
  double _startMovePosition = 0.0;

  CustomcChatController({
    required this.scrollController, // 需要传入 ScrollController
    required this.animationControl, // 需要传入 AnimationController
    required this.refreshUi, // 需要传入 setState 或类似的刷新函数
  }) {
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

  double getTotalHeight() {
    double num = 0;
    for (BaseInfovo vo in data) {
      num += vo.rect!.height;
    }
    return num;
  }

  void pushData(BaseInfovo vo) {
    data.add(vo);
    _clearOldData();
    _resetPosition(data);
  }

  //清理超出的数量，删除前部分，
  void _clearOldData() {
    int maxLen = 1000;
    int killNum = 100;
    if (data.length > maxLen) {
      double killHeight = 0;
      while (data.length > maxLen - killNum) {
        killHeight += data[0].rect!.height;
        data.removeAt(0);
      }
      if (scrollController.hasClients) {
        if (scrollController.position.hasContentDimensions) {
          _startMovePosition = scrollController.position.pixels - killHeight;
          scrollController.jumpTo(_startMovePosition);
        }
      }
    }
  }

  //计算所有对象当前的位置和对应的高度，这里需要优化，不是每一个都是要全刷新，可以优化
  void _resetPosition(List<BaseInfovo> arr) {
    double ty = 0.0;
    int id = 0;
    for (BaseInfovo vo in arr) {
      vo.skipId = id++;
      vo.rect = Rect.fromLTWH(0.0, ty, vo.rect!.width, vo.rect!.height);
      ty += vo.rect!.height;
    }
  }

  //移到到底部，
  void moveBottom({double? time}) {
    _animationMoveBottom = true;
    _starAnimation(time: time ?? 0.25);
  }

  //当不是在滑动的时间播放滑动到底部事件
  void autoMoveBottom({double? time}) {
    if (scrollController.hasClients) {
      ScrollPosition position = scrollController.position;
      if (position.hasPixels && position.hasViewportDimension) {
        if (position.activity is DragScrollActivity) {
          //拖拽滑动
        } else {
          if (position.pixels >= position.maxScrollExtent) {
            moveBottom(time: 0.25);
          }
        }
      }
    }
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
