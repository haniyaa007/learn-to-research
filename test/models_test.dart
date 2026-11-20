import 'package:flutter_test/flutter_test.dart';
import 'package:learn_to_research/models.dart';

void main() {
  test('mcq shuffle keeps the right answer', () {
    final q = Q.fromJson({'type': 'mcq', 'q': 'x', 'why': 'y', 'options': ['a', 'b', 'c'], 'answer': 1});
    expect(q.opts[q.answer], 'b');
  });
  test('order keeps canonical order', () {
    final q = Q.fromJson({'type': 'order', 'q': 'x', 'why': 'y', 'items': ['1', '2', '3']});
    expect(q.opts, ['1', '2', '3']);
  });
}
