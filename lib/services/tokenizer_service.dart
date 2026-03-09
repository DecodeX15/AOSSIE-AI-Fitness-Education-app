import 'dart:convert';
import 'package:flutter/services.dart';

class TokenizerService {
  late Map<String, int> vocab;

  Future<void> init() async {
    final vocabFile = await rootBundle.loadString('assets/vocab.txt');
    final lines = vocabFile.split('\n');
    vocab = {};
    for (int i = 0; i < lines.length; i++) {
      final token = lines[i].trim();

      if (token.isNotEmpty) {
        vocab[token] = i;
      }
    }
  }

  List<int> tokenize(String text) {
    final words = text.toLowerCase().split(" ");
    List<int> tokens = [];

    for (var w in words) {
      tokens.add(vocab[w] ?? vocab["[UNK]"] ?? 100);
    }
    if (tokens.length > 128) {
      tokens = tokens.take(128).toList();
    }
    return tokens;
  }
}
