import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:common_base/utils.dart';
import 'package:custom_image/image_data.dart';
import 'package:data_center/live_old/service/service_upload.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_net/download_mgr.dart';
import 'package:http/http.dart' as http;

class ImageLoadManager {
  static final Map<String, ui.Image> imageMap = {};
  static getImageLocalorNetFun(String url, Function(ui.Image?) calBackfun) async {
    ui.Image? bImg;

    // await Future.delayed(Duration(seconds:  Random().nextInt(5)));
    if (imageMap.containsKey(url)) {
      bImg = imageMap[url];
    } else {
      // print('加载图片  $url');
      if (url.contains("https:") || url.contains("http:")) {
        String? localUrl = await downloadMgr.downloadLite(url);
        if(localUrl!=null){
          bImg = await _loadLocal(localUrl);
        }
      } else {
        bImg = await _loadLocal(url);
      }
    }
    if(bImg!=null){
      imageMap.addEntries(
        <String, ui.Image>{url: bImg}.entries,
      );
    }
    calBackfun(bImg);
  }
  static Future<ui.Image?> _loadLocal(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      return frameInfo.image;
    } catch (e) {
      return null;
    }
  }



}
