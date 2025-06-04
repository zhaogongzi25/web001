import 'package:data_center/live_old/model/room_msg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live/page/home/room/sliver_chat/chatcell/room_chat_cell_vo.dart';
import '../../../../view_model/room_msg_model.dart';
import 'custom_chat_controller.dart';
import 'custom_chat_view.dart';

class SliverMain extends StatefulWidget {
  final RoomMsgModel roomMsgModel;

  const SliverMain({super.key, required this.roomMsgModel});

  @override
  _SliverMainState createState() => _SliverMainState();
}

class _SliverMainState extends State<SliverMain> {
  CustomcChatController? _customcChatController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 10.w, top: 450.w),
        width: 600.w,
        height: 450.w,
        // color: Colors.black26,
        child: _body());
  }

//数据显示暂是不改app逻辑硬对比的方法来添加到列表中
  void refreshMsglIst() {
    if (_customcChatController != null) {
      //暂时直接对应该当前的房间信息，然后显示要显示的记录 进行对比，没有就添加
      for (RoomMsg roomMsg in widget.roomMsgModel.msgList) {
        bool needAdd = true;
        for (RoomChatCellVo vo in _customcChatController!.data) {
          if (vo.roomMsg.id == roomMsg.id) {
            needAdd = false;
          }
        }
        if (needAdd) {
          RoomChatCellVo addVo = RoomChatCellVo(
            chatController: _customcChatController!,
            roomMsg: roomMsg,
          );
          _customcChatController!.pushData(addVo);
          _customcChatController!.moveBottom();
        }
      }
    }
  }

  Widget _body() {
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
