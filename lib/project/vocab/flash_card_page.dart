import 'package:flutter/material.dart';

class FlashCardPage extends StatefulWidget {
  final String word;
  final String meaning;
  final String phonetic;
  final String type;
  final String level;
  final String example;

  const FlashCardPage({
    super.key,
    required this.word,
    required this.meaning,
    required this.phonetic,
    required this.type,
    required this.level,
    required this.example,
  });

  @override
  State<FlashCardPage> createState() => _FlashCardPageState();
}

class _FlashCardPageState extends State<FlashCardPage> {
  bool isFront = true;

  // 🔒 KÍCH THƯỚC CỐ ĐỊNH (giống Figma)
  static const double cardWidth = 320;
  static const double cardHeight = 180;

  @override
  Widget build(BuildContext context) {
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
      body: Column(
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
                      ? _buildFront(const ValueKey('front'))
                      : _buildBack(const ValueKey('back')),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ================= < 1/3 > =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // PREV
                GestureDetector(
                  onTap: () {
                    // TODO: chuyển vocab trước
                  },
                  child: const Icon(Icons.chevron_left, size: 28),
                ),

                // INDEX
                const Text(
                  '1/3',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // NEXT
                GestureDetector(
                  onTap: () {
                    // TODO: chuyển vocab sau
                  },
                  child: const Icon(Icons.chevron_right, size: 28),
                ),
              ],
            ),
          ),

          const Spacer(),

          // ================= PHÁT ÂM =================
          Padding(
            padding: const EdgeInsets.only(bottom: 24,left: 12,right: 12),
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
      ),
    );
  }

  // ================= FRONT =================
  Widget _buildFront(Key key) {
    return Center(
      key: key,
      child: Text(
        widget.word,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ================= BACK =================
  Widget _buildBack(Key key) {
    return SingleChildScrollView(
      key: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _info('Ý nghĩa', widget.meaning),
          _info('Phiên âm', widget.phonetic),
          _info('Loại từ', widget.type),
          _info('Cấp độ', widget.level),
          _info('Ví dụ', widget.example),
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
