import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// type -> (emoji, label)
const typeInfo = <String, (String, String)>{
  'mcq': ('❓', 'Question'),
  'order': ('🧩', 'Task: put in order'),
  'fake': ('🕵️', 'Spot the fake'),
  'citation': ('📝', 'Fix the citation'),
  'review': ('🧑‍⚖️', 'Peer-review round'),
};

class Q {
  final String type, text, why;
  final List<String> opts; // order type: opts are in CORRECT order
  final int answer;
  const Q(this.type, this.text, this.why, this.opts, this.answer);
  bool get isOrder => type == 'order';

  factory Q.fromJson(Map<String, dynamic> j) {
    final t = j['type'] as String;
    if (t == 'order') {
      return Q(t, j['q'], j['why'], List<String>.from(j['items']), 0);
    }
    final o = List<String>.from(j['options']);
    final right = o[j['answer'] as int];
    o.shuffle();
    return Q(t, j['q'], j['why'], o, o.indexOf(right));
  }
}

class Persona {
  final String id, name, title, emoji, intro;
  final Color color;
  final List<Map<String, dynamic>> pool;
  const Persona(this.id, this.name, this.title, this.emoji, this.intro, this.color, this.pool);

  /// Randomized draw from the question bank.
  List<Q> draw(int n) =>
      (List.of(pool)..shuffle()).take(n).map(Q.fromJson).toList();

  factory Persona.fromJson(Map<String, dynamic> j) => Persona(
      j['id'], j['name'], j['title'], j['emoji'], j['intro'],
      Color(int.parse('FF${j['color']}', radix: 16)),
      List<Map<String, dynamic>>.from(j['questions']));
}

Future<List<Persona>> loadPersonas() async {
  final raw = await rootBundle.loadString('assets/questions.json');
  return (jsonDecode(raw) as List)
      .map((e) => Persona.fromJson(e as Map<String, dynamic>))
      .toList();
}
