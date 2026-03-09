import 'onnx_service.dart';
import 'tokenizer_service.dart';
import 'cosinesimilarity.dart';
import 'allembeddings.dart';

class TagsGenerations {

  final OnnxService onnx;
  final TokenizerService tokenizer;
  final EmbeddingStore store;

  TagsGenerations(this.onnx, this.tokenizer, this.store);

  Future<List<String>> getBestTags(String text) async {

    final tokens = tokenizer.tokenize(text);
    final userEmbedding = await onnx.generateEmbedding(tokens);

    List<String> bestFrom(Map<String, List<double>> embeddings) {

      Map<String, double> scores = {};

      embeddings.forEach((tag, emb) {
        final sim = SimilarityService.cosine(userEmbedding, emb);
        scores[tag] = sim;
      });

      final sorted = scores.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sorted.take(3).map((e) => e.key).toList();
    }

    final goalTags = bestFrom(store.goals);
    final injuryTags = bestFrom(store.injuries);
    final motivationTags = bestFrom(store.motivations);

    return [
      ...goalTags,
      ...injuryTags,
      ...motivationTags,
    ];
  }
}