import 'dart:convert';
import 'dart:math';

import 'package:data_center/data_center.dart';
import 'package:data_center/live_old/model/data_manager.dart';
import 'package:data_center/live_old/model/room_msg.dart';
import 'package:data_center/live_old/model/room_player.dart';
import 'package:data_center/live_old/view_model/my_follow_model.dart';
import 'package:data_center/utils/chat_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live/page/home/room/live_game_caipiao/model/live_game_model.dart';

import 'package:live/view_model/room_msg_model.dart';
import 'package:live/view_model/room_page_model.dart';

import 'chatcell/model_pack.dart';
import 'chatcell/room_chat_cell_vo.dart';
import 'chatcell/room_chat_text.dart';
import 'custom_chat_controller.dart';
import 'custom_chat_view.dart';

import 'package:provider/provider.dart';

class SliverMain extends StatefulWidget {
  final dynamic roomPagePodCastModel;
  const SliverMain({super.key, this.roomPagePodCastModel});

  // Provider.of<RoomPagePodCastModel>(context, listen: false)
  @override
  _SliverMainState createState() => _SliverMainState();
}

class _SliverMainState extends State<SliverMain> {
  CustomcChatController? _customcChatController;
  RoomMsgModel? _roomMsgModel;
  MyFollowModel? _myFollowModel;
  RoomPageModel? _roomPageModel;
  LiveGameModel? _liveGameModel;
  ModelPack? _modelPack;
  EdgeInsets? chatMargin;

  @override
  void initState() {
    super.initState();
    chatMargin = EdgeInsets.only(right: 182.w - widgetSpanPadding.right);
    _roomMsgModel = Provider.of<RoomMsgModel>(context, listen: false);
    _myFollowModel = Provider.of<MyFollowModel>(context, listen: false);
    _roomPageModel = Provider.of<RoomPageModel>(context, listen: false);
    _liveGameModel = Provider.of<LiveGameModel>(context, listen: false);
    // _roomPagePodCastModel =
    //     Provider.of<RoomPagePodCastModel>(context, listen: false);
    _modelPack = ModelPack(
      roomMsgModel: _roomMsgModel!,
      myFollowModel: _myFollowModel!,
      liveGameModel: _liveGameModel!,
      roomPageModel: _roomPageModel!,
      roomPagePodCastModel: widget.roomPagePodCastModel,
      chatContext: context,
    );
    // _oneByonePush(2000);
  }

  //自动刷新数据
  void _oneByonePush(tm) {
    if (_customcChatController != null) {
      int len = _customcChatController!.data.length;
      if (len > 9995 || (len - 9904).abs() < 5) {
        tm = 3000;
      }
    }
    Future.delayed(Duration(milliseconds: tm), () {
      if (_customcChatController != null) {
        //暂时直接对应该当前的房间信息，然后显示要显示的记录 进行对比，没有就添加
        int idx = Random().nextInt(_roomMsgModel!.msgList.length);
        RoomMsg roomMsg = _roomMsgModel!.msgList[idx];
        roomMsg = roomMsg.clone();
        if (roomMsg.id > 0) {
          RoomPlayer? player = RoomChatText.getRoomPlayerByUserId(roomMsg.userId);
          if (player == null) {
            if (mounted) {
              _oneByonePush(Random().nextInt(1000) + 1);
            }
            return;
          }
        }
        RoomChatCellVo addVo = RoomChatCellVo(
          chatController: _customcChatController!,
          roomMsg: roomMsg,
          modelPack: _modelPack!,
          width: _customcChatController!.width,
        );
        _customcChatController!.pushData(addVo);
        _customcChatController!.moveBottomOfpushData();
        if (mounted) {
          _oneByonePush(Random().nextInt(1000) + 1);
          setState(() {});
        }
      }
    });
  }

  final Map<int, bool> _useData = {};

//数据显示暂是不改app逻辑硬对比的方法来添加到聊天列表中
  void _refreshMsglIst() {
    if (_customcChatController != null) {
      //暂时直接对应该当前的房间信息，然后显示要显示的记录 进行对比，没有就添加
      for (int i = 0; i < _roomMsgModel!.msgList.length; i++) {
        RoomMsg roomMsg = _roomMsgModel!.msgList[i];
        if (!_useData.containsKey(roomMsg.id)) {
          if (roomMsg.id! < 0) {
            ///系统消息。不需要判断用户信息是否在内存中
            _makeRoomChatCellVo(roomMsg);
          } else {
            _createMsglineView(roomMsg, null);
          }
          return;
        }
      }
    }
  }

  void _makeRoomChatCellVo(RoomMsg roomMsg) {
    _useData.addEntries(<int, bool>{roomMsg.id: true}.entries);
    print('新添加对象 id = ${roomMsg.id}');
    RoomChatCellVo addVo = RoomChatCellVo(
      chatController: _customcChatController!,
      roomMsg: roomMsg,
      modelPack: _modelPack!,
      width: _customcChatController!.width,
    );
    _customcChatController!.pushData(addVo);
    _customcChatController!.moveBottomOfpushData();
    _refreshMsglIst();
  }

  void _createMsglineView(RoomMsg roomMsg, RoomPlayer? player) {
    RoomPlayer? player = RoomChatText.getRoomPlayerByUserId(roomMsg.userId);
    //添加逻辑，还没懂 item.userId == 1的逻辑，
    if (player != null || roomMsg.userId == 1) {
      _makeRoomChatCellVo(roomMsg);
    } else {
      //没有player缓存，就需要等待加载
      int roomId = _roomPageModel!.curRoomInfo.id!;
      dataMgr.getRoomPlayer(roomMsg.userId, roomId: roomId).then((value) {
        if (value != null) {
          _createMsglineView(roomMsg, value); //Container();
          _roomMsgModel!.setMsgChangeFlag();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double h = dataCenter.pkActivityMgr.activity.chatWidgetH(context);
    return Column(
      children: [
        SizedBox(
          height: 430.w,
        ),
        Container(
            // color: Colors.white,
            margin: chatMargin,
            height: h,
            child: Container(margin: lineMargin, child: _body()))
      ],
    );
  }

  Widget _body() {
    return Selector<RoomMsgModel, int>(
        selector: (context, model) => model.msgChangeFlag,
        builder: (context, flag, child) {
          return _listView();
        });
  }

  Widget _listView() {
    //刷新数据的方法还要结合app机制
    _refreshMsglIst();
    return CustomChatView(
      ctxWidth: ScreenUtil().screenWidth - chatMargin!.right - lineMargin.left,
      onCreated: (CustomcChatController controller) {
        _customcChatController = controller;
        _refreshMsglIst();
      },
    );
  }
}
