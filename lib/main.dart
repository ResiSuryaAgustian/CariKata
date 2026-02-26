import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Pencari Kata Bahasa Indonesia',
    theme: ThemeData(
      useMaterial3: false,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {TargetPlatform.android: ZoomPageTransitionsBuilder()},
      ),
    ),
    home: const WordFinder(),
  ),
);

class WordFinder extends StatefulWidget {
  const WordFinder({super.key});
  @override
  State<WordFinder> createState() => _WordFinderState();
}

class _WordFinderState extends State<WordFinder> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<String> _words = [], _results = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  // Jalankan di isolate terpisah (off main thread)
  static List<String> _parseWords(String data) {
    return data
        .split('\n')
        .map((e) => e.trim().toLowerCase())
        .where((w) => w.length > 1 && !w.contains(RegExp(r'[ \-(]')))
        .toSet()
        .toList();
  }

  static List<String> _filterWords(List<dynamic> args) {
    final words = args[0] as List<String>;
    final input = args[1] as String;
    return words.where((w) => w.startsWith(input)).toList()..sort();
  }

  Future<void> _loadWords() async {
    try {
      final data = await rootBundle.loadString('assets/daftar_kata.txt');
      final parsed = await compute(_parseWords, data);
      setState(() {
        _words = parsed;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal load file: $e')));
    }
  }

  void _search() {
    final input = _controller.text.trim().toLowerCase();
    if (input.isEmpty) {
      setState(() => _results = []);
      return;
    }
    compute(_filterWords, [_words, input]).then((result) {
      if (mounted) setState(() => _results = result);
    });
  }

  void _clearAndFocus() {
    _controller.clear();
    _search();
    _focusNode.unfocus();
    Future.delayed(const Duration(milliseconds: 50), () {
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pencari Kata Bahasa Indonesia')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Masukkan huruf depan (misal: ab)',
                border: const OutlineInputBorder(),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: _clearAndFocus,
                      )
                    : null,
              ),
              onChanged: (_) => _search(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ditemukan!\nCoba masukkan huruf depan!',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      addRepaintBoundaries: false,
                      addAutomaticKeepAlives: false,
                      itemCount: _results.length + 2,
                      itemBuilder: (_, i) {
                        if (i == 0)
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Kata berawalan: ${_controller.text.toUpperCase()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          );
                        if (i == _results.length + 1)
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              '========= selesai =========',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                          ), // ← jarak antar kata
                          child: Text(
                            '- ${_results[i - 1]}', // ← strip & ukuran
                            style: const TextStyle(fontSize: 18),
                          ),
                        );
                      },
                    ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Ada kesalahan? Hub DC: sansho. (pake titik)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }
}
