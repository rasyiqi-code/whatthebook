import 'package:flutter/material.dart';

class MarkdownFormatter {
  static TextSpan formatText(String text, TextStyle? baseStyle) {
    if (text.isEmpty) {
      return TextSpan(text: '', style: baseStyle);
    }

    final baseStyleNonNull = baseStyle ?? const TextStyle();

    // Simple approach: process one type at a time
    return _processMarkdown(text, baseStyleNonNull);
  }

  static TextSpan _processMarkdown(String text, TextStyle baseStyle) {
    final List<TextSpan> spans = [];
    int currentIndex = 0;

    // Process bold first (**text**)
    final boldMatches = RegExp(r'\*\*(.*?)\*\*').allMatches(text).toList();

    for (final match in boldMatches) {
      // Add text before bold
      if (match.start > currentIndex) {
        final beforeText = text.substring(currentIndex, match.start);
        spans.addAll(_processItalicAndUnderline(beforeText, baseStyle));
      }

      // Add bold text
      final boldText = match.group(1) ?? '';
      spans.add(
        TextSpan(
          text: boldText,
          style: baseStyle.copyWith(fontWeight: FontWeight.bold),
        ),
      );

      currentIndex = match.end;
    }

    // Add remaining text
    if (currentIndex < text.length) {
      final remainingText = text.substring(currentIndex);
      spans.addAll(_processItalicAndUnderline(remainingText, baseStyle));
    }

    return TextSpan(children: spans);
  }

  static List<TextSpan> _processItalicAndUnderline(
    String text,
    TextStyle baseStyle,
  ) {
    final List<TextSpan> spans = [];
    int currentIndex = 0;

    // Process underline first (__text__)
    final underlineMatches = RegExp(r'__(.*?)__').allMatches(text).toList();

    for (final match in underlineMatches) {
      // Add text before underline
      if (match.start > currentIndex) {
        final beforeText = text.substring(currentIndex, match.start);
        spans.addAll(_processItalic(beforeText, baseStyle));
      }

      // Add underline text
      final underlineText = match.group(1) ?? '';
      spans.add(
        TextSpan(
          text: underlineText,
          style: baseStyle.copyWith(decoration: TextDecoration.underline),
        ),
      );

      currentIndex = match.end;
    }

    // Add remaining text
    if (currentIndex < text.length) {
      final remainingText = text.substring(currentIndex);
      spans.addAll(_processItalic(remainingText, baseStyle));
    }

    return spans;
  }

  static List<TextSpan> _processItalic(String text, TextStyle baseStyle) {
    final List<TextSpan> spans = [];
    int currentIndex = 0;

    // Process italic (_text_) - avoid conflict with underline
    final italicMatches = RegExp(
      r'(?<!_)_([^_]+?)_(?!_)',
    ).allMatches(text).toList();

    for (final match in italicMatches) {
      // Add text before italic
      if (match.start > currentIndex) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, match.start),
            style: baseStyle,
          ),
        );
      }

      // Add italic text
      final italicText = match.group(1) ?? '';
      spans.add(
        TextSpan(
          text: italicText,
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ),
      );

      currentIndex = match.end;
    }

    // Add remaining text
    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex), style: baseStyle));
    }

    return spans;
  }

  // Helper method to strip markdown syntax
  static String stripMarkdown(String text) {
    return text
        // Remove bold syntax
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1')
        // Remove italic syntax
        .replaceAll(RegExp(r'(?<!_)_([^_]+?)_(?!_)'), r'$1')
        // Remove underline syntax
        .replaceAll(RegExp(r'__(.*?)__'), r'$1')
        // Remove $ placeholders (like $1, $2, etc.)
        .replaceAll(RegExp(r'\$\d+'), '')
        // Remove standalone $ symbols
        .replaceAll(RegExp(r'\$(?!\d)'), '')
        // Clean up multiple spaces
        .replaceAll(RegExp(r'\s+'), ' ')
        // Clean up multiple newlines
        .replaceAll(RegExp(r'\n\s*\n'), '\n\n')
        .trim();
  }
}
