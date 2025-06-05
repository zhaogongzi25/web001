//聊天消息

import 'dart:convert';
import 'dart:io';


import 'package:common_base/common_base.dart';
import 'package:common_base/utils/utility.dart';
import 'package:data_center/data_center.dart';
import 'package:data_center/live_old/constants.dart';

import 'package:data_center/live_old/model/data_manager.dart';
import 'package:data_center/live_old/model/item.dart';

import 'package:data_center/live_old/model/room_msg.dart';
import 'package:data_center/live_old/model/room_player.dart';
import 'package:data_center/live_old/service/service_game.dart';

import 'package:data_center/live_old/utility/colors.dart';
import 'package:data_center/live_old/utility/string.dart';
import 'package:data_center/live_old/view_model/my_follow_model.dart';
import 'package:data_center/live_old/widget/style_widget.dart';
import 'package:data_center/utils/chat_utils.dart';
import 'package:flutter/material.dart';
import 'package:live/page/home/room/sliver_chat/view/head_base_icon.dart';

import '../../../../../view_model/room_msg_model.dart';

import '../../../../../view_model/room_page_model.dart';
import '../../live_game_caipiao/model/live_game_model.dart';
import '../view/end_base_icon.dart';
import '../view/tittle_base_icon.dart';
import '../view/base_text_link.dart';

import 'package:provider/provider.dart';

import 'model_pack.dart';

class RoomChatText extends BaseTextLink {
  //聊天记录对象
  final RoomMsg roomMsg;
  final ModelPack modelPack;

  RoomChatText({
    required this.roomMsg,
    required this.modelPack,
    required super.baseStyle,
  });

  @override
  void initData() {
    links = [];
    RoomMsg msg = roomMsg;
    String content = roomMsg.getValue('content', null);
    Map<String, dynamic> data = jsonDecode(content);

    if (roomMsg.contentType == ChatType.Chat_sys) {
      RoomPlayer? player = getRoomPlayerByUserId(roomMsg.userId);
      Item? iteminfo;
      var tempCon = roomMsg.data['content'] ?? '';
      Map<String, dynamic> temp;
      if (tempCon == '') {
        temp = {};
      } else {
        temp = jsonDecode(tempCon);
      }
      if (temp['count'] != null && temp['item_id'] != null) {
        iteminfo = dataMgr.find<Item>(TableNames.item, temp['item_id']);
      }
      int value = temp['optcode'] ?? 0;

      textContent = '新添加系统消息。optcode    $value';
      if (value == ChatContentType.ChatContent_caipiaoXiazhu) {
        String nikeName = _addNikeName(msg, player!);
        String cpType = temp['cp_type_string'];
        double totalAmount = (temp['total_amount']) / 1;
        textContent = '用户${nikeName}在${cpType}的玩法中，已成功下注${totalAmount}元';
        _addSysIcon(); //加系统图标
        _setColorTypeToText(cpType, Colours.text_yellow); //游戏类型加颜色
        _setColorTypeToText(
            totalAmount.toString(), Colours.text_yellow); //金额加颜色
        addEndImageArr(
          EndBaseIcon(
              titleLen: 3,
              url: 'assets/live_game/gentou.png',
              textStyle: baseStyle,
              boxRect: Rect.fromLTRB(-5.w, -6.w, 5.w, 6.w),
              onTap: () {
                _onTapGetzhuEvent(temp);
              }),
        );
      } else if (value == ChatContentType.ChatContent_caipiaoZhongjiang) {
        // {pay_amount: 19.6, user_id: 271065674, cp_type: 3, notice_type: 1, cp_name: 一分快三, optcode: 20, broken_id: 250627693, app_user_id: 1189364220}
        // print(temp);
        String nikeName = _addNikeName(msg, player!);
        ;
        String cp_name = temp['cp_name'];
        double pay_amount = (temp['pay_amount']) / 1;
        textContent = '恭喜${nikeName}在${cp_name}的玩法中，已成功下注${pay_amount}元';
        _setColorTypeToText(cp_name, Colours.text_yellow); //游戏类型加颜色
        _setColorTypeToText(pay_amount.toString(), Colours.text_yellow); //金额加颜色
        _addZhongjiangIcon();
      } else {}

      return;
    }

    if (roomMsg.id! < 0) {
      if (data.containsKey('text')) {
        textContent = (data['text']);
      } else {
        textContent = ('独家主播福利,等你来解锁！尽情畅享私\n密时刻,体验无与伦比的乐趣！');
      }
      _addSysIcon();
    } else {
      ///普通消息
      RoomPlayer? player = getRoomPlayerByUserId(roomMsg.userId);
      if (player != null) {
        createSysAndNoticeView(roomMsg, player);
      } else {
        textContent = 'player 还没能获取';
      }
    }
  }

//下注Widget界面
  Widget? _xiaZhuWidget;

  void _onTapGetzhuEvent(temp) async {
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
      _liveGameModel!.curGameIdx = temp['cp_type'];
      // int cpType = temp['cp_type'];
      await _liveGameModel!.requestGameInfo(isChat: true);
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
        Map gameInfo = _liveGameModel!.getGameById(info['info'], cpGame);
        if (gameInfo.isEmpty) {
          showToastTip('对应的跟投信息失效,请尝试其他跟投操作');
          return;
        }
        int valueIdx =
        _liveGameModel!.getValueIdx(gameInfo['value'], msgValueIdx);
        String odd = '';
        if (gameInfo['game'] == LiveGameType.BjlZx && valueIdx == 3) {
          odd = '最高${gameInfo['odds'][valueIdx]}';
        } else {
          odd = gameInfo['odds'][valueIdx].toString();
        }
        String gameSel = gameInfo['info'][valueIdx].toString();
        Map<String, dynamic> betTtemp = {};
        if (_liveGameModel!.panluDrawinfo == null) return;
        betTtemp = {
          'draw_issue': _liveGameModel!.panluDrawinfo!.drawIssue.toString(),
          'user_id': dataCenter.mainUser.id,
          'broken_id': _roomPageModel!.curRoomInfo.id,
          'seq': _roomPageModel!.curVideo.seq,
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

      if (_chatContext!.mounted) {
        // print('当前下注阶段8');
        // if (LiveGameType.NewGameArr.indexOf(cpType) != -1) {
        // } else {
        _liveGameModel!.betData = arr;
        _liveGameModel!.idVserion = _liveGameModel!.curGameIdx;
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
              _xiaZhuWidget = getXiaZhuWidget!(
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

  void _setColorTypeToText(String str, Color color) {
    links!.add({
      'text': str,
      'color': color,
    });
  }

  //添加用户名字
  String _addNikeName(RoomMsg msg, RoomPlayer player) {

    links!.add({
      'text': player.nickname,
      'onTap': () {
        onTapNikeName(player, msg);
      },
      'color': player.vipLevel > 0 ? Colours.chat_user_vip : Colours.text_blue,
    });
    return player.nickname;
  }

  //加系统图标
  void _addSysIcon() {
    addIconTittleToHead(
      HeadBaseIcon(
        titleLen: 3,
        url: 'assets/live_game/xitong.png',
        textStyle: baseStyle,
        boxRect: Rect.fromLTRB(0.w, 0.w, 0.w, 0.w),
      ),
    );
  }

  //加中奖图标
  void _addZhongjiangIcon() {
    addIconTittleToHead(
      TittleBaseIcon(
        titleLen: 3,
        url: 'assets/live_game/zhongjiang.png',
        textStyle: baseStyle,
        boxRect: Rect.fromLTRB(5.w, 0.w, -2.w, 0.w),
        title: "中奖",
        pos: Offset(0.w, 2.w),
      ),
    );
  }

  //通过id得到RoomPlayer； 这个方法暂时来直接获取用户信息，
  static RoomPlayer? getRoomPlayerByUserId(int userId) {
    RoomPlayer? player = dataMgr.findObj(TableNames.roomPlayer, userId) != null
        ? dataMgr.findObj(TableNames.roomPlayer, userId) as RoomPlayer
        : null;
    return player;
  }

  void onTapNikeName(RoomPlayer roomPlayer, RoomMsg _chatRoom) {
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

//创建聊天内容的文本组织信息
  void makeBaseLineInfo(RoomMsg msg, RoomPlayer player) {
    // static const int Chat_none = 0; //无
    // static const int Chat_text = 1; //文本
    // static const int Chat_pic = 2; //图像
    // static const int Chat_voice = 3; //语音
    // static const int Chat_video = 4; //视频
    // static const int Chat_face = 5; //表情
    // static const int Chat_file = 6; //文件
    // static const int Chat_location = 7; //地理位置
    // static const int Chat_sys = 8; //系统消息
    // static const int Chat_custom = 9; //自定义
    // static const int Chat_light = 10; //点亮
    String content = roomMsg.getValue('content', null);
    String baseStr = '';
    Map<String, dynamic> data = jsonDecode(content);
    if (data.containsKey('text')) {
      baseStr = data['text'];
    }

    textContent = _addNikeName(msg, player) + baseStr;

    int lv = player.level;
    double rw = (25 / 2).w;
    if (lv < 10) {
      if (Platform.isAndroid) {
        rw = 18.w;
      } else {
        rw = 15.w;
      }
    } else if (lv > 90 && lv < 100) {
      rw = 18.w;
    }
    addIconTittleToHead(
      TittleBaseIcon(
        titleLen: lv >= 100 ? 4 : 3,
        //这里需要优化，如果是100级以上需要加长一个字，还要讨论
        url: 'assets/new_rank/${getNewRankIcon(player.level)}.png',
        textStyle: baseStyle,
        boxRect: Rect.fromLTRB(lv >= 100 ? 4.w : 0.w, 0.w, -2.w, 0.w),
        pos: Offset(28.w - rw, 2.w),
        title: '${player.level}',
      ),
    );

    //国王图标，网络地址
    String vipIconUrl = getVipIconUrl(player.vipLevel);
    if (vipIconUrl.isNotEmpty) {
      // var src = ImageLoadManager().serviceUpload.cdnUrl(vipIconUrl);
      addIconTittleToHead(
        TittleBaseIcon(
          titleLen: 4,
          url: 'assets/new_rank/rank_61_70.png',
          textStyle: baseStyle,
          boxRect: Rect.fromLTRB(0.w, 0.w, -2.w, 0.w),
          pos: Offset(14.w, 2.w),
          title: "国王",
        ),
      );
    }
    //是否为国王，应该判断是管理者
    if (player.roomAdmin > 0) {
      addIconTittleToHead(
        HeadBaseIcon(
          boxRect: Rect.fromLTRB(-2.w, 0.w, -2.w, 0.w),
          titleLen: 2,
          url: 'assets/common/room_admin.png',
          textStyle: baseStyle,
        ),
      );
    }
    //幸运
    if (player.luckNum != null && player.luckNum! > 0) {
      addIconTittleToHead(
        HeadBaseIcon(
          titleLen: 2,
          boxRect: Rect.fromLTRB(-2.w, 0.w, -2.w, 0.w),
          url: 'assets/common/icon_luckey_num.png',
          textStyle: baseStyle,
        ),
      );
    }
    if (player.userDefend > 0) //守护图标
    {
      addIconTittleToHead(
        TittleBaseIcon(
          titleLen: 2,
          url: 'assets/live_game/gametype_v3/panlu/bg_red.png',
          textStyle: baseStyle,
          boxRect: Rect.fromLTRB(-2.w, 0.w, -2.w, 0.w),
          pos: Offset(0.w, 4.w),
          title: "守",
        ),
      );
    }
  }

  //有Roomplayer  有roomMsg.id的消息
  void createSysAndNoticeView(RoomMsg msg, RoomPlayer player) {
    // static const int Chat_none = 0; //无
    // static const int Chat_text = 1; //文本
    // static const int Chat_pic = 2; //图像
    // static const int Chat_voice = 3; //语音
    // static const int Chat_video = 4; //视频
    // static const int Chat_face = 5; //表情
    // static const int Chat_file = 6; //文件
    // static const int Chat_location = 7; //地理位置
    // static const int Chat_sys = 8; //系统消息
    // static const int Chat_custom = 9; //自定义
    // static const int Chat_light = 10; //点亮
    if (msg.contentType == ChatType.Chat_sys) {
      makeBaseLineInfo(msg, player);
    } else if (msg.contentType == ChatType.Chat_text) {
      makeBaseLineInfo(msg, player);
    } else {
      String content = roomMsg.getValue('content', null);
      Map<String, dynamic> data = jsonDecode(content);
      if (data.containsKey('text')) {
        textContent = '${msg.contentType}:' + data['text'];
      } else {
        textContent = '没有Text数据';
      }
    }
  }
}
