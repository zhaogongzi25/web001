//聊天消息

import 'dart:convert';

import 'package:common_base/common_base.dart';
import 'package:data_center/data_center.dart';
import 'package:data_center/live_old/generated/l10n.dart';

import 'package:data_center/live_old/model/data_manager.dart';
import 'package:data_center/live_old/model/item.dart';
import 'package:data_center/live_old/model/room.dart';

import 'package:data_center/live_old/model/room_msg.dart';
import 'package:data_center/live_old/model/room_player.dart';

import 'package:data_center/live_old/utility/app_define_info.dart';

import 'package:data_center/live_old/utility/colors.dart';
import 'package:data_center/live_old/utility/string.dart';

import 'package:data_center/live_old/widget/style_widget.dart';
import 'package:data_center/models/chat/chat.dart';

import 'package:data_center/utils/chat_utils.dart';
import 'package:data_center/utils/sliver_chat/chatcell/room_chat_cell_vo.dart';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';

import '../../../live_old/model/video.dart';
import '../../../live_old/service/service_upload.dart';
import '../icon/end_base_icon.dart';
import '../icon/free_base_icon.dart';
import '../icon/head_base_icon.dart';
import '../icon/level_base_icon.dart';
import '../base/custom_base_text_link.dart';

import 'chat_event_class.dart';
import '../base/model_pack.dart';

class RoomChatText extends CustomBaseTextLink {
  //角色信息，特殊消息是没有角色信息的
  RoomPlayer? _voPlayer;

  //要显示的内容
  String? _textContent;

  RoomChatText({
    required super.roomChatCellVo,
    required super.maxWidth,
    required super.textStyle,
  });

  @override
  void initData() {
    RoomMsg roomMsg = roomChatCellVo.roomMsg;
    //当消息小于0时不需要有角色信息
    if (roomMsg.id < 0) {
      _makeSpecialInfo(roomMsg);
      setTextContentToRander(_textContent!);
    } else {
      //当id号不小于0就需要基础角色信息，需要先异步获取
      _getRoomPlayerByUserId(roomMsg.userId, (RoomPlayer? player) {
        _voPlayer = player;
        if (roomMsg.contentType == ChatType.Chat_text) {
          //文本
          _makeChatText(roomMsg);
        } else if (roomMsg.contentType == ChatType.Chat_sys) {
          //系统消息
          String content = roomMsg.data['content'] ?? '';

          if (content == '') {
            _textContent = '未知消息 content 内容为空';
          } else {
            Map<String, dynamic> temp = jsonDecode(content);
            _makeChatSys(roomMsg, temp);
          }
        } else {
          _textContent = '未知消息 contentType = ${roomMsg.contentType}  id  =${roomMsg.id} ';
        }
        setTextContentToRander(_textContent);
      });
    }
  }


  //独家消息
  void _addRoomCard() {
    ModelPack modelPack = roomChatCellVo.modelPack;
    fontBaseLeft = 80.w;
    dynamic roomPageModel = modelPack.roomPageModel;
    UserChat anchor = roomPageModel.anchor;
    if (anchor.isLoveValueOn && !anchor.isFolder) {
      _textContent = '主播私聊已开启！解锁即刻进入私密频\n道,与主播一对一亲密互动！';
    } else {
      _textContent = '独家主播福利,等你来解锁！尽情畅享私\n密时刻,体验无与伦比的乐趣！';
    }
    //行距不一样。
    baseStyle = TextStyle(color: Colors.white, fontSize: 24.sp, height: 3.2.w);
    addEndImageArr(
      EndBaseIcon(
          url: 'assets/new_live_room/new_room_chat_card.png',
          boxRect: Rect.fromLTWH(0.w, 10.w, 100.w, 32.w),
          onTap: () {
            ChatEventClass().onJiesuo(modelPack);
          },
          roomChatCellVo: roomChatCellVo),
    );

    addFreeImageArr(
      FreeBaseIcon(
          url: 'assets/live_room/room_chat_card_title.png',
          roomChatCellVo: roomChatCellVo,
          drawRect: Rect.fromLTWH(
            0.w,
            5.w,
            70.w,
            70.w,
          )),
    );
  }

//创建聊天内容的文本组织信息
  void _makeChatText(RoomMsg msg) {
    RoomPlayer? player = _voPlayer;
    RoomMsg roomMsg = roomChatCellVo.roomMsg;
    ModelPack modelPack = roomChatCellVo.modelPack;
    if (player == null) {
      _textContent = 'RoomPlayer is null ${roomMsg.userId} ';
    } else {
      String showText = msg.content?.text ?? '';
      if (showText.isNotEmpty && showText.startsWith(secrecyTag)) {
        //安全标记开头
        Room chatRoom = modelPack.roomPageModel.selfRoom;
        if (dataCenter.mainUser.id == chatRoom.id || //我是主播
            (msg.userId == dataCenter.mainUser.id)) {
          //消息是我自己发的)
          //去除开始标记
          showText = showText.substring(secrecyTag.length);
        } else {
          //直接隐藏内容
          showText = S.current.l_id_10165;
        }
      }
      _createPlayerIcon(player);
      String nikeName = _addNikeNameAndTap(msg, player);
      _textContent = '$nikeName:$showText';
    }
  }

  //添加特殊消息，id<0的走这里
  void _makeSpecialInfo(RoomMsg notice) {
    ModelPack modelPack = roomChatCellVo.modelPack;

    // if (notice.id != -9999999) {

    if (notice.id == -1) {
      //直接显示文本，前面加一个系统图标
      _addSysIcon(); //系统
      _textContent = notice.content!.text!;
    } else if (notice.id == -9999999) {
      //房卡
      _addRoomCard();
    } else {
      if (!notice.data.containsKey('userId')) {
        //没有userId 也就是异常信息
        _textContent = '未知信息 - contentType = ${notice.contentType}  id  =${notice.id} ';
        return;
      }
      //pk
      if (notice.data['userId'].abs() == ChatContentType.ChatContent_simulate) {
        _addSysIcon(); //互动
        int startIndex = 0;
        String textSpans = '';
        String contentTxt=notice.content!.text??'';
        while (startIndex < contentTxt.length) {
          int poundIndex = contentTxt.indexOf('#', startIndex);
          if (poundIndex != -1) {
            // 添加 # 前的文本
            textSpans += _selLinksStr(contentTxt.substring(startIndex, poundIndex), Colours.text_blue);
            // 添加 # 内的文本
            int endIndex = contentTxt.indexOf('#', poundIndex + 1);
            if (endIndex != -1) {
              textSpans += _selLinksStr(contentTxt.substring(poundIndex + 1, endIndex), Colours.text_blue);
              startIndex = endIndex + 1;
            } else {
              // 没有匹配的 #，将剩余文本全部设置为白色
              textSpans += _selLinksStr(contentTxt.substring(poundIndex + 1), Colours.text_blue);
              startIndex = contentTxt.length;
            }
          } else {
            // 没有 #，将剩余文本全部设置为白色
            textSpans += _selLinksStr(contentTxt.substring(startIndex), Colours.text_blue);
            startIndex = contentTxt.length;
          }
        }
        _textContent = textSpans;
      } else if (notice.data['userId'].abs() == ChatContentType.ChatContext_tiaodan ||
          notice.data['userId'].abs() == ChatContentType.ChatContext_yuwangzhilun ||
          notice.data['userId'].abs() == ChatContentType.ChatContext_xinyuandan) {
        //   ChatContext_tiaodan = 9000; //跳蛋
        //  ChatContext_yuwangzhilun = 9001; //欲望之论
        //  ChatContext_xinyuandan = 9002; //心愿单

        String textSpans = '';
        _addHuDongIcon(); //互动
        RegExp exp = RegExp(r"#(\d)(.*?)#\1", multiLine: true);
        Iterable<RegExpMatch> matches = exp.allMatches(notice.content!.text!);

        for (var match in matches) {
          String matchGroupstr = match.group(2).toString();

          switch (match.group(1)) {
            case '1':
              textSpans += _selLinksStr(matchGroupstr, Colours.text_blue, onTap: () {
                Room chatRoom = modelPack.roomPageModel.selfRoom;
                if ((notice.data['mysteryMan'] != null &&
                        notice.data['mysteryMan'] > 0 &&
                        notice.data['gameUserId'] != dataCenter.mainUser.id) &&
                    dataCenter.mainUser.isAdmin == 0) {
                  return;
                }

                if (modelPack.chatContext.mounted) {
                  showModalBottomSheet(
                    barrierColor: Colours.bottom_sheet_black_bg,
                    backgroundColor: Colors.transparent,
                    context: modelPack.chatContext,
                    builder: (context) {
                      Widget memberInfoNew = getMemberWidget!(chatRoom.id, notice.data['gameUserId']);
                      return SizedBox(
                          height: ScreenUtil().bottomBarHeight > 0 ? 615.w : 575.w,
                          child: ChangeNotifierProvider.value(value: modelPack.myFollowModel, child: memberInfoNew));
                    },
                  );
                }
              });
              break;
            case '2': //只要是2 的都是 白色文字
              textSpans += _selLinksStr(matchGroupstr, Colors.white);
              break;
            case '3':
              if (notice.data['userId'].abs() == ChatContentType.ChatContext_tiaodan) {
                textSpans += _selLinksStr(matchGroupstr, Colours.chat_tiaodan);
              } else if (notice.data['userId'].abs() == ChatContentType.ChatContext_yuwangzhilun) {
                textSpans += _selLinksStr(matchGroupstr, Colours.chat_yuwangzhilun);
              } else if (notice.data['userId'].abs() == ChatContentType.ChatContext_xinyuandan) {
                textSpans += _selLinksStr(matchGroupstr, Colours.chat_xinyuandan);
              }

              break;
            case '4':
              textSpans += _selLinksStr(matchGroupstr, Colours.chat_result);

              break;
          }
        }
        _textContent = textSpans;
      } else if (notice.data['userId'].abs() == ChatContentType.ChatContext_tiaodan_connect) {
        //跳蛋(进直播间的连结消息)9003
        _addHuDongIcon(); //互动
        String tiaoDan = _selLinksStr('跳蛋', Colours.chat_tiaodan);
        _textContent = "主播已连接 $tiaoDan";
        _addTiaoDouIcon(); //挑逗icon
      } else {
        _addSysIcon(); //系统
        if (notice.contentType == ChatType.Chat_none) {

          _textContent = notice.content!.text?? '';

        } else {
          _textContent = '未知信息 - contentType = ${notice.contentType}  id  =${notice.id} ';
        }
      }
    }
  }

  //单纯给文本设置颜色，每一次添加都必按顺序排列在文本结构中，⌚️列表需要和文本对应
  String _selLinksStr(String str, Color color, {FontWeight? fontWeight, VoidCallback? onTap}) {
    textLinks.add({
      'text': str,
      'color': color,
      'onTap': onTap,
      'fontWeight': fontWeight,
    });
    return str;
  }

  bool _isMysteryPlayer(RoomPlayer player) {
    return player.mysteryMan > 0 && player.id != dataCenter.mainUser.id;
  }

  //添加用户名，并按等级设置颜色 包含点击
  String _addNikeNameAndTap(RoomMsg msg, RoomPlayer? player) {
    if (player == null) {
      return 'null';
    }
    ModelPack modelPack = roomChatCellVo.modelPack;

    bool mystery = _isMysteryPlayer(player);
    String nickName = mystery ? '神秘人' : player.nickname;

    Color color = player.vipLevel > 0 ? Colours.chat_user_vip : Colours.text_blue;
    textLinks.add({
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

  //系统聊天消息
  void _makeChatSys(RoomMsg msg, Map<String, dynamic> temp) {
    RoomPlayer? player = _voPlayer;
    ModelPack modelPack = roomChatCellVo.modelPack;
    if (player == null) {
      _textContent = '异常数据 --- RoomPlayer is null = ${msg.userId}';
      return;
    }

    int optCode = temp['optcode'] ?? 0;
    // shaortid 有可能刚好是0
    if (msg.shortId != 0) {
      optCode = msg.optcode;
    } else if (msg.optcode == ChatContentType.ChatContent_shortId && msg.shortId == 0) {
      optCode = msg.optcode;
    }

    if (optCode == ChatContentType.ChatContent_jinyan) {
      //禁言 1
      var flag = (temp['time_str'] == null || temp['time_str'] == "");
      var isGlobal = (temp['room_id'] != null && temp['room_id'] == 0);
      var timeStr = flag ? '' : temp['time_str'].toString();
      RoomPlayer? tempPlay = dataMgr.findObj(TableNames.roomPlayer, temp['user_id']) as RoomPlayer?;
      _addSysIcon(); //系统
      if (tempPlay != null) {
        _createPlayerIcon(tempPlay);
        var baseStr = flag ? S.current.l_id_10168 : (isGlobal ? S.current.l_id_14516 : S.current.l_id_10169);
        String nikeName = _addNikeNameAndTap(msg, player);
        _textContent = nikeName + baseStr + _selLinksStr(timeStr, Colors.red);
      } else {
        _textContent = '禁言  RoomPlayer  为空';
      }
    } else if (optCode == ChatContentType.ChatContent_tiren) {
      //踢人 2
      _addSysIcon(); //系统
      String nickName = _selLinksStr(temp['nickname'], Colours.text_blue);
      _textContent = '$nickName:$S.current.l_id_10174';
    } else if (optCode == ChatContentType.ChatContent_liwu) {
      RoomPlayer? roomPlayer = player;
      //礼物 3
      Item? iteminfo;
      if (temp['count'] != null && temp['item_id'] != null) {
        iteminfo = dataMgr.find<Item>(TableNames.item, temp['item_id']);
      }
      String? s = iteminfo?.name ?? '';
      int id = iteminfo?.id ?? 0;
      if ((id >= 204 && id <= 206)) {
        _addSysIcon(); //系统
        String nikeName = _addNikeNameAndTap(msg, player);
        String itemInfoName = _selLinksStr('[${iteminfo?.name}]', Color(0xfff4de98), fontWeight: FontWeight.w400);
        _textContent = nikeName + S.current.l_id_14581 + itemInfoName + S.current.l_id_14582;
        //名字开通了xx，以后就是一家人；
      } else {
        if (!(roomPlayer.mysteryMan > 0 && roomPlayer.id != dataCenter.mainUser.id)) {
          _createPlayerIcon(roomPlayer);
        }
        String nikeName = _addNikeNameAndTap(msg, player);
        String itemInfoName = _selLinksStr('[$s]', Color(0xfff4de98), fontWeight: FontWeight.w400);
        String count = _selLinksStr(' x${temp['count']}', Color(0xfff4de98), fontWeight: FontWeight.w400);
        _textContent = '$nikeName:${S.current.l_id_10167}$itemInfoName$count';
      }
    } else if (optCode == ChatContentType.ChatContent_guanzhu) {
      //关注 5

      _addSysIcon(); //系统
      String nikeName = _addNikeNameAndTap(msg, player);
      String userNickname = _selLinksStr(temp['user_nickname'], Colours.text_blue);
      _textContent = '$nikeName关注了$userNickname';
    } else if (optCode == ChatContentType.ChatContent_jinggao) {
      //警告 6
      if (temp['user_id'] == dataCenter.mainUser.id) {
        Future.delayed(const Duration(milliseconds: 500), () async {
          chatRoomWarningDialog?.call(modelPack.chatContext, temp['desc']);
        });
      }
      _textContent = S.current.l_id_14381 + temp['desc'];
    } else if (optCode == ChatContentType.ChatContent_meiqian) {
      //付费房钱不够退出 9
      // 弹窗逻辑不走这里
      // Future.delayed(const Duration(milliseconds: 300), () async {
      //   await chatLeaveHandler?.call(modelPack.chatContext);
      //   chatNoMomeyHandler?.call(modelPack.roomPageModel.selfRoom);
      // });
      _textContent = temp['desc'];
    } else if (optCode == ChatContentType.ChatContent_setadmin || optCode == ChatContentType.ChatContent_caneladmin) {
      //设置房管 11 //取消房管 12
      _addSysIcon(); //系统
      String userNickname = _selLinksStr(temp['user_nickname'], Colours.text_blue, fontWeight: FontWeight.w400);
      String desc = optCode == ChatContentType.ChatContent_setadmin ? S.current.l_id_10170 : S.current.l_id_10171;
      _textContent = userNickname + desc;
    } else if (optCode == ChatContentType.ChatContent_forceEndVideo ||
        optCode == ChatContentType.ChatContent_timeoutEndVideo ||
        optCode == ChatContentType.ChatContent_maintainEndVideo ||
        optCode == ChatContentType.ChatContent_changeUserEndVideo ||
        optCode == ChatContentType.ChatContent_banTimeoutEndVideo) {
      var reson = "";
      if (optCode == ChatContentType.ChatContent_forceEndVideo) {
        reson = S.current.l_id_14374;
      } else if (optCode == ChatContentType.ChatContent_timeoutEndVideo) {
        reson = S.current.l_id_14375;
      } else if (optCode == ChatContentType.ChatContent_maintainEndVideo) {
        reson = S.current.l_id_14376;
      } else if (optCode == ChatContentType.ChatContent_changeUserEndVideo) {
        reson = S.current.l_id_14377;
      } else if (optCode == ChatContentType.ChatContent_banTimeoutEndVideo) {
        reson = S.current.l_id_14378;
      }
      if (temp['user_id'] == dataCenter.mainUser.id) {
        //弹框
        Future.delayed(const Duration(milliseconds: 500), () async {
          modelPack.roomPagePodCastModel?.setStatus(PagePodcastStauts.closed, reason: EndVideoReason.imNotice);
          modelPack.roomPagePodCastModel?.statusMsg = S.current.l_id_14379 + reson;
        });
        _textContent = S.current.l_id_14379 + reson;
      } else {
        _textContent =
            '${msg.content!.text}${_selLinksStr(S.current.l_id_14380, Colors.white, fontWeight: FontWeight.w600)}';
      }
    } else if (optCode == ChatContentType.ChatContent_shortId) {
      //短语 18
      String str = '${msg.content!.text}';
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
          str = paraseList[idx];
        }
      }
      _createPlayerIcon(player);
      String nikeName = _addNikeNameAndTap(msg, player);
      _textContent = '$nikeName:$str';
    } else if (optCode == ChatContentType.ChatContent_caipiaoXiazhu) {
      //彩票下注19

      _addSysIcon(); //系统
      String nikeName = _addNikeNameAndTap(msg, player);
      String cpType = _selLinksStr(temp['cp_type_string'], Colours.text_yellow, fontWeight: FontWeight.w600);
      String totalAmount = _selLinksStr(((temp['total_amount']) / 1.0).toString(), Colours.text_yellow);
      _textContent = '用户$nikeName在$cpType玩法中，已成功下注了$totalAmount元 ';
      //添加跟投按钮，

      if (LiveGameType.GameNoGenTou.contains(temp['cp_type'])) {
      } else {
        addEndImageArr(
          EndBaseIcon(
              url: 'assets/live_game/gentou.png',
              boxRect: Rect.fromLTWH(5.w, 5.w, 66.w, 32.w),
              onTap: () {
                ChatEventClass().onTapGetzhuEvent(temp, roomChatCellVo.modelPack);
              },
              roomChatCellVo: roomChatCellVo),
        );
      }
    } else if (optCode == ChatContentType.ChatContent_caipiaoZhongjiang) {
      // 彩票中奖 20

      _addZhongJiangIcon(); //中奖
      String nikeName = _addNikeNameAndTap(msg, player);
      String cpName = _selLinksStr(temp['cp_name'], Colours.text_yellow, fontWeight: FontWeight.w600);
      String payAmount = _selLinksStr(((temp['pay_amount']) / 1.0).toString(), Colours.text_yellow);
      _textContent = '恭喜$nikeName在$cpName中了$payAmount元';
    } else if (optCode == ChatContentType.ChatContent_caipiaoZhongjiangEffect) {
      // 彩票中奖特效 21
      _addCaiJinIcon(); //彩金
      String payAmount = _selLinksStr(((temp['pay_amount']) / 1.0).toString(), Colours.text_yellow);
      _textContent = '恭喜您中奖了获得彩金$payAmount元';
    } else if (optCode == ChatContentType.ChatContent_caipiaoZhongjiangFenHong) {
      // 彩票中奖主播分红 22
      _addCaiJinIcon(); //彩金
      String totalPayAmout = _selLinksStr(((temp['total_pay_amout']) / 1.0).toString(), Colors.red);
      _textContent = '恭喜获得彩金分红$totalPayAmout火力';
    } else {
      _textContent = '异常数据    ${msg.optcode} --${msg.contentType}';
    }
  }

  //加系统图标
  void _addSysIcon() {
    _addHeadBaseIcon(imgUrl: 'assets/live_game/xitong.png');
  }

  //加互动图标
  void _addHuDongIcon() {
    _addHeadBaseIcon(imgUrl: 'assets/new_live_room/hudong.png');
  }

  //加中奖图标
  void _addZhongJiangIcon() {
    _addHeadBaseIcon(imgUrl: 'assets/live_game/zhongjiang.png');
  }

  void _addCaiJinIcon() {
    _addHeadBaseIcon(imgUrl: 'assets/live_game/caijin.png');
  }

  void _addTiaoDouIcon() {
    addEndImageArr(
      EndBaseIcon(
          url: 'assets/live_game/tiaodou.png',
          boxRect: Rect.fromLTWH(5.w, 5.w, 86.w, 32.w),
          onTap: () {
            dataCenter.roomExtendMgr.callEggBuy();
          },
          roomChatCellVo: roomChatCellVo),
    );
  }

  //对头部图标的统一入口，只包含了图片，
  void _addHeadBaseIcon({required String imgUrl}) {
    addIconTittleToHead(
      HeadBaseIcon(
        iconLen: 6,
        url: imgUrl,
        boxRect: Rect.fromLTWH(0.w, 0.w, 66.w, 32.w),
        roomChatCellVo: roomChatCellVo,
      ),
    );
  }

  //获取用户RoomPlayer
  void _getRoomPlayerByUserId(int userId, Function(RoomPlayer?) bFun) {
    // Future.delayed(Duration(milliseconds:3000), () {
    RoomPlayer? basePlayer = dataMgr.findObj(TableNames.roomPlayer, userId) != null
        ? dataMgr.findObj(TableNames.roomPlayer, userId) as RoomPlayer
        : null;
    if (basePlayer == null) {
      ModelPack modelPack = roomChatCellVo.modelPack;
      int roomId = modelPack.roomPageModel.curRoomInfo.id!;
      RoomMsg roomMsg = roomChatCellVo.roomMsg;
      dataMgr.getRoomPlayer(roomMsg.userId, roomId: roomId).then((value) {
        bFun(value);
      });
    } else {
      bFun(basePlayer);
    }
    // });

  }

  //添加用户等级Icon到前排中，
  void _addUserLevelIcon(int level) {
    int lv = level;
    int titleLen = 7;
    //10-90的宽度
    Rect rect = Rect.fromLTWH(0.w, 1.w, 76.w, 30.w);
    if (lv < 10) {
      rect = Rect.fromLTWH(0.w, 1.w, 66.w, 30.w); //和系统，互动，按钮一样大
      titleLen = 6;
    } else if (lv > 90 && lv < 100) {
      rect = Rect.fromLTWH(0.w, 1.w, 86.w, 30.w);
      titleLen = 7;
    } else if (lv >= 100) {
      rect = Rect.fromLTWH(-2.w, 1.w, 90.w, 30.w);
      titleLen = 8;
    }
    addIconTittleToHead(
      LevelBaseIcon(
        iconLen: titleLen,
        url: 'assets/new_rank/${getNewRankIcon(lv)}.png',
        boxRect: rect,
        level: lv,
        roomChatCellVo: roomChatCellVo,
      ),
    );
    //返回因等级的变化图标的宽度引起的偏移，在titleLen中已表现了icon的宽度
  }

  //用户多个icon 等级，标签，房管，幸运
  void _createPlayerIcon(RoomPlayer player) {
    if (_isMysteryPlayer(player)) {
      //神秘用户不显示
      return;
    }
    _addUserLevelIcon(player.level);
    //用用户标签
    String vipIconUrl = getVipIconUrl(player.vipLevel);
    if (vipIconUrl.isNotEmpty) {
      addIconTittleToHead(
        HeadBaseIcon(
          iconLen: 7,
          url: vipIconUrl,
          roomChatCellVo: roomChatCellVo,
          boxRect: Rect.fromLTWH(0.w, 2.w, 80.w, 28.w),
        ),
      );
    }
    //小图标都用一样的尺寸
    int num3 = 3;
    Rect rect=Rect.fromLTWH(5.w, 5.w, 26.w, 26.w);
    //，应该判断是管理者
    if (player.roomAdmin > 0) {
      addIconTittleToHead(
        HeadBaseIcon(
          boxRect:rect,
          iconLen: num3,
          url: 'assets/common/room_admin.png',
          roomChatCellVo: roomChatCellVo,
        ),
      );
    }
    //幸运
    if (player.luckNum != null && player.luckNum! > 0) {
      addIconTittleToHead(
        HeadBaseIcon(
          iconLen: num3,
          boxRect: rect,
          url: 'assets/common/icon_luckey_num.png',
          roomChatCellVo: roomChatCellVo,
        ),
      );
    }
    if (player.userDefend > 0) //守护图标
    {
      Item? it = dataCenter.itemConfigMgr.getItemGuard(player.userDefend);
      if (it!.icon != null) {
        addIconTittleToHead(
          HeadBaseIcon(
            iconLen: num3,
            boxRect: rect,
            url: serviceUpload.cdnUrl(it.icon ?? ''),
            roomChatCellVo: roomChatCellVo,
          ),
        );
      }
    }
  }

  //绘制背景
  void _drawBackGroundColor(RoomChatCellVo vo, Canvas canvas, double ty) {
    Color bgLineColor = Colors.transparent;
    Color bgColor = Colours.public_transparent_bg;
    double borderWidth = 2.w;
    int vipLevel = 0;
    int roomAdmin = 0;
    if (vo.roomMsg.id >= 0 && _voPlayer != null) {
      vipLevel = _voPlayer!.vipLevel;
      roomAdmin = _voPlayer!.roomAdmin;
    }

    switch (vipLevel) {
      case 5:
        // 侯爵 - 蓝色
        bgLineColor = const Color(0xff00BFFF);
        bgColor = const Color(0x300053c4);

        break;
      case 6:
        // 公爵 -紫色
        bgLineColor = const Color(0xffff00ff);
        bgColor = const Color(0x308707c2);

        break;
      case 7:
        // 国王 -玫红
        bgLineColor = const Color(0xffff1493);
        bgColor = const Color(0x30c30e5d);
        break;
      default:
        if (roomAdmin > 0) {
          bgLineColor = const Color(0XFF8773FD);
          bgColor = Colours.public_transparent_bg;
          borderWidth = 3.w;
        } else {
          bgLineColor = Colors.transparent;
          bgColor = Colours.public_transparent_bg;
        }
        break;
    }

    final fillPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = bgLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    Radius radius = Radius.circular(20.w); // 所有角都使用 20.w 的圆角
    final rRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          0,
          (vo.rect.top - ty + 3.w),
          vo.rect.width,
          vo.rect.height - 6.w,
        ),
        radius); // 创建 RRect 对象
    canvas.drawRRect(rRect, fillPaint);
    canvas.drawRRect(rRect, strokePaint);
  }

  @override
  void draw(RoomChatCellVo vo, Canvas canvas, double ty) {
    _drawBackGroundColor(vo, canvas, ty);
    super.draw(vo, canvas, ty);

  }
}
