import 'package:flutter/material.dart';
import 'package:magic_english_project/core/utils/toast_helper.dart';
import 'package:magic_english_project/project/dto/vocabulary.dart';
import 'package:magic_english_project/project/vocab/vocab_api.dart';

class FlashCardPage extends StatefulWidget {
  final int notebookId;
  final int? initialVocabId;

  FlashCardPage({
    super.key,
    required this.notebookId,
    this.initialVocabId,
  });

  @override
  State<FlashCardPage> createState() => _FlashCardPageState();
}

class _FlashCardPageState extends State<FlashCardPage> {
  bool isFront = true;

  bool _isLoading = true;
  List<Vocabulary> _items = const [];
  int _index = 0;

  // 🔒 KÍCH THƯỚC CỐ ĐỊNH (giống Figma)
  static const double cardWidth = 320;
  static const double cardHeight = 180;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final items = await VocabApi.fetchByNotebookId(notebookId: widget.notebookId);
      if (!mounted) return;

      var initialIndex = 0;
      final initialId = widget.initialVocabId;
      if (initialId != null) {
        final found = items.indexWhere((e) => e.id == initialId);
        if (found >= 0) initialIndex = found;
      }

      setState(() {
        _items = items;
        _index = initialIndex.clamp(0, items.isEmpty ? 0 : items.length - 1);
      });
    } catch (e) {
      if (!mounted) return;
      showTopNotification(
        context,
        type: ToastType.error,
        title: 'Lỗi',
        message: e.toString(),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _goPrev() {
    if (_items.isEmpty) return;
    if (_index <= 0) return;
    setState(() {
      _index -= 1;
      isFront = true;
    });
  }

  void _goNext() {
    if (_items.isEmpty) return;
    if (_index >= _items.length - 1) return;
    setState(() {
      _index += 1;
      isFront = true;
    });
  }

  Vocabulary? get _current => (_items.isEmpty || _index < 0 || _index >= _items.length)
      ? null
      : _items[_index];

  @override
  Widget build(BuildContext context) {
    final current = _current;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Flash card',
          style: TextStyle(color: Colors.black),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.settings, color: Colors.black),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_items.isEmpty
              ? const Center(child: Text('Chưa có từ vựng.'))
              : Column(
                  children: [
                    const SizedBox(height: 100),

                    Center(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            isFront = !isFront;
                          });
                        },
                        child: Container(
                          width: cardWidth,
                          height: cardHeight,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: isFront
                                ? _buildFront(const ValueKey('front'), word: current?.word ?? '')
                                : _buildBack(
                                    const ValueKey('back'),
                                    meaning: current?.meaning ?? '',
                                    phonetic: current?.ipa ?? '',
                                    type: current?.partOfSpeech ?? '',
                                    level: current?.cefrLevel ?? '',
                                    example: current?.example ?? '',
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ================= < 3/30 > =================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _goPrev,
                            child: const Icon(Icons.chevron_left, size: 28),
                          ),
                          Text(
                            '${_index + 1}/${_items.length}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: _goNext,
                            child: const Icon(Icons.chevron_right, size: 28),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // ================= PHÁT ÂM =================
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24, left: 12, right: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [
                          Icon(Icons.volume_up),
                          SizedBox(width: 8),
                          Text(
                            'Phát âm',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
    );
  }

  // ================= FRONT =================
  Widget _buildFront(Key key, {required String word}) {
    return Center(
      key: key,
      child: Text(
        word,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ================= BACK =================
  Widget _buildBack(
    Key key, {
    required String meaning,
    required String phonetic,
    required String type,
    required String level,
    required String example,
  }) {
    return SingleChildScrollView(
      key: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _info('Ý nghĩa', meaning),
          _info('Phiên âm', phonetic),
          _info('Loại từ', type),
          _info('Cấp độ', level),
          _info('Ví dụ', example),
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
