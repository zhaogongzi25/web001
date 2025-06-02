import 'package:data_center/live_old/model/data_manager.dart';
import 'package:data_center/live_old/model/room_msg.dart';
import 'package:data_center/live_old/model/room_player.dart';
import 'package:data_center/live_old/utility/string.dart';
import 'package:live/page/home/room/sliver_chat/chatcell/base_text_link.dart';
import 'package:live/page/home/room/sliver_chat/custom_chat_controller.dart';

import 'package:live/page/home/room/sliver_chat/vo/base_info_vo.dart';
import 'package:live/page/home/room/sliver_chat/vo/nine_image_draw.dart';

class CustomBrideModel {
  static CustomBrideModel? _instance;

  CustomBrideModel._internal();

  factory CustomBrideModel() {
    _instance ??= CustomBrideModel._internal();
    return _instance!;
  }

  List<RoomMsg> _msgList = [];
  CustomcChatController? _customcChatController;

  void init(CustomcChatController controller) {
    _customcChatController = controller;
    initBase();
  }

  void initBase() {
    _customcChatController!.data.clear();
    for (int i = 0; i < _msgList.length; i++) {
      pushdata(_msgList[i]);
    }
  }

  CustomcChatController get chatController => _customcChatController!;

  void pushdata(RoomMsg roomMsg) {
    BaseInfovo vo = getMsgLineView(roomMsg);

    if (vo != null) {
      CustomBrideModel().chatController!.pushData(vo);
      CustomBrideModel().chatController!.refreshUi();
    }
  }

  void resetdata(List<RoomMsg> arr) {
    if (arr.length > _msgList.length) {
      while (_msgList.length < arr.length) {
        _msgList.add(arr[_msgList.length]);
        if (chatController != null) {
          pushdata(_msgList[_msgList.length - 1]);
        }
      }
    }
  }

  ///获取含有背景的行数据
  BaseInfovo getMsgLineView(RoomMsg item) {
    return BaseInfovo(
      chatController: chatController!,
      roomMsg: item,
    );
  }

}
