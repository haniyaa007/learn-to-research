import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game.dart';
import 'leaderboard.dart';
import 'models.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Persona> ps = [];
  final stars = <String, int>{}, best = <String, int>{};

  @override
  void initState() {
    super.initState();
    () async {
      final p = await SharedPreferences.getInstance();
      final l = await loadPersonas();
      setState(() {
        ps = l;
        for (final h in l) {
          stars[h.id] = p.getInt('s_${h.id}') ?? 0;
          best[h.id] = p.getInt('b_${h.id}') ?? 0;
        }
      });
    }();
  }

  bool open(int i) => i == 0 || (stars[ps[i - 1].id] ?? 0) > 0;

  Future<void> play(Persona h) async {
    final r = await Navigator.push<(int, int)>(context, MaterialPageRoute(builder: (_) => Game(h)));
    if (r == null) return;
    final p = await SharedPreferences.getInstance();
    if (r.$1 > (stars[h.id] ?? 0)) await p.setInt('s_${h.id}', r.$1);
    if (r.$2 > (best[h.id] ?? 0)) await p.setInt('b_${h.id}', r.$2);
    setState(() {
      stars[h.id] = r.$1 > (stars[h.id] ?? 0) ? r.$1 : stars[h.id]!;
      best[h.id] = r.$2 > (best[h.id] ?? 0) ? r.$2 : best[h.id]!;
    });
  }

  @override
  Widget build(BuildContext c) {
    final total = stars.values.fold(0, (a, b) => a + b);
    return Scaffold(
      body: SafeArea(
        child: ps.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(padding: const EdgeInsets.all(16), children: [
                Row(children: [
                  const Expanded(child: Text('🔎 Learn to Research', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900))),
                  if (Board.enabled)
                    IconButton(
                        icon: const Icon(Icons.emoji_events),
                        onPressed: () => Navigator.push(c, MaterialPageRoute(builder: (_) => const LeaderboardScreen()))),
                ]),
                Text('From Noob to Professor  •  ⭐ $total / ${ps.length * 3}', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                for (var i = 0; i < ps.length; i++) card(i),
              ]),
      ),
    );
  }

  Widget card(int i) {
    final h = ps[i], ok = open(i), s = stars[h.id] ?? 0;
    return Opacity(
      opacity: ok ? 1 : .4,
      child: Card(
        color: h.color.withOpacity(.25),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(radius: 28, backgroundImage: AssetImage('assets/avatars/${h.id}.png')),
          title: Text('${h.name} — ${h.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(ok ? '${h.intro}\nBest: ${best[h.id]}' : '🔒 Earn a star on the previous level'),
          trailing: Text('⭐' * s + '☆' * (3 - s)),
          onTap: ok ? () => play(h) : null,
        ),
      ),
    );
  }
}
