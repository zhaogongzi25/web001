//聊天消息

import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:common_base/common_base.dart';

import 'package:data_center/live_old/model/data_manager.dart';

import 'package:data_center/live_old/model/room_msg.dart';
import 'package:data_center/live_old/model/room_player.dart';

import 'package:data_center/live_old/utility/colors.dart';
import 'package:data_center/live_old/utility/string.dart';
import 'package:data_center/live_old/widget/style_widget.dart';
import 'package:data_center/utils/chat_utils.dart';
import 'package:flutter/material.dart';
import 'package:live/page/home/room/sliver_chat/icon/base_icon.dart';
import 'package:live/page/home/room/sliver_chat/vo/image_load_manager.dart';

import '../icon/tittle_base_icon.dart';
import 'base_text_link.dart';

class RoomMsgChat extends BaseTextLink {
  final RoomMsg roomMsg;


  RoomMsgChat(this.roomMsg,{  required super.baseStyle,});

  @override
  void initData() {
    maxWidth = 600.w;
    links = [];
    String content = roomMsg.getValue('content', null);

    // textContent=   roomMsg.getValue('text');
    Map<String, dynamic> data = jsonDecode(content);

    if (data.containsKey('text')) {
      textContent = data['text'];
    } else {
      textContent = '没有Text数据';
      if (data['optcode'] == 30) {
        textContent = content;
      } else {
        textContent = '没有Text数据';
      }
    }
    if (roomMsg.id! < 0) {
      textContent = '独家主播福利,等你来解锁！尽情畅享私\n密时刻,体验无与伦比的乐趣！';
    } else {
      ///普通消息
      RoomPlayer? player =
          dataMgr.findObj(TableNames.roomPlayer, roomMsg.userId) != null
              ? dataMgr.findObj(TableNames.roomPlayer, roomMsg.userId)
                  as RoomPlayer
              : null;
      if (player != null) {
        createSysAndNoticeView(roomMsg, player);

      } else {
        ///内存里没有的对象，走
        // textContent = '内存里没有的对象';
      }
    }
  }

  void makeBaseLineInfo(RoomMsg msg, RoomPlayer player) {
    String content = roomMsg.getValue('content', null);
    String baseStr = '';
    Map<String, dynamic> data = jsonDecode(content);

    if (data.containsKey('text')) {
      baseStr = data['text'];
    }
    textContent = '${player.nickname}:' + baseStr;
    links!.add({
      'text': player.nickname,
      'onTap': () {
        print('点中了用户名   ${player.nickname}');
      },
      'color': player.vipLevel > 0 ? Colours.chat_user_vip : Colours.text_blue,
    });

    //等级
    addHeadImageArr(
      TittleBaseIcon(
        titleLen: 3,
        url: 'assets/new_rank/${getNewRankIcon(player.level)}.png',
        textStyle: baseStyle,
        boxRect: Rect.fromLTRB(0, 0, -2, 0),
        title: "${player.level}",
        pos: Offset(10,2),
      ),
    );
    //国王图标，网络地址
    String vipIconUrl = getVipIconUrl(player.vipLevel);
    if (vipIconUrl.isNotEmpty) {
      var src = ImageLoadManager().serviceUpload.cdnUrl(vipIconUrl);
      addHeadImageArr(
        TittleBaseIcon(
          titleLen: 4,
          // url:'http://res.banana888.ninja:89/files/admin_res/2025052413/pic/a18afcb70a54132c08c9c6483aa96a55.png',
          url: 'assets/new_rank/rank_61_70.png',
          textStyle: baseStyle,
          boxRect: Rect.fromLTRB(0, 0, 0, 0),
          pos: Offset(10,2),
          title: "国王",
        ),
      );
    }

    //是否为国王，应该判断是管理者
    if (player.roomAdmin > 0) {
      addHeadImageArr(
        BaseIcon(
          boxRect: Rect.fromLTRB(-2, 0, -2, 0),
          titleLen: 2,
          url: 'assets/common/room_admin.png',
          textStyle: baseStyle,
        ),
      );
    }
    //幸运
    if (player.luckNum != null && player.luckNum! > 0) {
      addHeadImageArr(
        BaseIcon(
          titleLen: 2,
          boxRect: Rect.fromLTRB(-2, 0, -2,0),
          url: 'assets/common/icon_luckey_num.png',
          textStyle: baseStyle,
        ),
      );
    }
    if (player.userDefend > 0) //守护图标
    {

      addHeadImageArr(
        TittleBaseIcon(
          titleLen: 2,
          url: 'assets/live_game/gametype_v3/panlu/bg_red.png',
          textStyle: baseStyle,
          boxRect: Rect.fromLTRB(-2, 0, -2, 0),
          pos: Offset(0,4),
          title: "守",
        ),
      );
    }

  }

  //有Roomplayer  有roomMsg.id的消息
  void createSysAndNoticeView(RoomMsg msg, RoomPlayer player) {

    String content = roomMsg.getValue('content', null);
    Map<String, dynamic> data = jsonDecode(content);

    if (msg.contentType == ChatType.Chat_text) {
      textContent = ' ${msg.contentType} :' + data['text'];
    }
    // static const int Chat_sys = 8; //系统消息
    if (msg.contentType == ChatType.Chat_sys) {
      makeBaseLineInfo(msg, player);
    }
    if (msg.contentType == ChatType.Chat_text) {
      makeBaseLineInfo(msg, player);
    }
  }
}
