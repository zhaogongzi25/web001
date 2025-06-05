import 'dart:convert';

import 'package:data_center/live_old/model/data_manager.dart';
import 'package:data_center/live_old/model/room_msg.dart';
import 'package:data_center/live_old/model/room_player.dart';
import 'package:data_center/live_old/view_model/my_follow_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live/page/home/room/sliver_chat/chatcell/room_chat_cell_vo.dart';
import '../../../../view_model/room_msg_model.dart';
import '../../../../view_model/room_page_model.dart';
import 'chatcell/room_chat_text.dart';
import 'custom_chat_controller.dart';
import 'custom_chat_view.dart';

import 'package:provider/provider.dart';

class SliverMain extends StatefulWidget {
  const SliverMain({super.key});

  @override
  _SliverMainState createState() => _SliverMainState();
}

class _SliverMainState extends State<SliverMain> {
  CustomcChatController? _customcChatController;
  RoomMsgModel? _roomMsgModel;
  MyFollowModel? _myFollowModel;
  RoomPageModel? _roomPageModel;

  @override
  void initState() {
    super.initState();
    _roomMsgModel = Provider.of<RoomMsgModel>(context, listen: false);
    _myFollowModel = Provider.of<MyFollowModel>(context, listen: false);
    _roomPageModel = Provider.of<RoomPageModel>(context, listen: false);
    print('SliverMain------------------initState');
  }

//数据显示暂是不改app逻辑硬对比的方法来添加到列表中
  void refreshMsglIst() {
    if (_customcChatController != null) {
      //暂时直接对应该当前的房间信息，然后显示要显示的记录 进行对比，没有就添加
      for (RoomMsg item in _roomMsgModel!.msgList) {
        // print('roomMsg.len   ${_roomMsgModel!.msgList.length}');
        bool needAdd = true;
        for (RoomChatCellVo vo in _customcChatController!.data) {
          if (vo.roomMsg.id == item.id) {
            needAdd = false;
          }
        }
        if (needAdd) {
          if (item.id! < 0) {
            ///系统消息
            RoomChatCellVo addVo = RoomChatCellVo(
                chatController: _customcChatController!,
                roomMsg: item,
                roomMsgModel: _roomMsgModel!,
                myFollowModel: _myFollowModel!);
            _customcChatController!.pushData(addVo);
            _customcChatController!.moveBottomOfpushData();
          } else {
            createMsglineView(item, null);
          }
        }
      }
    }
  }

  void createMsglineView(RoomMsg item, RoomPlayer? player) {
    RoomPlayer? player = RoomChatText.getRoomPlayerByUserId(item.userId);
    if (player != null || item.userId == 1) {
      RoomChatCellVo addVo = RoomChatCellVo(
          chatController: _customcChatController!,
          roomMsg: item,
          roomMsgModel: _roomMsgModel!,
          myFollowModel: _myFollowModel!);
      _customcChatController!.pushData(addVo);
      _customcChatController!.moveBottomOfpushData();
    } else {
      int roomId = _roomPageModel!.curRoomInfo.id!;
      dataMgr.getRoomPlayer(item.userId, roomId: roomId).then((value) {
        if (value != null) {
          createMsglineView(item, value); //Container();
          _roomMsgModel!.setMsgChangeFlag();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 20.w, top: 450.w),
        width: 600.w,
        height: 450.w,
        // color: Colors.white,
        child: _bodycopy());
  }

  Widget _bodycopy() {
    return Selector<RoomMsgModel, int>(
        selector: (context, model) => model.msgChangeFlag,
        builder: (context, flag, child) {
          return _listView();
        });
  }

  Widget _listView() {
    //刷新数据的方法还要结合app机制

    refreshMsglIst();

    return CustomChatView(
      onCreated: (CustomcChatController controller) {
        _customcChatController = controller;
        refreshMsglIst();
      },
    );
  }
}
