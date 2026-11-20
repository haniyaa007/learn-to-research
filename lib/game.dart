import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'leaderboard.dart';
import 'sfx.dart';
import 'models.dart';

class Game extends StatefulWidget {
  final Persona hero;
  const Game(this.hero, {super.key});
  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  late final List<Q> qs = widget.hero.draw(8);
  int i = 0, lives = 3, score = 0, streak = 0;
  int? picked;
  bool answered = false, correct = false, pop = false;
  List<int> chain = [], shuf = [];
  Q get q => qs[i];

  @override
  void initState() {
    super.initState();
    prep();
  }

  void prep() {
    answered = false;
    picked = null;
    chain = [];
    shuf = List.generate(q.opts.length, (k) => k)..shuffle();
  }

  void finishQ(bool ok) {
    ok ? HapticFeedback.lightImpact() : HapticFeedback.heavyImpact();
    Sfx.play(ok ? 'correct' : 'wrong');
    setState(() {
      answered = true;
      correct = ok;
      pop = true;
      if (ok) {
        streak++;
        score += 10 + streak * 2;
      } else {
        streak = 0;
        lives--;
      }
    });
    Future.delayed(const Duration(milliseconds: 300), () => mounted ? setState(() => pop = false) : null);
  }

  void next() {
    if (lives <= 0 || i == qs.length - 1) return end();
    setState(() {
      i++;
      prep();
    });
  }

  Future<void> end() async {
    final won = lives > 0, st = !won ? 0 : lives;
    Sfx.play(won ? 'win' : 'lose');
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (d) => AlertDialog(
        title: Text(won ? '🎉 Level complete!' : '💀 Out of lives'),
        content: Text('Score: $score\n${'⭐' * st}${'☆' * (3 - st)}'),
        actions: [
          if (Board.enabled && score > 0)
            TextButton(onPressed: () => Board.submit(context, widget.hero.name, score), child: const Text('Post score 🏆')),
          TextButton(onPressed: () => Navigator.pop(d), child: const Text('Continue')),
        ],
      ),
    );
    if (mounted) Navigator.pop<(int, int)>(context, (st, score));
  }

  @override
  Widget build(BuildContext c) {
    final h = widget.hero, info = typeInfo[q.type]!;
    return Scaffold(
      appBar: AppBar(
        title: Text(h.title),
        backgroundColor: h.color.withOpacity(.4),
        actions: [Center(child: Padding(padding: const EdgeInsets.only(right: 16), child: Text('${'❤️' * lives} 🔥$streak ⭐$score')))],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        LinearProgressIndicator(value: (i + (answered ? 1 : 0)) / qs.length),
        const SizedBox(height: 16),
        Row(children: [
          AnimatedScale(
            scale: pop ? 1.4 : 1,
            duration: const Duration(milliseconds: 250),
            curve: Curves.elasticOut,
            child: CircleAvatar(radius: 32, backgroundColor: h.color, backgroundImage: AssetImage('assets/avatars/${h.id}.png')),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text('${info.$1} ${info.$2}', style: TextStyle(color: h.color, fontWeight: FontWeight.bold, fontSize: 16))),
        ]),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: Column(
            key: ValueKey(i),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(q.text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              ...(q.isOrder ? orderUI() : mcqUI()),
            ],
          ),
        ),
        if (answered) feedback(),
      ]),
    );
  }

  List<Widget> mcqUI() => [
        for (var k = 0; k < q.opts.length; k++)
          Card(
            color: !answered ? null : k == q.answer ? Colors.green.shade800 : k == picked ? Colors.red.shade800 : null,
            child: ListTile(
              title: Text(q.opts[k]),
              onTap: answered ? null : () {
                picked = k;
                finishQ(k == q.answer);
              },
            ),
          )
      ];

  List<Widget> orderUI() => [
        if (chain.isNotEmpty)
          Wrap(spacing: 6, children: [for (var n = 0; n < chain.length; n++) Chip(label: Text('${n + 1}. ${q.opts[chain[n]]}'))]),
        for (final k in shuf)
          Card(
            child: ListTile(
              enabled: !chain.contains(k) && !answered,
              title: Text(q.opts[k]),
              onTap: () {
                setState(() => chain.add(k));
                if (chain.length == q.opts.length) {
                  finishQ(List.generate(chain.length, (n) => chain[n] == n).every((x) => x));
                }
              },
            ),
          ),
        if (!answered) TextButton(onPressed: () => setState(() => chain = []), child: const Text('Reset')),
      ];

  Widget feedback() => TweenAnimationBuilder<double>(
        tween: Tween(begin: .8, end: 1),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        builder: (_, v, child) => Transform.scale(scale: v, child: child),
        child: Card(
          color: correct ? Colors.green.shade900 : Colors.red.shade900,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(correct ? '✅ Correct!' : '❌ Not quite', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (!correct && q.isOrder) Text('Correct order: ${q.opts.join(' → ')}'),
              const SizedBox(height: 6),
              Text('💡 ${q.why}'),
              const SizedBox(height: 12),
              FilledButton(onPressed: next, child: const Text('Next')),
            ]),
          ),
        ),
      );
}
