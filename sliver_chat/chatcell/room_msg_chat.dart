//聊天消息

import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:common_base/common_base.dart';
import 'package:data_center/live_old/model/data_manager.dart';
import 'package:data_center/live_old/model/item.dart';
import 'package:data_center/live_old/model/room_msg.dart';
import 'package:data_center/live_old/model/room_player.dart';
import 'package:data_center/live_old/utility/app_define_info.dart';
import 'package:data_center/live_old/utility/colors.dart';
import 'package:data_center/live_old/utility/string.dart';
import 'package:flutter/material.dart';
import 'package:live/page/home/room/sliver_chat/vo/base_titlle.dart';

import 'base_text_link.dart';

class RoomMsgChat extends BaseTextLink {
  final RoomMsg roomMsg;

  RoomMsgChat(this.roomMsg) {}

  @override
  void initData() {
 
    maxWidth = 500.w;
    links = [];
    String content = roomMsg.getValue('content', null);

    // textContent=   roomMsg.getValue('text');
    Map<String, dynamic> data = jsonDecode(content);
    print(content);
    if (data.containsKey('text')) {
      textContent = data['text'];
    } else {
      textContent = '没有Text数据';
      //{text: ❤️❤️‍🔥❤️❤️‍🔥❤️❤️‍🔥观看直播有风险，血压太高请找医生看病拿药。❤️❤️‍🔥❤️❤️‍🔥❤️❤️‍🔥}
      //{broken_id: 1197670397, user_id: 1682034565, cp_type: 10, notice_type: 1, pay_amount: 5880, optcode: 20, cp_name: 极速轮盘, app_user_id: 1002321579}
      // {{用戶餛飩nice}}完成了粉丝团任务{{「观看直播2分钟」}}, user_nickname: 用戶餛飩nice, create_time: 1748852054, optcode: 30, podcast_id: 1197670397, user_id: 1593260760}

      if (data['optcode'] == 30) {
        textContent = content;
      } else {
        textContent = '没有Text数据';
      }
    }
    

    if (roomMsg.id! < 0) {
      ///系统消息
      // textContent = '系统消息';
      textContent = '独家主播福利,等你来解锁！尽情畅享私\n密时刻,体验无与伦比的乐趣！';

      addHeadImageArr(
        BaseTittle(
          titleLen: 3,
          url: 'https://zhaogongzi25.github.io/web001/img001.png',
          fontSize: baseStyle.fontSize!,
          roundBox: Rect.fromLTRB(-2, -2, -2, 4),
          label: "系统",
        ),
      );
    } else {

      ///普通消息
      RoomPlayer? player =
          dataMgr.findObj(TableNames.roomPlayer, roomMsg.userId) != null
              ? dataMgr.findObj(TableNames.roomPlayer, roomMsg.userId)
                  as RoomPlayer
              : null;
      if (player != null ) {
        createSysAndNoticeView(roomMsg,player);

      } else {
        ///内存里没有的对象，走
        // textContent = '内存里没有的对象';

      }
    }
  }
  //有Roomplayer  有roomMsg.id的消息
  void createSysAndNoticeView(RoomMsg msg, RoomPlayer player){
    hide = false;
    String content = roomMsg.getValue('content', null);
    Map<String, dynamic> data = jsonDecode(content);
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

    textContent =' ${ msg.contentType} :' + data['text'];

    if (msg.contentType == ChatType.Chat_text) {
      textContent = ' ${ msg.contentType} :' + data['text'];
    }
    // static const int Chat_sys = 8; //系统消息
    if (msg.contentType == ChatType.Chat_sys) {

      Item? iteminfo;
      var tempCon = msg.data['content'] ?? '';
      Map<String, dynamic> temp;
      if (tempCon == '') {
        temp = {};
      } else {
        temp = jsonDecode(tempCon);
      }
      if (temp['count'] != null && temp['item_id'] != null) {
        // mypdebug('当前礼物id${temp['item_id']}');
        iteminfo = dataMgr.find<Item>(TableNames.item, temp['item_id']);
      }
      int value = temp['optcode'] ?? 0;
      // shaortid 有可能刚好是0
      if (msg.shortId != 0) {
        value = msg.optcode;
      } else if (msg.optcode == ChatContentType.ChatContent_shortId &&
          msg.shortId == 0) {
        value = msg.optcode;
      }
      if (value == ChatContentType.ChatContent_redbagSend) {

      } else if (value == ChatContentType.ChatContent_shortId) {
        if (temp['short_id'] != null) {
          int idx = temp['short_id'];
          msg.optcode = ChatContentType.ChatContent_shortId;
          msg.shortId = idx;
          var paraseList = dataMgr.chatPhrase;
          //如果大于主播短语索引，则取主播短语数组
          if (idx >= AppDefines.PODCAST_CHAT_PHRASE_BEGIN_IDX) {
            paraseList = dataMgr.podcastChatPhrase;
            idx -= AppDefines.PODCAST_CHAT_PHRASE_BEGIN_IDX;
          }
          //显示相应短语
          if (paraseList.length >= idx + 1) {
            Content c = msg.content!;
            c.text = paraseList[idx];
            msg.content = c;
          }
        }

      }


      textContent = '${player.nickname}:' + textContent!;
      links!.add({
        'text': player.nickname,
        'onTap': () { print('点中了用户名') ;},
        'color':Colours.text_blue,
      });
      addHeadImageArr(
        BaseTittle(
          titleLen: 3,
          url: 'https://zhaogongzi25.github.io/web001/rank_41_50.png',
          fontSize: baseStyle.fontSize!,
          // roundBox: Rect.fromLTRB(-2, -2, -2, 4),
          label: "${player.level}级",
        ),
      );
      if (player.id == msg.userId) {
        addHeadImageArr(
          BaseTittle(
            titleLen: 3,
            url: 'https://zhaogongzi25.github.io/web001/bg_146_60.png',
            fontSize: baseStyle.fontSize!,
            // roundBox: Rect.fromLTRB(-2, -2, -2, 4),
            label: "房主",
          ),
        );
      }

    }



  }
}
