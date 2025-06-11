
import 'package:flutter/material.dart';
//用于给文本保存点击链接的数据，
class TextLinkRegion {
  /// 链接在整个文本字符串中的起始字符索引 (包含)
  final int startCharacterIndex;

  /// 链接在整个文本字符串中的结束字符索引 (不包含)
  final int endCharacterIndex;

  /// 与此链接关联的数据 (例如，URL, ID)
  final dynamic linkData;

  /// 点击时触发的回调
  final VoidCallback? onTap;

  TextLinkRegion({
    required this.startCharacterIndex,
    required this.endCharacterIndex,
    this.linkData,
    this.onTap,
  });


}

Tuple2<List<InlineSpan>, List<TextLinkRegion>> buildSpansAndRegions({
  required String fullText, // Full simple string (if not using base style)
  required TextStyle baseStyle,
  required List<Map<String, dynamic>>
  linkDefinitions, // List of { 'text': 'link text', 'url': '...', 'onTap': ...}
}) {
  final List<InlineSpan> resultSpans = [];
  final List<TextLinkRegion> linkRegions = [];
  int currentOffset = 0;
  int linkDefIndex = 0;
  // A simple parser: find links in sequence. This is basic and might need
  // more sophistication for complex formatting.
  String remainingText = fullText;
  while (remainingText.isNotEmpty) {
    if (linkDefIndex < linkDefinitions.length) {
      final linkDef = linkDefinitions[linkDefIndex];
      final String linkText = linkDef['text']!;
      final String? url = linkDef['url'];
      final Color? color = linkDef['color'];
      final FontWeight? fontWeight = linkDef['fontWeight'];
      final VoidCallback? onTap = linkDef['onTap'];
      final int linkIndexInRemaining = remainingText.indexOf(linkText);
      if (linkIndexInRemaining != -1) {
        // Add text before the link
        if (linkIndexInRemaining > 0) {
          final String preLinkText = remainingText.substring(
            0,
            linkIndexInRemaining,
          );
          resultSpans.add(TextSpan(text: preLinkText, style: baseStyle));
          currentOffset += preLinkText.length;
        }
        // Add the link span
        resultSpans.add(
          TextSpan(
            text: linkText,
            style: baseStyle.copyWith(
              // Copy base style and add link specific style
              fontWeight:fontWeight??baseStyle.fontWeight,
              color: color ?? Colors.blueAccent, // Example link style
              // decoration: TextDecoration.underline,
            ),
            // No recognizer here! Handled in RenderSliver.
          ),
        );

        // Add the link region
        linkRegions.add(
          TextLinkRegion(
            startCharacterIndex: currentOffset,
            endCharacterIndex: currentOffset + linkText.length,
            linkData: url,
            onTap:
            onTap ??
                (url != null
                // ignore: avoid_print
                    ? () => print('Tapped $url')
                    : null), // Default simple tap if url given
          ),
        );
        currentOffset += linkText.length;
        remainingText = remainingText.substring(
          linkIndexInRemaining + linkText.length,
        );
        linkDefIndex++; // Move to the next link definition
      } else {
        // Link text not found in remaining text, treat remaining as plain text
        resultSpans.add(TextSpan(text: remainingText, style: baseStyle));
        currentOffset += remainingText.length;
        remainingText = ''; // Finish
      }
    } else {
      // No more link definitions, add remaining text as plain text
      resultSpans.add(TextSpan(text: remainingText, style: baseStyle));
      currentOffset += remainingText.length;
      remainingText = ''; // Finish
    }
  }
  return Tuple2(resultSpans, linkRegions);
}

// Simple helper for returning two values
class Tuple2<T1, T2> {
  final T1 item1;
  final T2 item2;

  Tuple2(this.item1, this.item2);
}