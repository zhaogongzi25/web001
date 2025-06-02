import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:live/page/home/room/sliver_chat/custom_bride_model.dart';

import 'custom_chat_render_sliver.dart';
import 'vo/base_info_vo.dart';
import 'custom_chat_controller.dart';
import 'custom_chat_view.dart';

class SliverMain extends StatefulWidget {
  const SliverMain({super.key});

  @override
  _SliverMainState createState() => _SliverMainState();
}

class _SliverMainState extends State<SliverMain>
    with SingleTickerProviderStateMixin {
 

  @override
  void initState() {
    super.initState();
  }

  void addTempText(BaseInfovo vo) {
    CustomBrideModel().chatController!.pushData(vo);
     CustomBrideModel().chatController!.refreshUi();
    // setState(() {});
  }
 
  
 

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:EdgeInsets.only(top: 300.w),
      width: 650.w,
      height: 500.w,
      color: Colors.white30,

      child: CustomChatView(
           onCreated: (CustomcChatController controller) {
             CustomBrideModel().init(controller);
      
       
           },
         ),
    );

  }
}
