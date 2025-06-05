
import 'package:data_center/live_old/model/room_msg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live/page/home/room/sliver_chat/chatcell/room_chat_cell_vo.dart';
import '../../../../view_model/room_msg_model.dart';
import '../../../../view_model/room_page_model.dart';
import 'custom_chat_controller.dart';
import 'custom_chat_view.dart';

import 'package:live/view_model/room_page_model.dart';
import 'package:provider/provider.dart';


class SliverMain extends StatefulWidget {


  const SliverMain({super.key});

  @override
  _SliverMainState createState() => _SliverMainState();
}

class _SliverMainState extends State<SliverMain> {
  CustomcChatController? _customcChatController;
  RoomMsgModel? _roomMsgModel;
  @override
  void initState() {
    super.initState();
    _roomMsgModel=Provider.of<RoomMsgModel>(context, listen: false);
    print('SliverMain------------------initState');
  }

  @override
  Widget build(BuildContext context) {
    print('SliverMain------------------build');
     Provider.of<RoomPageModel>(context, listen: false);
    return Container(
        margin: EdgeInsets.only(left: 10.w, top: 450.w),
        width: 600.w,
        height: 450.w,
        // color: Colors.white,
        child: _bodycopy()
       );
  }


//数据显示暂是不改app逻辑硬对比的方法来添加到列表中
  void refreshMsglIst() {
    if (_customcChatController != null) {
      //暂时直接对应该当前的房间信息，然后显示要显示的记录 进行对比，没有就添加
      if(_customcChatController!.scrollButtonState.value){
        print('----------不添加');
        return;
      }
      for (RoomMsg roomMsg in _roomMsgModel!.msgList) {
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
          // _customcChatController!.moveBottomOfpushData();
        }
      }
    }
  }
  Widget _bodycopy(){

    return   Selector<RoomMsgModel, int>(
        selector: (context, model) => model.msgChangeFlag,
        builder: (context, flag, child) {

          return _body();
        });
  }

  Widget _body() {
    //刷新数据的方法还要结合app机制
    refreshMsglIst();
    print('refreshMsglIst------------------refreshMsglIst');
    return CustomChatView(
      onCreated: (CustomcChatController controller) {
        _customcChatController = controller;
        refreshMsglIst();
        print('onCreated------------------onCreated');
      },
    );
  }
}
