//聊天消息

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:common_base/common_base.dart';
import 'package:data_center/data_center.dart';
import 'package:data_center/live_old/generated/l10n.dart';

import 'package:data_center/live_old/model/data_manager.dart';
import 'package:data_center/live_old/model/item.dart';
import 'package:data_center/live_old/model/room.dart';

import 'package:data_center/live_old/model/room_msg.dart';
import 'package:data_center/live_old/model/room_player.dart';
import 'package:data_center/live_old/model/video.dart';
import 'package:data_center/live_old/utility/app_define_info.dart';

import 'package:data_center/live_old/utility/colors.dart';
import 'package:data_center/live_old/utility/string.dart';

import 'package:data_center/live_old/widget/style_widget.dart';
import 'package:data_center/models/chat/chat.dart';

import 'package:data_center/utils/chat_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:live/page/home/room/sliver_chat/chatcell/chat_event_class.dart';
import 'package:live/page/home/room/sliver_chat/view/head_base_icon.dart';

import '../view/end_base_icon.dart';
import '../view/free_base_icon.dart';
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
    required super.maxWidth,
    required super.textStyle,
  });

  //独家消息
  void _addDujiaXingxi() {
    fontBaseLeft = 80.w;
    UserChat anchor = modelPack.roomPageModel.anchor!;
    if (anchor.isLoveValueOn && !anchor.isFolder) {
      textContent = '主播私聊已开启！解锁即刻进入私密频\n道,与主播一对一亲密互动！';
    } else {
      textContent = '独家主播福利,等你来解锁！尽情畅享私\n密时刻,体验无与伦比的乐趣！';
    }
    //行距不一样。
    baseStyle = TextStyle(color: Colors.white, fontSize: 24.sp, height: 3.w);

    addEndImageArr(
      EndBaseIcon(
          url: 'assets/new_live_room/new_room_chat_card.png',
          boxRect: Rect.fromLTWH(0.w, 10.w, 100.w, 32.w),
          onTap: () {
            print('立即解锁');
            ChatEventClass().onJiesuo(modelPack);
          }),
    );

    addFreeImageArr(
      FreeBaseIcon(
          url: 'assets/live_room/room_chat_card_title.png',
          drawRect: Rect.fromLTWH(
            0.w,
            10.w,
            70.w,
            70.w,
          ),
          onTap: () {}),
    );
  }

  @override
  void initData() {
    if (roomMsg.id < 0) {
      _makeSpecialInfo(roomMsg);
    } else {
      RoomPlayer? player = getRoomPlayerByUserId(roomMsg.userId);
      if (roomMsg.contentType == ChatType.Chat_text) {
        //文本
        _makeChatText(roomMsg, player!);
      } else if (roomMsg.contentType == ChatType.Chat_sys) {
        //系统消息
        String content = roomMsg.data['content'] ?? '';
        Map<String, dynamic> temp = jsonDecode(content);
        _makeChatSys(roomMsg, player!, temp);
      } else {
        // _addSysIcon('系统');
        textContent = '未知消息 contentType = ${roomMsg.contentType}  id  =${roomMsg.id} ';
      }
    }
  }

  void _makeSpecialInfo(notice) {
    if (notice.id.abs() == 9999999) {
      //独家信息
      _addDujiaXingxi();
    } else if (notice.id.abs() == ChatContentType.ChatContent_simulate) {
      // pk
      _addSysIcon('系统');

      int startIndex = 0;
      String textSpans = '';
      while (startIndex < notice.content!.text!.length) {
        int poundIndex = notice.content!.text!.indexOf('#', startIndex);
        if (poundIndex != -1) {
          // 添加 # 前的文本
          textSpans += _selLinksStr(notice.content!.text!.substring(startIndex, poundIndex), Colours.text_blue);
          // 添加 # 内的文本
          int endIndex = notice.content!.text!.indexOf('#', poundIndex + 1);
          if (endIndex != -1) {
            textSpans += _selLinksStr(notice.content!.text!.substring(poundIndex + 1, endIndex), Colours.text_blue);
            startIndex = endIndex + 1;
          } else {
            // 没有匹配的 #，将剩余文本全部设置为白色
            textSpans += _selLinksStr(notice.content!.text!.substring(poundIndex + 1), Colours.text_blue);
            startIndex = notice.content!.text!.length;
          }
        } else {
          // 没有 #，将剩余文本全部设置为白色
          textSpans += _selLinksStr(notice.content!.text!.substring(startIndex), Colors.white);
          startIndex = notice.content!.text!.length;
        }
      }
      textContent = textSpans;
    } else if (notice.id.abs() == ChatContentType.ChatContext_tiaodan ||
        notice.id.abs() == ChatContentType.ChatContext_yuwangzhilun ||
        notice.id.abs() == ChatContentType.ChatContext_xinyuandan) {
      // static const int ChatContext_tiaodan = 9000; //跳蛋
      // static const int ChatContext_yuwangzhilun = 9001; //欲望之论
      // static const int ChatContext_xinyuandan = 9002; //心愿单

      String textSpans = '';
      _addHudongIcon('互动');
      RegExp exp = RegExp(r"#(\d)(.*?)#\1", multiLine: true);
      Iterable<RegExpMatch> matches = exp.allMatches(notice.content!.text!);
      for (var match in matches) {
        String matchGroupstr = match.group(2).toString();
        switch (match.group(1)) {
          case '1':
            textSpans = _selLinksStr(matchGroupstr, Colours.text_blue, onTap: () {
              Room _chatRoom = modelPack.roomPageModel.selfRoom;
              if ((notice.data['mysteryMan'] != null &&
                      notice.data['mysteryMan'] > 0 &&
                      notice.data['gameUserId'] != dataCenter.mainUser.id) &&
                  dataCenter.mainUser.isAdmin == 0) return;
              if (modelPack.roomMsgModel!.msgBuildContext == null) return;
              showModalBottomSheet(
                barrierColor: Colours.bottom_sheet_black_bg,
                backgroundColor: Colors.transparent,
                context: modelPack.chatContext,
                builder: (context) {
                  Widget _memberInfoNew = getMemberWidget!(_chatRoom.id, notice.data['gameUserId']);
                  return Container(
                      height: ScreenUtil().bottomBarHeight > 0 ? 615.w : 575.w,
                      child: ChangeNotifierProvider.value(value: modelPack.myFollowModel, child: _memberInfoNew));
                },
              );
            });
            break;
          case '2': //只要是2 的都是 白色文字
            textSpans = _selLinksStr(matchGroupstr, Colors.white);
            break;
          case '3':
            if (notice.id.abs() == ChatContentType.ChatContext_tiaodan) {
              textSpans = _selLinksStr(matchGroupstr, Colours.chat_tiaodan);
            } else if (notice.id.abs() == ChatContentType.ChatContext_yuwangzhilun) {
              textSpans = _selLinksStr(matchGroupstr, Colours.chat_yuwangzhilun);
            } else if (notice.id.abs() == ChatContentType.ChatContext_xinyuandan) {
              textSpans = _selLinksStr(matchGroupstr, Colours.chat_xinyuandan);
            }
            break;
          case '4':
            textSpans = _selLinksStr(matchGroupstr, Colours.chat_result);
            break;
        }
      }
      textContent = textSpans;
    } else if (notice.id.abs() == ChatContentType.ChatContext_tiaodan_connect) {
      //跳蛋(进直播间的连结消息)9003
      _addHudongIcon('互动');
      textContent = "主播已连接" + _selLinksStr('跳蛋', Colours.chat_tiaodan);
      addEndImageArr(
        EndBaseIcon(
            url: 'assets/live_game/tiaodou.png',
            boxRect: Rect.fromLTWH(5.w, 5.w, 86.w, 32.w),
            onTap: () {
              dataCenter.roomExtendMgr.callEggBuy();
            }),
      );
    } else {
      _addSysIcon('系统');
      if (roomMsg.contentType == ChatType.Chat_none) {
        String content = roomMsg.getValue('content', null);
        Map<String, dynamic> data = jsonDecode(content);
        textContent = data['text'] ?? '';
      } else {
        textContent = '2未知信息 - contentType = ${notice.contentType}  id  =${notice.id} ';
      }
    }
  }

  //单纯给文本设置颜色，第一次添加都必按顺序排列在文本结构中
  String _selLinksStr(String str, Color color, {FontWeight? fontWeight, VoidCallback? onTap}) {
    if (onTap == null) {
      links.add({
        'text': str,
        'color': color,
        'fontWeight': fontWeight,
      });
    } else {
      links.add({
        'text': str,
        'color': color,
        'onTap': onTap,
        'fontWeight': fontWeight,
      });
    }
    return str;
  }

  bool _isMysteryPlayer(RoomPlayer player) {
    return player.mysteryMan > 0 && player.id != dataCenter.mainUser.id;
  }

  //添加用户名，并按等级设置颜色 包含点击
  String _addNikeNameAndTap(RoomMsg msg, RoomPlayer player) {
    bool mystery = _isMysteryPlayer(player);
    String nickName = mystery ? '神秘人' : player.nickname;

    Color color = player.vipLevel > 0 ? Colours.chat_user_vip : Colours.text_blue;
    links.add({
      'text': nickName,
      'onTap': () {
        if (!mystery) {
          ChatEventClass().onTapNikeName(player, msg, modelPack);
        }
      },
      'color': color,
    });
    return nickName;
  }

  void _makeChatSys(RoomMsg msg, RoomPlayer player, Map<String, dynamic> temp) {
    RoomPlayer roomPlayer = player;

    int value = temp['optcode'] ?? 0;

    if (value == ChatContentType.ChatContent_jinyan) {
      //禁言 1
      var flag = (temp['time_str'] == null || temp['time_str'] == "");
      var isGlobal = (temp['room_id'] != null && temp['room_id'] == 0);
      var time_str = flag ? '' : temp['time_str'].toString();
      RoomPlayer? tempPlay = dataMgr.findObj(TableNames.roomPlayer, temp['user_id']) as RoomPlayer?;
      _addSysIcon('系统');
      if (tempPlay != null) {
        createPlayInfoView(tempPlay);
        var baseStr = flag ? S.current.l_id_10168 : (isGlobal ? S.current.l_id_14516 : S.current.l_id_10169);
        textContent = _addNikeNameAndTap(msg, tempPlay) + baseStr + _selLinksStr(time_str, Colors.red);
      } else {
        textContent = '禁言  RoomPlayer  为空';
      }
    } else if (value == ChatContentType.ChatContent_tiren) {
      //踢人 2
      _addSysIcon('系统');
      String nickname = _selLinksStr(temp['nickname'], Colours.text_blue);
      textContent = nickname + ':' + S.current.l_id_10174;
    } else if (value == ChatContentType.ChatContent_liwu) {
      //礼物 3
      Item? iteminfo;
      if (temp['count'] != null && temp['item_id'] != null) {
        iteminfo = dataMgr.find<Item>(TableNames.item, temp['item_id']);
      }
      String? s = iteminfo?.name ?? '';
      int id = iteminfo?.id ?? 0;
      if ((id >= 204 && id <= 206)) {
        _addSysIcon('系统');
        String nikeName = _addNikeNameAndTap(msg, player);
        String itemInfoName = _selLinksStr('[${iteminfo?.name}]', Color(0xfff4de98), fontWeight: FontWeight.w400);
        textContent = nikeName + S.current.l_id_14581 + itemInfoName + S.current.l_id_14582;
        //名字开通了xx，以后就是一家人；
      } else {
        String addStr = '';

        if (!(roomPlayer.mysteryMan > 0 && roomPlayer.id != dataCenter.mainUser.id)) {
          addStr = createPlayInfoView(roomPlayer);
        }
        String nikeName = _addNikeNameAndTap(msg, player);
        String itemInfoName = _selLinksStr('[$s]', Color(0xfff4de98), fontWeight: FontWeight.w400);
        String count = _selLinksStr(' x${temp['count']}', Color(0xfff4de98), fontWeight: FontWeight.w400);
        textContent = addStr + nikeName + ':' + S.current.l_id_10167 + itemInfoName + count;
        //名字送出礼物x数量
      }
    } else if (value == ChatContentType.ChatContent_guanzhu) {
      //关注 5
      _addSysIcon('系统');
      String nikeName = _addNikeNameAndTap(msg, player);
      String user_nickname = _selLinksStr(temp['user_nickname'], Colours.text_blue);
      textContent = '${nikeName}关注了${user_nickname}';
    } else if (value == ChatContentType.ChatContent_jinggao) {
      //警告 6
      if (temp['user_id'] == dataCenter.mainUser.id) {
        Future.delayed(const Duration(milliseconds: 500), () async {
          chatRoomWarningDialog?.call(modelPack.chatContext, temp['desc']);
        });
        return getTextSpan(
          S.current.l_id_14381 + temp['desc'],
          Colors.white,
          chatDefFontSize,
          FontWeight.w400,
        );
      }
      textContent = S.current.l_id_14381 + temp['desc'];
    } else if (value == ChatContentType.ChatContent_meiqian) {
      //付费房钱不够退出 9
      Future.delayed(const Duration(milliseconds: 300), () async {
        await chatLeaveHandler?.call(modelPack.chatContext);
        chatNoMomeyHandler?.call(modelPack.roomPageModel.selfRoom);
      });
      textContent = temp['desc'];
    } else if (value == ChatContentType.ChatContent_setadmin || value == ChatContentType.ChatContent_caneladmin) {
      //设置房管 11 //取消房管 12
      _addSysIcon('系统');
      String user_nickname = _selLinksStr(temp['user_nickname'], Colours.text_blue, fontWeight: FontWeight.w400);
      String desc = value == ChatContentType.ChatContent_setadmin ? S.current.l_id_10170 : S.current.l_id_10171;
      textContent = user_nickname + desc;
    } else if (value == ChatContentType.ChatContent_forceEndVideo ||
        value == ChatContentType.ChatContent_timeoutEndVideo ||
        value == ChatContentType.ChatContent_maintainEndVideo ||
        value == ChatContentType.ChatContent_changeUserEndVideo ||
        value == ChatContentType.ChatContent_banTimeoutEndVideo) {
      var reson = "";
      if (value == ChatContentType.ChatContent_forceEndVideo) {
        reson = S.current.l_id_14374;
      } else if (value == ChatContentType.ChatContent_timeoutEndVideo) {
        reson = S.current.l_id_14375;
      } else if (value == ChatContentType.ChatContent_maintainEndVideo) {
        reson = S.current.l_id_14376;
      } else if (value == ChatContentType.ChatContent_changeUserEndVideo) {
        reson = S.current.l_id_14377;
      } else if (value == ChatContentType.ChatContent_banTimeoutEndVideo) {
        reson = S.current.l_id_14378;
      }
      if (temp['user_id'] == dataCenter.mainUser.id) {
        textContent = S.current.l_id_14379 + reson;
        //弹框
        //直播助手的提示框没添加
      } else {
        textContent =
            '${msg.content!.text}' + _selLinksStr(S.current.l_id_14380, Colors.white, fontWeight: FontWeight.w600);
      }
    } else if (value == ChatContentType.ChatContent_shortId) {
      //短语 18
      if (temp['short_id'] != null) {
        int idx = temp['short_id'];
        var paraseList = dataMgr.chatPhrase;
        //如果大于主播短语索引，则取主播短语数组
        if (idx >= AppDefines.PODCAST_CHAT_PHRASE_BEGIN_IDX) {
          paraseList = dataMgr.podcastChatPhrase;
          idx -= AppDefines.PODCAST_CHAT_PHRASE_BEGIN_IDX;
        }
        //显示相应短语
        if (idx < paraseList.length) {
          String addStr = createPlayInfoView(player);
          textContent = addStr + _addNikeNameAndTap(msg, player) + ':' + paraseList[idx];
        }
      } else {
        textContent = '未知数据 --- optcode = $value';
      }
    } else if (value == ChatContentType.ChatContent_caipiaoXiazhu) {
      //彩票下注19
      _addSysIcon('系统');
      String nikeName = _addNikeNameAndTap(msg, player);
      String cpType = _selLinksStr(temp['cp_type_string'], Colours.text_yellow, fontWeight: FontWeight.w600);
      String totalAmount = _selLinksStr(((temp['total_amount']) / 1.0).toString(), Colours.text_yellow);
      textContent = '用户${nikeName}在${cpType}玩法中，已成功下注了${totalAmount}元 ';
      //添加跟投按钮，
      if (LiveGameType.GameNoGenTou.contains(temp['cp_type'])) {
      } else {
        addEndImageArr(
          EndBaseIcon(
              url: 'assets/live_game/gentou.png',
              boxRect: Rect.fromLTWH(5.w, 5.w, 66.w, 32.w),
              onTap: () {
                ChatEventClass().onTapGetzhuEvent(temp, modelPack);
              }),
        );
      }
    } else if (value == ChatContentType.ChatContent_caipiaoZhongjiang) {
      // 彩票中奖 20
      _addZhongjiangIcon('中奖');
      String nikeName = _addNikeNameAndTap(msg, player);
      String cp_name = _selLinksStr(temp['cp_name'], Colours.text_yellow, fontWeight: FontWeight.w600);
      String pay_amount = _selLinksStr(((temp['pay_amount']) / 1.0).toString(), Colours.text_yellow);
      textContent = '恭喜${nikeName}在${cp_name}中了${pay_amount}元';
    } else if (value == ChatContentType.ChatContent_caipiaoZhongjiangEffect) {
      // 彩票中奖特效 21
      _addCaiJinIcon('彩金');
      String pay_amount = _selLinksStr(((temp['pay_amount']) / 1.0).toString(), Colours.text_yellow);
      textContent = '恭喜您中奖了获得彩金$pay_amount元';
    } else if (value == ChatContentType.ChatContent_caipiaoZhongjiangFenHong) {
      // 彩票中奖主播分红 22
      _addCaiJinIcon('彩金');
      String total_pay_amout = _selLinksStr(((temp['total_pay_amout']) / 1.0).toString(), Colors.red);
      textContent = '恭喜获得彩金分红$total_pay_amout火力';
    } else if (value == ChatContentType.ChatContent_xinyuandan) {
    } else {
      textContent = '未知数据 --- optcode = $value';
    }
  }

  //加系统图标
  void _addSysIcon(String value) {
    _addHeadBaseIcon(len: 6, imgUrl: 'assets/live_game/xitong.png');
  }

  //加互动图标
  void _addHudongIcon(String value) {
    _addHeadBaseIcon(len: 6, imgUrl: 'assets/new_live_room/hudong.png');
  }

  //加中奖图标
  void _addZhongjiangIcon(String value) {
    _addHeadBaseIcon(len: 6, imgUrl: 'assets/live_game/zhongjiang.png');
  }

  void _addCaiJinIcon(String value) {
    _addHeadBaseIcon(len: 6, imgUrl: 'assets/live_game/caijin.png');
  }

  //对头部图标的统一入口，只包含了图片，
  void _addHeadBaseIcon({required int len, required String imgUrl}) {
    addIconTittleToHead(
      HeadBaseIcon(
        titleLen: len,
        url: imgUrl,
        textStyle: baseStyle!,
        boxRect: Rect.fromLTWH(0.w, 0.w, 66.w, 32.w),
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

  _addUserLevelIcon(int level) {
    int lv = level;

    double lw = 12.w;
    int titleLen = 7; //3.2;
    String addStr = ""; //空格偏移
    Rect rect = Rect.fromLTWH(0.w, 2.w, 76.w, 28.w);
    if (lv < 10) {
      lw = 16.w;
      rect = Rect.fromLTWH(0.w, 2.w, 72.w, 28.w);
      addStr = ' ';
      titleLen = 6; //3.1;
    } else if (lv > 90 && lv < 100) {
      lw = 15.w;
      rect = Rect.fromLTWH(0.w, 0.w, 86.w, 30.w);
      addStr = "";
      titleLen = 7; //3.6;
    } else if (lv >= 100) {
      lw = 18.w;
      rect = Rect.fromLTWH(0.w, 0.w, 86.w, 30.w);
      addStr = "";
      titleLen = 8; //3.6;
    }

    addIconTittleToHead(
      TittleBaseIcon(
        titleLen: titleLen,
        url: 'assets/new_rank/${getNewRankIcon(lv)}.png',
        textStyle: baseStyle!,
        boxRect: rect,
        pos: Offset(lw, 0.w),
        title: '$lv',
      ),
    );
    //返回因等级的变化图标的宽度引起的偏移，在titleLen中已表现了icon的宽度
  }

  //用户多个icon
  createPlayInfoView(RoomPlayer player) {
    if (_isMysteryPlayer(player)) {
      return;
    }
    _addUserLevelIcon(player.level);
    //国王图标，网络地址
    String vipIconUrl = getVipIconUrl(player.vipLevel);
    if (vipIconUrl.isNotEmpty) {
      // var src = ImageLoadManager().serviceUpload.cdnUrl(vipIconUrl);
      addIconTittleToHead(
        TittleBaseIcon(
          titleLen: 8,
          url: 'assets/new_rank/rank_61_70.png',
          textStyle: baseStyle!,
          boxRect: Rect.fromLTWH(0.w, 0.w, 86.w, 32.w),
          pos: Offset(14.w, 4.w),
          title: "国王",
        ),
      );
    }
    int num3 = 3;
    //，应该判断是管理者
    if (player.roomAdmin > 0) {
      addIconTittleToHead(
        HeadBaseIcon(
          boxRect: Rect.fromLTWH(5.w, 5.w, 26.w, 26.w),
          titleLen: num3,
          url: 'assets/common/room_admin.png',
          textStyle: baseStyle!,
        ),
      );
    }
    //幸运
    if (player.luckNum != null && player.luckNum! > 0) {
      addIconTittleToHead(
        HeadBaseIcon(
          titleLen: num3,
          boxRect: Rect.fromLTWH(5.w, 5.w, 26.w, 26.w),
          url: 'assets/common/icon_luckey_num.png',
          textStyle: baseStyle!,
        ),
      );
    }
    if (player.userDefend > 0) //守护图标
    {
      addIconTittleToHead(
        HeadBaseIcon(
          titleLen: num3,
          boxRect: Rect.fromLTWH(5.w, 5.w, 26.w, 26.w),
          url: 'assets/common/icon_luckey_num.png',
          textStyle: baseStyle!,
        ),
      );
    }
  }

//创建聊天内容的文本组织信息
  void _makeChatText(RoomMsg msg, RoomPlayer player) {
    String content = roomMsg.getValue('content', null);
    String baseStr = '';
    Map<String, dynamic> data = jsonDecode(content);
    if (data.containsKey('text')) {
      baseStr = data['text'];
    }
    createPlayInfoView(player);
    textContent = _addNikeNameAndTap(msg, player) + ':' + baseStr;
  }
}
