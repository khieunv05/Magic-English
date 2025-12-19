import 'package:flutter/material.dart';
import 'package:magic_english_project/core/utils/toast_helper.dart';
import 'package:magic_english_project/project/vocab/flash_card_page.dart';

enum _VocabMenuAction { edit, delete }

class VocabPage extends StatelessWidget {
  final String notebookName;

  const VocabPage({super.key, required this.notebookName});

  // ============================================================
  //                        CARD TỪ VỰNG
  // ============================================================
  Widget _buildVocabCard(
      BuildContext context, {
        required String title,
        required String meaning,
        required String phonetic,
        required String type,
        required String level,
        required String example,
        required VoidCallback onEdit,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Stack(
          children: [
            // ================= CONTENT =================
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 42, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6), // chừa chỗ cho icon ⋮

                  Row(
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
                            const SizedBox(height: 10),
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
                            const SizedBox(height: 6),
                            Text("Loại từ: $type",
                                style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                            const SizedBox(height: 6),
                            Text("Cấp độ: $level",
                                style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                            const SizedBox(height: 10),
                            Text(
                              "Ví dụ: $example",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Positioned(
              top: 6,
              right: 6,
              child: PopupMenuButton<_VocabMenuAction>(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.more_vert,
                  size: 22,
                  color: Colors.grey[700],
                ),
                onSelected: (action) {
                  if (action == _VocabMenuAction.edit) {
                    onEdit();
                  } else {
                    _showDeleteConfirm(context);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _VocabMenuAction.edit,
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Sửa từ vựng'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: _VocabMenuAction.delete,
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Xóa từ vựng'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }

  // ============================================================
  //                 MODAL XÁC NHẬN XÓA
  // ============================================================
  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Xóa từ vựng?'),
          content: const Text(
            'Bạn có chắc chắn muốn xóa từ vựng này không? '
                'Hành động này không thể hoàn tác.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                showTopNotification(
                  context,
                  type: ToastType.success,
                  title: 'Đã xóa',
                  message: 'Từ vựng đã được xóa thành công.',
                );
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  //                 MODAL SỬA (GIỮ NGUYÊN)
  // ============================================================
  void _showEditVocabModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            height: MediaQuery.of(ctx).size.height * 0.9,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Center(
              child: Text(
                'MODAL SỬA TỪ (giữ nguyên logic cũ)',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  //                          UI CHÍNH
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sổ tay của bạn/$notebookName",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        leading:
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
        actions: const [
          Icon(Icons.settings_outlined),
          SizedBox(width: 12),
          Icon(Icons.search),
          SizedBox(width: 12),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
        children: [
          _buildVocabCard(
            context,
            title: "Encryption",
            meaning: "Ý nghĩa: Đào giải, mã hóa",
            phonetic: "ɛnˈkrɪpʃənnn",
            type: "Danh từ",
            level: "B1",
            example: "The encryption prevents data leakage.",
            onEdit: () => _showEditVocabModal(context),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FlashCardPage(
                  word: "Encryption",
                  meaning: "Đào giải, mã hóa",
                  phonetic: "ɛnˈkrɪpʃən",
                  type: "Danh từ",
                  level: "B1",
                  example:
                  "The encryption of the system prevents data leakage.",
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3A94E7),
        onPressed: () {
          showTopNotification(
            context,
            type: ToastType.success,
            title: 'Demo',
            message: 'Mở modal thêm từ (giữ logic cũ)',
          );
        },
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }
}
