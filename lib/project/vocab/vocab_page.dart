import 'package:flutter/material.dart';
import 'package:magic_english_project/project/base/basescreen.dart'; // your BaseScreen

class VocabPage extends StatelessWidget {
  final String notebookName;

  const VocabPage({super.key, required this.notebookName});

  Widget _buildVocabCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Encryption",
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text("Ý nghĩa: Đào giải mã hóa", style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 4),
                Text("Phiên âm: ɛnˈkrɪpʃən", style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 4),
                Text("Loại từ: Danh từ  •  Cấp độ: B1", style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 4),
                Text("Ví dụ: The encryption of...", style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
          Column(
            children: [
              Icon(Icons.volume_up, size: 20, color: Colors.grey[600]),
              const SizedBox(height: 8),
              Icon(Icons.edit, size: 20, color: Colors.grey[600]),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      // AppBar giống mẫu trước
      appBar: AppBar(
        title: Text("Sổ tay của bạn/$notebookName", style: const TextStyle(fontWeight: FontWeight.w600)),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      needBottom: true,             // hiện bottom nav
      activeIndex: 1,               // chỉnh index phù hợp với bottom nav của bạn
      bottomActions: [
        // hàm tương ứng với các icon ở bottom nav — thay đổi theo app
            () => Navigator.pushReplacementNamed(context, '/home'),
            () => Navigator.pushNamed(context, '/notebooks'),
            () => Navigator.pushNamed(context, '/history_point'),
            () {}, // ví dụ
      ],

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 120),
                children: [
                  _buildVocabCard(),
                  _buildVocabCard(),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }
}
