import 'dart:convert';
import 'package:flutter/services.dart';

class EmbeddingStore {
  late Map<String, List<double>> goals;
  late Map<String, List<double>> injuries;
  late Map<String, List<double>> motivations;

  Future<void> init() async {
    final data = await rootBundle.loadString('assets/tag_embeddings.json');
    final decoded = json.decode(data);
    goals = {};
    injuries = {};
    motivations = {};
    for (var item in decoded["goals"]) {
      goals[item["tag"]] = List<double>.from(item["embedding"]);
    }
    for (var item in decoded["injuries"]) {
      injuries[item["tag"]] = List<double>.from(item["embedding"]);
    }
    for (var item in decoded["motivations"]) {
      motivations[item["tag"]] = List<double>.from(item["embedding"]);
    }
  }
}
