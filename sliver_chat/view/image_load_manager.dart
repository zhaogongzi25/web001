import 'dart:io';
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
  static getImageLocalorNetFun(String url, Function(ui.Image) calBackfun) async {
    ui.Image? bimg;
    if (imageMap.containsKey(url)) {
      bimg = imageMap[url];
    } else {
      if (url.contains("https:") || url.contains("http:")) {
        bimg = await _loadNetWorkCopy(url);
      } else {
        bimg = await _loadLocal(url);
      }
    }
    if (bimg != null) {
      calBackfun(bimg);
    } else {
      print('图片加载失败-----------$url');
    }
  }
  static Future<ui.Image?> _loadLocal(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      imageMap.addEntries(
        <String, ui.Image>{assetPath: frameInfo.image}.entries,
      );
      return frameInfo.image;
    } catch (e) {
      return null;
    }
  }
  static Future<ui.Image?> _loadNetWorkCopy(String url) async {
    String? outUrl = await downloadMgr.downloadLite(url);
    if (outUrl != null) {
      return _loadLocal(outUrl);
    } else {
      return null;
    }
  }

}
