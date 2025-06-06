//聊天消息

import 'dart:convert';
import 'dart:io';

import 'package:common_base/common_base.dart';

import 'package:data_center/live_old/model/data_manager.dart';

import 'package:data_center/live_old/model/room_msg.dart';
import 'package:data_center/live_old/model/room_player.dart';

import 'package:data_center/live_old/utility/colors.dart';
import 'package:data_center/live_old/utility/string.dart';

import 'package:data_center/live_old/widget/style_widget.dart';

import 'package:data_center/utils/chat_utils.dart';
import 'package:flutter/material.dart';
import 'package:live/page/home/room/sliver_chat/chatcell/chat_event_class.dart';
import 'package:live/page/home/room/sliver_chat/view/head_base_icon.dart';

import '../view/end_base_icon.dart';
import '../view/tittle_base_icon.dart';
import '../view/base_text_link.dart';

import 'model_pack.dart';

class RoomChatText extends BaseTextLink {
  //聊天记录对象
  final RoomMsg roomMsg;
  final ModelPack modelPack;

  RoomChatText({
    required this.roomMsg,
    required this.modelPack,
    required super.baseStyle, required super.maxWidth,
  });

  @override
  void initData() {

    RoomPlayer? player = getRoomPlayerByUserId(roomMsg.userId);
    RoomMsg msg = roomMsg;
    String content = roomMsg.data['content'] ?? '';
    Map<String, dynamic> temp = jsonDecode(content);
    if (roomMsg.contentType == ChatType.Chat_text) {
      _makeChatText(msg, player!);
      return;
    }else if (roomMsg.contentType == ChatType.Chat_sys) {
      _makeChatSys(msg, player!,temp);
      return;
    }
    //默认程序不应该到这里，将逐条补充内容
    textContent='未知--> roomMsg.contentType = ${roomMsg.contentType }  roomMsg.id  =${roomMsg.id} ';

    if (roomMsg.id! < 0) {
      _addSysIcon('系统');
      if (temp.containsKey('text')&&((temp['text']).toString()).length>0) {
        textContent = (temp['text']);
      }else{
        textContent='信息内容为空。roomMsg.contentType = ${roomMsg.contentType }  roomMsg.id  =${roomMsg.id} ';
      }
    }
  }

  //单纯给文本设置颜色，第一次添加都必按顺序排列在文本结构中
  String _selLinksStr(String str, Color color) {
    links.add({
      'text': str,
      'color': color,
    });
    return str;
  }


  //添加用户名，并按等级设置颜色 包含点击
  String _addNikeNameAndTap(RoomMsg msg, RoomPlayer player) {
    links.add({
      'text': player.nickname,
      'onTap': () {
        print('有点击头像事件。');
        ChatEventClass().onTapNikeName(player, msg, modelPack);
      },
      'color': player.vipLevel > 0 ? Colours.chat_user_vip : Colours.text_blue,
    });
    return player.nickname;
  }
  void _makeChatSys(RoomMsg msg, RoomPlayer player,Map<String, dynamic>  temp){
    int value = temp['optcode'] ?? 0;
    if (value == ChatContentType.ChatContent_caipiaoXiazhu) {
      _addSysIcon('系统');
      String nikeName = _addNikeNameAndTap(msg, player);
      String cpType = _selLinksStr(temp['cp_type_string'], Colours.text_yellow);
      String totalAmount = _selLinksStr(((temp['total_amount']) / 1.0).toString(), Colours.text_yellow);
      textContent = '用户${nikeName}在${cpType}的玩法中，已成功下注${totalAmount}元';
      //添加跟注按钮，
      addEndImageArr(
        EndBaseIcon(
            titleLen: 3,
            url: 'assets/live_game/gentou.png',
            textStyle: baseStyle,
            boxRect: Rect.fromLTRB(-5.w, -6.w, 5.w, 6.w),
            onTap: () {
              ChatEventClass().onTapGetzhuEvent(temp, modelPack);
            }),
      );
    } else if (value == ChatContentType.ChatContent_caipiaoZhongjiang) {
      _addZhongjiangIcon('中奖');
      String nikeName = _addNikeNameAndTap(msg, player);
      String cp_name = _selLinksStr(temp['cp_name'], Colours.text_yellow);
      String pay_amount = _selLinksStr(((temp['pay_amount']) / 1.0).toString(), Colours.text_yellow);
      textContent = '恭喜${nikeName}在${cp_name}中了${pay_amount}元';
    } else {
      textContent = '未知数据 --- optcode = $value';
    }
  }

  //加系统图标
  void _addSysIcon(String value) {
    _addHeadBaseIcon(len: 3, imgUrl: 'assets/live_game/xitong.png');
  }

  //加中奖图标
  void _addZhongjiangIcon(String value) {
    _addHeadBaseIcon(len: 3, imgUrl: 'assets/live_game/zhongjiang.png');
  }

  //对头部图标的统一入口，只包含了图片，
  void _addHeadBaseIcon({required int len, required String imgUrl}) {
    addIconTittleToHead(
      HeadBaseIcon(
        titleLen: len,
        url: imgUrl,
        textStyle: baseStyle,
        boxRect: Rect.fromLTRB(0.w, 0.w, 0.w, 0.w),
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
  void _addUserLevelIcon(int level){
    int lv = level;

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
        url: 'assets/new_rank/${getNewRankIcon(lv)}.png',
        textStyle: baseStyle,
        boxRect: Rect.fromLTRB(lv >= 100 ? 4.w : 0.w, 0.w, -2.w, 0.w),
        pos: Offset(28.w - rw, 2.w),
        title: '$lv',
      ),
    );
  }

//创建聊天内容的文本组织信息
  void _makeChatText(RoomMsg msg, RoomPlayer player) {
    String content = roomMsg.getValue('content', null);
    String baseStr = '';
    Map<String, dynamic> data = jsonDecode(content);
    if (data.containsKey('text')) {
      baseStr = data['text'];
    }
    textContent = _addNikeNameAndTap(msg, player) + baseStr;
    _addUserLevelIcon( player.level);
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
}
