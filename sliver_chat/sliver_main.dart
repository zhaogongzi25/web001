import 'package:custom_image/cache_image.dart';
import 'package:data_center/live_old/model/room_msg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live/page/home/room/sliver_chat/vo/base_info_vo.dart';
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
        margin: EdgeInsets.only(left: 10.w, top: 300.w),
        width: 650.w,
        height: 500.w,
        color: Colors.white30,
        child: _body());
  }

  Widget _img() {
    String url =
        'http://res.banana888.ninja:89/files/admin_res/2025052413/pic/a18afcb70a54132c08c9c6483aa96a55.png';

    Widget img = RemoteImage(
      src: url,
    );
    return img;
  }

  void refreshMsglIst() {
    if (_customcChatController != null) {
      for (RoomMsg roomMsg in widget.roomMsgModel.msgList) {
        bool needAdd = true;
        for (BaseInfoVo baseInfovo in _customcChatController!.data) {
          if (baseInfovo.roomMsg.id == roomMsg.id) {
            needAdd = false;
          }
        }
        if (needAdd) {
          print('添加  -----------。${roomMsg.id}');
          BaseInfoVo addvo = BaseInfoVo(
            chatController: _customcChatController!,
            roomMsg: roomMsg,
          );
          _customcChatController!.pushData(addvo);
        }
      }
    }
  }



  Widget _body() {
    refreshMsglIst();

    return Container(
      color: Colors.black26,
      child: CustomChatView(
        onCreated: (CustomcChatController controller) {
          _customcChatController = controller;
          refreshMsglIst();
        },
      ),
    );
  }
}
