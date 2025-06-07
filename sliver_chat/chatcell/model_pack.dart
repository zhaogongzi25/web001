import 'package:data_center/live_old/model/room.dart';
import 'package:data_center/live_old/view_model/my_follow_model.dart';
import 'package:data_center/models/chat/chat.dart';
import 'package:flutter/cupertino.dart';

import '../../../../../view_model/room_msg_model.dart';
import '../../../../../view_model/room_page_model.dart';
import '../../live_game_caipiao/model/live_game_model.dart';

//用于传递模型数据，
class ModelPack{
  final RoomMsgModel roomMsgModel;
  final MyFollowModel myFollowModel;
  final LiveGameModel liveGameModel;
  final RoomPageModel roomPageModel;

  final BuildContext chatContext;


  ModelPack({
    required this.roomMsgModel,
    required this.myFollowModel,
    required this.liveGameModel,
    required this.roomPageModel,

    required this.chatContext,


  });
}