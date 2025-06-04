import 'dart:io';
import 'dart:ui' as ui;
import 'package:common_base/utils.dart';
import 'package:data_center/live_old/service/service_upload.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ImageLoadManager {
  static final Map<String, ui.Image> imageMap = {};

  final ServiceUpload serviceUpload = ServiceUpload();

  // static Future<ui.Image?> getImageLocalorNet(String url) async {
  //   if (imageMap.containsKey(url)) {
  //     print('不用加载');
  //     return imageMap[url];
  //   }else{
  //     if (url.contains("https:")) {
  //       return await _loadNetWork(url);
  //     }else{
  //       return await _loadLocal(url);
  //     }
  //   }
  // }
  static getImageLocalorNetFun(
      String url, Function(ui.Image) calBackfun) async {
    ui.Image? bimg;
    if (imageMap.containsKey(url)) {
      bimg = imageMap[url];
    } else {
      if (url.contains("https:") || url.contains("http:")) {
        bimg = await _loadNetWork(url);
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
      // 1. Get the image data from assets

      final ByteData data = await rootBundle.load(assetPath);
      // 2. Convert the data to a Uint8List
      final Uint8List bytes = data.buffer.asUint8List();
      // 3. Decode the image bytes into a ui.Image
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();

      imageMap.addEntries(
        <String, ui.Image>{assetPath: frameInfo.image}.entries,
      );
      return frameInfo.image;
    } catch (e) {
      return null;
      // Handle error loading image, maybe show a placeholder or error message
    }
  }

  static Future<ui.Image?> _loadNetWork(String url) async {
 
    try {
      var assetPath = Utils.getAssetRealPath(url);
      final HttpClient httpClient = HttpClient();
      final HttpClientRequest request = await httpClient.getUrl(Uri.parse(assetPath));

      final HttpClientResponse response = await request.close();
      final Uint8List bytes =
          await consolidateHttpClientResponseBytes(response);
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);

      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      imageMap.addEntries(
        <String, ui.Image>{url: frameInfo.image}.entries,
      );
      print(frameInfo.image.width);

      return frameInfo.image; // 返回 ui.Image 对象
    } catch (e) {
      // 捕获网络错误、解码错误等
      print('Error  $url: $e');

      return null;
    } finally {
      // 释放 Codec 和 Buffer 资源
      // codec?.dispose();
      // immutableBuffer?.dispose();
    }
  }

  static Future<ui.Image?> _loadNetWorkbase(String url) async {
    ui.Codec? codec; // 使用 nullable
    ui.ImmutableBuffer? immutableBuffer; // 使用 nullable
    try {
      // 1. 获取图片数据 (Bytes)
      final http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        print('Failed to load image: ${response.statusCode}');
        return null; // 请求失败
      }
      final Uint8List bytes = response.bodyBytes;
      // 2. 解码图片数据
      // 创建 ImmutableBuffer，这是推荐的方式
      immutableBuffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      // 使用 ImmutableBuffer 实例化 Codec
      codec = await ui.instantiateImageCodecFromBuffer(immutableBuffer);
      // 获取第一帧 (如果是静态图片，通常只有一帧)
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      imageMap.addEntries(
        <String, ui.Image>{url: frameInfo.image}.entries,
      );
      return frameInfo.image; // 返回 ui.Image 对象
    } catch (e) {
      // 捕获网络错误、解码错误等
      print('Error  $url: $e');

      return null;
    } finally {
      // 释放 Codec 和 Buffer 资源
      // codec?.dispose();
      // immutableBuffer?.dispose();
    }
  }
}
