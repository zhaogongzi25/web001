//聊天消息

import 'dart:convert';
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
import 'package:live/page/home/room/sliver_chat/view/head_base_icon.dart';

import '../view/level_base_icon.dart';
import '../view/tittle_base_icon.dart';
import '../view/base_text_link.dart';

class RoomChatText extends BaseTextLink {
  //聊天记录对象
  final RoomMsg roomMsg;

  RoomChatText(
    this.roomMsg, {
    required super.baseStyle,
  });

  @override
  void initData() {
    links = [];
    maxWidth = 300.0; //可以改变但见意统一值

    if (roomMsg.id! < 0) {
      String content = roomMsg.getValue('content', null);
      Map<String, dynamic> data = jsonDecode(content);
      if (data.containsKey('text')) {
        makeNoticeInfo( data['text']);
      }else{
        makeNoticeInfo('独家主播福利,等你来解锁！尽情畅享私\n密时刻,体验无与伦比的乐趣！');
      }


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
  void makeNoticeInfo(String value){
    textContent=value;

      addIconTittleToHead(
        TittleBaseIcon(
          titleLen: 3,
          url: 'assets/new_live_room/wish_reward_btn.png',
          textStyle: baseStyle,
          boxRect: Rect.fromLTRB(5.w, 0.w, -2.w, 0.w),
          title: "系统",
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

//创建聊天内容的文本组织信息
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
        print('点中了用户名 ${msg.userId}    ${player.nickname}');
      },
      'color': player.vipLevel > 0 ? Colours.chat_user_vip : Colours.text_blue,
    });

    //等级
    addIconTittleToHead(
      LevelBaseIcon(
        titleLen: 3,
        url: 'assets/new_rank/${getNewRankIcon(player.level)}.png',
        textStyle: baseStyle,
        boxRect: Rect.fromLTRB(0.w, 0.w, -2.w, 0.w),
        level: player.level,
        pos: Offset(14.w, 2.w),
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
        textContent ='${msg.contentType}:' + data['text'];
      } else {
        textContent = '没有Text数据';
      }

    }
  }
}
