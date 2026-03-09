import 'dart:math';

class SimilarityService {
  static double cosine(List<double> a, List<double> b) {
    double dot = 0;
    double magA = 0;
    double magB = 0;

    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      magA += a[i] * a[i];
      magB += b[i] * b[i];
    }
    return dot / (sqrt(magA) * sqrt(magB));
  }
}
