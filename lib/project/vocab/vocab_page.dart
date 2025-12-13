import 'package:flutter/material.dart';
import 'package:magic_english_project/project/base/basescreen.dart';
import 'package:magic_english_project/core/utils/toast_helper.dart';
import 'flash_card_page.dart';

class VocabPage extends StatelessWidget {
  final String notebookName;

  const VocabPage({super.key, required this.notebookName});

  Widget _buildVocabCard(
      BuildContext context, {
        required String title,
        required String meaning,
        required String phonetic,
        required String type,
        required String level,
        required String example,
        VoidCallback? onEdit,
      }) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  meaning,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // RIGHT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Phiên âm: $phonetic",
                    style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                const SizedBox(height: 4),
                Text("Loại từ: $type",
                    style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                const SizedBox(height: 4),
                Text("Cấp độ: $level",
                    style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                const SizedBox(height: 8),
                Text(
                  "Ví dụ: $example",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                  TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    // ===== DATA MẪU =====
    const word = "Encryption";
    const meaning = "Đào giải, mã hóa";
    const phonetic = "/ɪnˈkrɪp.ʃən/";
    const type = "Danh từ";
    const level = "B1";
    const example =
        "The encryption of the system prevented data theft.";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sổ tay của bạn/$notebookName",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          ListView(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FlashCardPage(
                        word: word,
                        meaning: meaning,
                        phonetic: phonetic,
                        type: type,
                        level: level,
                        example: example,
                      ),
                    ),
                  );
                },
                child: _buildVocabCard(
                  context,
                  title: word,
                  meaning: meaning,
                  phonetic: phonetic,
                  type: type,
                  level: level,
                  example: example,
                ),
              ),
            ],
          ),

          // FAB
          Positioned(
            right: 24,
            bottom: 100,
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: const Color(0xFF3A94E7),
              child:
              const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
