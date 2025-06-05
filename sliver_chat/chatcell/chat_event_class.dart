
//功能模块
import 'package:common_base/common_base.dart';
import 'package:common_base/utils/utility.dart';
import 'package:data_center/data_center.dart';
import 'package:data_center/live_old/constants.dart';
import 'package:data_center/live_old/model/data_manager.dart';
import 'package:data_center/live_old/model/room_msg.dart';
import 'package:data_center/live_old/model/room_player.dart';
import 'package:data_center/live_old/service/service_game.dart';
import 'package:data_center/live_old/utility/colors.dart';
import 'package:data_center/live_old/utility/string.dart';
import 'package:data_center/live_old/view_model/my_follow_model.dart';
import 'package:data_center/live_old/widget/style_widget.dart';
import 'package:data_center/utils/chat_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:live/page/home/room/sliver_chat/chatcell/model_pack.dart';

import '../../../../../view_model/room_msg_model.dart';
import '../../../../../view_model/room_page_model.dart';
import '../../live_game_caipiao/model/live_game_model.dart';

class ChatEventClass{

  void onTapNikeName(RoomPlayer roomPlayer, RoomMsg _chatRoom,ModelPack modelPack) {
    if ((
        roomPlayer.mysteryMan > 0 &&
            roomPlayer.id != dataCenter.mainUser.id) &&
        dataCenter.mainUser.isAdmin == 0) {
      return;
    }
    RoomMsgModel roomMsgModel = modelPack.roomMsgModel;
    MyFollowModel myFollowModel = modelPack.myFollowModel;
    if (roomMsgModel.msgBuildContext != null) {
      showModalBottomSheet(
        barrierColor: Colours.bottom_sheet_black_bg,
        backgroundColor: Colors.transparent,
        context: roomMsgModel.msgBuildContext!,
        builder: (context) {
          Widget _memberInfoNew =
          getMemberWidget!(_chatRoom.id, roomPlayer.id);
          return Container(
              height: ScreenUtil().bottomBarHeight > 0 ? 615.w : 575.w,
              child: ChangeNotifierProvider.value(
                  value: myFollowModel, child: _memberInfoNew));
        },
      );
    }
  }
  void onTapGetzhuEvent(temp,ModelPack modelPack) async {
    LiveGameModel _liveGameModel=modelPack.liveGameModel;
    RoomPageModel _roomPageModel=modelPack.roomPageModel;
    BuildContext _chatContext=modelPack.chatContext;
    if (dataCenter.clientLimitMgr.getIsButtonDisabled('genTouBtn')) {
      return;
    }
    dataCenter.clientLimitMgr.setButtonDisabled(true, 'genTouBtn', 1000);
    print('点击到跟投按钮');
    if (dataMgr.cacheMgr.liveGameConfig == null) {
      showToastTip('跟投数据加载失败,请重试');
      return;
    }

    if (temp != null && !isTouZhuOk) {
      isTouZhuOk = true;
      List arr = [];

      // print('当前下注阶段5');
      // if (result.result == null) return;
      _liveGameModel.curGameIdx = temp['cp_type'];
      // int cpType = temp['cp_type'];
      await _liveGameModel.requestGameInfo(isChat: true);
      // print('当前下注阶段6');
      dynamic info;
      int multiple = 1;
      List<dynamic>? betList = temp['bet_list'];
      if (betList == null || betList.isEmpty) {
        var result = await serviceGame.queryUserBet(
            temp['pp_user_id'], temp['draw_issue'], temp['cp_type']);
        betList = result.result;
      }

      for (var i = 0; i < betList!.length; i++) {
        Map arrMap = {};
        var batSigleArr =
        temp['bet_list'] != null ? betList[i].split('-') : [];
        int cpGame = temp['bet_list'] != null
            ? int.tryParse(batSigleArr[0]) ?? 0
            : betList[i]['cp_game'];
        int msgValueIdx = temp['bet_list'] != null
            ? int.tryParse(batSigleArr[1]) ?? 0
            : betList[i]['value'];
        int msgMoney = temp['bet_list'] != null
            ? int.tryParse(batSigleArr[2]) ?? 0
            : betList[i]['amount'];
        info = getGameByType(temp['cp_type']);
        multiple = temp['bet_list'] != null ? 1 : betList[i]['multiple'];
        Map gameInfo = _liveGameModel.getGameById(info['info'], cpGame);
        if (gameInfo.isEmpty) {
          showToastTip('对应的跟投信息失效,请尝试其他跟投操作');
          return;
        }
        int valueIdx =
        _liveGameModel.getValueIdx(gameInfo['value'], msgValueIdx);
        String odd = '';
        if (gameInfo['game'] == LiveGameType.BjlZx && valueIdx == 3) {
          odd = '最高${gameInfo['odds'][valueIdx]}';
        } else {
          odd = gameInfo['odds'][valueIdx].toString();
        }
        String gameSel = gameInfo['info'][valueIdx].toString();
        Map<String, dynamic> betTtemp = {};
        if (_liveGameModel.panluDrawinfo == null) return;
        betTtemp = {
          'draw_issue': _liveGameModel.panluDrawinfo!.drawIssue.toString(),
          'user_id': dataCenter.mainUser.id,
          'broken_id': _roomPageModel.curRoomInfo.id,
          'seq': _roomPageModel.curVideo.seq,
          'cp_type': temp['cp_type'],
          'cp_game': cpGame,
          'value': msgValueIdx,
          'amount': msgMoney, //:
          'multiple': multiple,
          'gameName': gameInfo['title'],
          'gameSelCon': gameSel,
          'odds': odd
        };
        CaipiaoBet caipiao = CaipiaoBet(betTtemp);

        String key =
            '${caipiao.gameName!}-${caipiao.gameSelCon!}-${caipiao.cpGame!}-${caipiao.value!}';
        arrMap['key'] = key;
        arrMap['content'] = caipiao;
        arr.add(arrMap);
        // }
      }
      // print('当前下注阶段7');
      Future.delayed(const Duration(seconds: 1), () {
        // if (mounted) {
        isTouZhuOk = false;
        // }
      });

      if (_chatContext.mounted) {
        // print('当前下注阶段8');
        // if (LiveGameType.NewGameArr.indexOf(cpType) != -1) {
        // } else {
        _liveGameModel.betData = arr;
        _liveGameModel.idVserion = _liveGameModel.curGameIdx;
        Future.delayed(const Duration(milliseconds: 100), () {
          showModalBottomSheet(
            enableDrag: false,
            isScrollControlled: true,
            //一：设为true，此时为全屏展示
            barrierColor: Colours.bottom_sheet_black_bg,
            backgroundColor: Colors.transparent,
            context: Constants.navigatorKey.currentContext!,
            builder: (context) {
              pdebug('1点击到跟投按钮');
             Widget _xiaZhuWidget = getXiaZhuWidget!(
                info,
                -1,
                true,
              );
              return Container(
                  height: 928.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _xiaZhuWidget);
            },
          ).then((value) {
            isTouZhuOk = false;
          });
        });
        // }
      }
      // print('当前下注阶段9');
      // print(result);
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        // if (mounted) {
        isTouZhuOk = false;
        // }
      });
    }



  }

}