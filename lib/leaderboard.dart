import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Board {
  static bool enabled = false;
  static SupabaseClient get _db => Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> top() async => List<Map<String, dynamic>>.from(
      await _db.from('scores').select().order('score', ascending: false).limit(50));

  static Future<void> submit(BuildContext ctx, String persona, int score) async {
    final p = await SharedPreferences.getInstance();
    var nick = p.getString('nick');
    if (nick == null && ctx.mounted) {
      final c = TextEditingController();
      nick = await showDialog<String>(
          context: ctx,
          builder: (d) => AlertDialog(
                title: const Text('Pick a nickname'),
                content: TextField(controller: c, maxLength: 20, autofocus: true),
                actions: [TextButton(onPressed: () => Navigator.pop(d, c.text.trim()), child: const Text('OK'))],
              ));
      if (nick == null || nick.length < 2) return;
      await p.setString('nick', nick);
    }
    try {
      await _db.from('scores').insert({'nickname': nick, 'persona': persona, 'score': score});
      if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Score posted! 🏆')));
    } catch (_) {
      if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Could not post score.')));
    }
  }
}

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
        appBar: AppBar(title: const Text('🏆 Leaderboard')),
        body: FutureBuilder(
          future: Board.top(),
          builder: (_, s) {
            if (s.hasError) return const Center(child: Text('Offline or not configured.'));
            if (!s.hasData) return const Center(child: CircularProgressIndicator());
            final rows = s.data!;
            if (rows.isEmpty) return const Center(child: Text('No scores yet. Be the first!'));
            return ListView.builder(
              itemCount: rows.length,
              itemBuilder: (_, i) => ListTile(
                leading: Text(i < 3 ? ['🥇', '🥈', '🥉'][i] : '${i + 1}'),
                title: Text(rows[i]['nickname']),
                subtitle: Text(rows[i]['persona']),
                trailing: Text('${rows[i]['score']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            );
          },
        ),
      );
}
