import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';

class OnnxService {
  late OrtSession _session;

  Future<void> init() async {
    OrtEnv.instance.init();
    final modelData = await rootBundle.load('assets/model.onnx');
    final modelBytes = modelData.buffer.asUint8List();
    final options = OrtSessionOptions();
    _session = await OrtSession.fromBuffer(modelBytes, options);
    print("ONNX model loaded successfully");
  }

  Future<List<double>> generateEmbedding(List<int> tokens) async {
    final attentionMask = List.filled(tokens.length, 1);
    final inputIds = OrtValueTensor.createTensorWithDataList(tokens, [
      1,
      tokens.length,
    ]);
    final maskTensor = OrtValueTensor.createTensorWithDataList(attentionMask, [
      1,
      tokens.length,
    ]);
    final outputs = await _session.run(OrtRunOptions(), {
      "input_ids": inputIds,
      "attention_mask": maskTensor,
    });
    final raw = outputs.first!.value as List;
    final embedding = List<double>.from(raw[0][0]);
    return embedding;
  }
}