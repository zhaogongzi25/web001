
//功能模块
import 'package:common_base/common_base.dart';
import 'package:common_base/toast.dart';
import 'package:common_base/utils.dart';
import 'package:common_base/utils/utility.dart';
import 'package:data_center/data_center.dart';
import 'package:data_center/live_old/constants.dart';
import 'package:data_center/live_old/manager/preload_mgr.dart';
import 'package:data_center/live_old/model/data_manager.dart';
import 'package:data_center/live_old/model/room_msg.dart';
import 'package:data_center/live_old/model/room_player.dart';
import 'package:data_center/live_old/service/service_game.dart';
import 'package:data_center/live_old/utility/colors.dart';
import 'package:data_center/live_old/utility/string.dart';
import 'package:data_center/live_old/view_model/my_follow_model.dart';
import 'package:data_center/live_old/widget/style_widget.dart';
import 'package:data_center/models/chat/chat.dart';
import 'package:data_center/utils/chat_utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';

import 'package:wordchat/views/benefit/benefit_dialog.dart';

import 'model_pack.dart';


//按钮事件都放这里，和原来方法一样，
class ChatEventClass{
  //解锁
  void onJiesuo(ModelPack modelPack) async {
    BuildContext context = modelPack.chatContext;
    dynamic roomPageModel = modelPack.roomPageModel;
    UserChat anchor = roomPageModel.anchor!;
    if (!context.mounted) {
      return;
    }
    if (anchor.isGamePodcast) {
      Toast.showToast('主播尚未开启私聊');
      return;
    }
    if (dataCenter.userAnchorMgr.isBenefitOpen) {
      return;
    }
    if (dataCenter.clientLimitMgr
        .getIsButtonDisabled('room_bottom_input')) {
      return;
    }
    dataCenter.clientLimitMgr
        .setButtonDisabled(true, 'room_bottom_input', 500);



    if (!dataCenter.userAnchorMgr.isBenefitCanClick)
      return;
    dataCenter.userAnchorMgr.isBenefitClick = false;

    // 需要查询的话
    if (dataCenter.userAnchorMgr.isNeedCheckBenefit) {
      // 转菊花
      // showDialog(
      //     context: context,
      //     barrierDismissible: false,
      //     barrierColor: Colors.transparent,
      //     builder: (_) {
      //       return Container(
      //         width: ScreenUtil().screenWidth,
      //         height: ScreenUtil().screenHeight,
      //         alignment: Alignment.center,
      //         child: SpinKitFadingCircle(color: Colours.gray_66),
      //       );
      //     });
      // 请求福利数据
      await dataCenter.userAnchorMgr.checkBenefitData(
          roomPageModel.curRoomInfo.id!);
      // 把菊花pop掉
      //Routes.instance!.popUntilLivePage(Constants.navigatorKey.currentContext!);
    }

    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: false,
      barrierColor: Colours.bottom_sheet_black_bg,
      backgroundColor: Colors.transparent,
      context: Constants.navigatorKey.currentContext!,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (context) => Container(
        decoration: new BoxDecoration(
          image: DecorationImage(
            image: preloadMgr.getImageAssetWidget(
                Utils.getAssetRealPath(
                    'assets/plugin/wordchat/images/common/bg_benefit.png')),
            fit: BoxFit.fill,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40.w),
            topRight: Radius.circular(40.w),
          ),
        ),
        height: 978.w,
        // color: Colors.red,
        child: BenefitDialog(
          roomId: roomPageModel.curRoomInfo.id!,
          loveValue:
          dataCenter.anchorSettingMgr.loveValue,
          isFolder: dataCenter.userAnchorMgr.isFolder,
          isFriend: dataCenter.userAnchorMgr.isFriend,
        ),
      ),
    );

  }
//点击人名
  void onTapNikeName(RoomPlayer roomPlayer, RoomMsg _chatRoom,ModelPack modelPack) {
    if ((
        roomPlayer.mysteryMan > 0 &&
            roomPlayer.id != dataCenter.mainUser.id) &&
        dataCenter.mainUser.isAdmin == 0) {
      return;
    }
    dynamic roomMsgModel = modelPack.roomMsgModel;
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
  //打开跟注
  void onTapGetzhuEvent(temp,ModelPack modelPack) async {
    dynamic _liveGameModel=modelPack.liveGameModel;
    dynamic _roomPageModel=modelPack.roomPageModel;
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