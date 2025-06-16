import 'dart:convert';
import 'dart:math';

import 'package:data_center/data_center.dart';

import 'package:data_center/live_old/model/room_msg.dart';

import 'package:data_center/live_old/view_model/my_follow_model.dart';
import 'package:data_center/utils/chat_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live/page/home/room/live_game_caipiao/model/live_game_model.dart';

import 'package:live/view_model/room_msg_model.dart';
import 'package:live/view_model/room_page_model.dart';

import 'base/custom_chat_controller.dart';
import 'base/model_pack.dart';

import 'custom_chat_view.dart';

import 'package:provider/provider.dart';

class SliverChatBox extends StatelessWidget {
  const SliverChatBox({super.key});

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
            margin: EdgeInsets.only(right: 182.w - widgetSpanPadding.right),
            height: h,
            child: Selector<RoomMsgModel, int>(
                selector: (context, model) => model.msgChangeFlag,
                builder: (context, flag, child) {
                  return SliverChatWidget(modelPack: ModelPack(
                    roomMsgModel: Provider.of<RoomMsgModel>(context, listen: false),
                    myFollowModel: Provider.of<MyFollowModel>(context, listen: false),
                    liveGameModel: Provider.of<LiveGameModel>(context, listen: false),
                    roomPageModel: Provider.of<RoomPageModel>(context, listen: false),
                    roomPagePodCastModel: null,
                    chatContext: context,
                  ),);
                }))
      ],
    );
  }
}

class SliverChatWidget extends StatefulWidget {
  final dynamic roomPagePodCastModel;
  final ModelPack modelPack;

  const SliverChatWidget({
    super.key,
     required  this.modelPack,
    this.roomPagePodCastModel,
  });

  @override
  State<StatefulWidget> createState() {
    return _SliverChatWidgetState();
  }
}

class _SliverChatWidgetState extends State<SliverChatWidget> {
  CustomcChatController? _customcChatController;

  // RoomMsgModel? _roomMsgModel;

  // ModelPack? _modelPack;
  EdgeInsets? chatMargin;

  @override
  void initState() {
    super.initState();
    chatMargin = EdgeInsets.only(right: 182.w - widgetSpanPadding.right);
    // _roomMsgModel = Provider.of<RoomMsgModel>(context, listen: false);
    // _modelPack = ModelPack(
    //   myFollowModel: Provider.of<MyFollowModel>(context, listen: false),
    //   liveGameModel: Provider.of<LiveGameModel>(context, listen: false),
    //   roomPageModel: Provider.of<RoomPageModel>(context, listen: false),
    //   roomPagePodCastModel: widget.roomPagePodCastModel,
    //   chatContext: context,
    // );
    // _oneByonePush(3000);
  }


  //自动刷新数据 测试用，到时会删除
  void _oneByonePush(tm) {
    if (_customcChatController != null) {
      int len = _customcChatController!.data.length;
      if (len < 15 || (len > 9000 && len < 9010) || len > 9990) {
        tm = 3000;
      }
      
      if(len>5000){
        tm = 3000;
        return;
      }else{
        tm=1;
      }


      // tm=1000;
    }

    Future.delayed(Duration(milliseconds: tm), () {

        //已有的信息
        print('有数据 ${_customcChatController!.data.length}' );
        if (_customcChatController!.data.length > 0) {
          int idx = Random().nextInt(_customcChatController!.data.length);
          RoomMsg roomMsg = _customcChatController!.data[idx].roomMsg;
          roomMsg = roomMsg.clone();
         if(   widget.modelPack.roomMsgModel.filterInfoItem(roomMsg)){
           if (roomMsg.id == -2) {
             roomMsg.id = -1;
           }
           _customcChatController!.pushRoomMsg(roomMsg);
         }

        }

      if (mounted) {
        _oneByonePush(Random().nextInt(1) + 1000);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: lineMargin,
      child: _listView(),
    );
  }

  Widget _listView() {
    return CustomChatView(
      modelPack: widget.modelPack,
      ctxWidth: ScreenUtil().screenWidth - chatMargin!.right - lineMargin.left,
      onCreated: (CustomcChatController controller) {
        widget.modelPack.roomMsgModel.setChatController(controller);
        _customcChatController = controller;
      },
    );
  }
}
//
// void initSliverModel() {
//   setRoomMsgModel = _roomMsgModel;
//   setRoomPageModel = _roomPageModel;
//   setLiveGameModel = _liveGameModel;
//   setMyFollowModel = _myFollowModel!;
//   getMemberWidget = getMemberNewPage;
//   getXiaZhuWidget = getXiazhuWidget;
//   chatLeaveHandler = leaveRoom;
//   chatNoMomeyHandler = showNoMoneyDialogWithFenMian;
//   setChatGuideWidget = EventsWidget(
//       data: _roomPageModel!.isBenefitLoad,
//       builder: (context, data) {
//         // 如果主播数据异常或者读取主播福利信息失败，返回 SizedBox()
//         if (_roomPageModel?.anchor == null || !_roomPageModel!.isBenefitLoad.value) {
//           return SizedBox();
//         }
//         return RoomBusinessCardTip(anchor: _roomPageModel!.anchor!);
//       });
//   setChatRoom = widget.room;
//   setChatContext = context;
// }
