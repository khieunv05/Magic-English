// lib/project/vocab/vocab_page.dart
import 'package:flutter/material.dart';
import 'package:magic_english_project/project/base/basescreen.dart';
import 'package:magic_english_project/core/utils/toast_helper.dart';

class VocabPage extends StatelessWidget {
  final String notebookName;

  const VocabPage({super.key, required this.notebookName});

  // CARD HIỂN THỊ TỪ
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
          // LEFT COLUMN (title + meaning)
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Meaning - allow multiple lines
                  Text(
                    meaning,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // RIGHT COLUMN (details + edit icon)
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: details (left) and edit icon (right)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Details column (phiên âm, loại từ, cấp độ)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Phiên âm: $phonetic",
                              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Loại từ: $type",
                              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Cấp độ: $level",
                              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),

                      // Edit icon aligned top-right
                      GestureDetector(
                        onTap: onEdit,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.edit_road,
                            size: 20,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Example (wrap to next lines)
                  Text(
                    "Ví dụ: $example",
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MODAL THÊM TỪ
  void _showAddVocabModal(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String word = '';
    String meaning = '';
    String phonetic = '';
    String type = '';
    String level = '';
    String example = '';
    bool isLoading = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // giữ để thấy bo góc
      builder: (BuildContext ctx) {
        // lấy inset & kích thước từ ctx (quan trọng)
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        final maxHeight = MediaQuery.of(ctx).size.height * 0.92;

        return SafeArea(
          child: AnimatedPadding(
            // AnimatedPadding sẽ animate khi bàn phím bật/tắt
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: bottomInset),
            child: FractionallySizedBox(
              heightFactor: null,
              // giới hạn chiều cao modal bằng maxHeight
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
                child: Container(
                  // container trắng chính
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      // scrollable content
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(left: 18, right: 18, top: 14, bottom: 0),
                          child: StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // drag bar
                                  Center(
                                    child: Container(
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // title + AI button (giữ nguyên)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Thêm từ vựng thủ công',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Điền bằng AI (demo)')),
                                          );
                                        },
                                        icon: const Icon(Icons.auto_fix_high, size: 14),
                                        label: const Text('Điền bằng AI', style: TextStyle(fontSize: 12)),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          side: BorderSide(color: Colors.grey.shade300),
                                          foregroundColor: Colors.black87,
                                          minimumSize: const Size(0, 32),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // FORM (giữ nguyên cấu trúc các field)
                                  Form(
                                    key: formKey,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Text('Từ vựng', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                          const SizedBox(width: 6),
                                          const Text('*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                        ]),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          decoration: InputDecoration(
                                            hintText: 'Nhập tên từ vựng',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                          ),
                                          onChanged: (v) => word = v,
                                          validator: (v) {
                                            if (v == null || v.trim().isEmpty) return 'Vui lòng nhập tên từ vựng';
                                            return null;
                                          },
                                        ),

                                        const SizedBox(height: 14),

                                        Row(children: [
                                          Text('Ý nghĩa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                          const SizedBox(width: 6),
                                          const Text('*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                        ]),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          minLines: 1,
                                          decoration: InputDecoration(
                                            hintText: 'Nhập ý nghĩa',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                          ),
                                          onChanged: (v) => meaning = v,
                                          validator: (v) {
                                            if (v == null || v.trim().isEmpty) return 'Vui lòng nhập ý nghĩa';
                                            return null;
                                          },
                                        ),

                                        const SizedBox(height: 14),

                                        Text('Phiên âm', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          decoration: InputDecoration(
                                            hintText: 'Nhập phiên âm',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                          ),
                                          onChanged: (v) => phonetic = v,
                                        ),

                                        const SizedBox(height: 14),

                                        Text('Loại từ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 8),
                                        DropdownButtonFormField<String>(
                                          value: type.isEmpty ? null : type,
                                          decoration: InputDecoration(
                                            hintText: 'Chọn loại từ',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          ),
                                          items: const [
                                            DropdownMenuItem(value: 'Danh từ', child: Text('Danh từ')),
                                            DropdownMenuItem(value: 'Động từ', child: Text('Động từ')),
                                            DropdownMenuItem(value: 'Tính từ', child: Text('Tính từ')),
                                          ],
                                          onChanged: (v) => setState(() => type = v ?? ''),
                                        ),

                                        const SizedBox(height: 14),

                                        Text('Cấp độ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 8),
                                        DropdownButtonFormField<String>(
                                          value: level.isEmpty ? null : level,
                                          decoration: InputDecoration(
                                            hintText: 'Chọn cấp độ',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          ),
                                          items: const [
                                            DropdownMenuItem(value: 'A1', child: Text('A1')),
                                            DropdownMenuItem(value: 'A2', child: Text('A2')),
                                            DropdownMenuItem(value: 'B1', child: Text('B1')),
                                            DropdownMenuItem(value: 'B2', child: Text('B2')),
                                          ],
                                          onChanged: (v) => setState(() => level = v ?? ''),
                                        ),

                                        const SizedBox(height: 14),

                                        Text('Ví dụ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          minLines: 4,
                                          maxLines: 8,
                                          decoration: InputDecoration(
                                            hintText: 'Nhập ví dụ: The encryption of the system ...',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                          ),
                                          onChanged: (v) => example = v,
                                        ),

                                        const SizedBox(height: 18),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),

                      // sticky footer: ĐẶT padding bottom = max(14, bottomInset)
                      Padding(
                        padding: EdgeInsets.fromLTRB(18, 10, 18, 14 + bottomInset),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              return ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                  if (!(formKey.currentState?.validate() ?? false)) return;
                                  setState(() => isLoading = true);

                                  await Future.delayed(const Duration(milliseconds: 600));
                                  Navigator.of(ctx).pop();

                                  // showTopNotification(...) -- giữ như cũ
                                  setState(() => isLoading = false);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3A94E7),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: isLoading
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text('Xác nhận', style: TextStyle(fontSize: 16,color: Colors.white)),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  // MODAL SỬA TỪ
  void _showEditVocabModal(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        final maxHeight = MediaQuery.of(ctx).size.height * 0.92;

        // Các controller mẫu (bạn có thể thay giá trị khởi tạo bằng dữ liệu thực)
        final wordCtrl = TextEditingController(text: "Encryption");
        final meaningCtrl = TextEditingController(text: "The process of encoding information...");
        final phoneticCtrl = TextEditingController(text: "/ɪnˈkrɪp.ʃən/");
        final exampleCtrl = TextEditingController(text: "The encryption of the system prevented data theft.");

        String type = ''; // 'Danh từ' | 'Động từ' | 'Tính từ'
        String level = ''; // 'A1' | 'A2' | 'B1' | 'B2'

        return SafeArea(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: bottomInset),
            child: FractionallySizedBox(
              // dùng ConstrainedBox giữ chiều cao tối đa
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      // Expanded scrollable content
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(left: 18, right: 18, top: 14, bottom: 0),
                          child: StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // drag bar
                                  Center(
                                    child: Container(
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // title + AI button
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Chỉnh sửa từ vựng',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Điền bằng AI (demo)')),
                                          );
                                        },
                                        icon: const Icon(Icons.auto_fix_high, size: 14),
                                        label: const Text('Điền bằng AI', style: TextStyle(fontSize: 12)),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          side: BorderSide(color: Colors.grey.shade300),
                                          foregroundColor: Colors.black87,
                                          minimumSize: const Size(0, 32),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // FORM
                                  Form(
                                    key: formKey,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // --- Từ vựng ---
                                        Row(children: [
                                          Text('Từ vựng', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                          const SizedBox(width: 6),
                                          const Text('*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                        ]),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: wordCtrl,
                                          decoration: InputDecoration(
                                            hintText: 'Nhập tên từ vựng',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                          ),
                                          validator: (v) {
                                            if (v == null || v.trim().isEmpty) return 'Vui lòng nhập tên từ vựng';
                                            return null;
                                          },
                                        ),

                                        const SizedBox(height: 14),

                                        // --- Ý nghĩa ---
                                        Row(children: [
                                          Text('Ý nghĩa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                          const SizedBox(width: 6),
                                          const Text('*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                        ]),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: meaningCtrl,
                                          minLines: 1,
                                          decoration: InputDecoration(
                                            hintText: 'Nhập ý nghĩa',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                          ),
                                          validator: (v) {
                                            if (v == null || v.trim().isEmpty) return 'Vui lòng nhập ý nghĩa';
                                            return null;
                                          },
                                        ),

                                        const SizedBox(height: 14),

                                        // --- Phiên âm ---
                                        Text('Phiên âm', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: phoneticCtrl,
                                          decoration: InputDecoration(
                                            hintText: 'Nhập phiên âm',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                          ),
                                        ),

                                        const SizedBox(height: 14),

                                        // --- Loại từ ---
                                        Text('Loại từ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 8),
                                        DropdownButtonFormField<String>(
                                          value: type.isEmpty ? null : type,
                                          decoration: InputDecoration(
                                            hintText: 'Chọn loại từ',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          ),
                                          items: const [
                                            DropdownMenuItem(value: 'Danh từ', child: Text('Danh từ')),
                                            DropdownMenuItem(value: 'Động từ', child: Text('Động từ')),
                                            DropdownMenuItem(value: 'Tính từ', child: Text('Tính từ')),
                                          ],
                                          onChanged: (v) => setState(() => type = v ?? ''),
                                        ),

                                        const SizedBox(height: 14),

                                        // --- Cấp độ ---
                                        Text('Cấp độ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 8),
                                        DropdownButtonFormField<String>(
                                          value: level.isEmpty ? null : level,
                                          decoration: InputDecoration(
                                            hintText: 'Chọn cấp độ',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          ),
                                          items: const [
                                            DropdownMenuItem(value: 'A1', child: Text('A1')),
                                            DropdownMenuItem(value: 'A2', child: Text('A2')),
                                            DropdownMenuItem(value: 'B1', child: Text('B1')),
                                            DropdownMenuItem(value: 'B2', child: Text('B2')),
                                          ],
                                          onChanged: (v) => setState(() => level = v ?? ''),
                                        ),

                                        const SizedBox(height: 14),

                                        // --- Ví dụ ---
                                        Text('Ví dụ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: exampleCtrl,
                                          minLines: 4,
                                          maxLines: 8,
                                          decoration: InputDecoration(
                                            hintText: 'Nhập ví dụ: The encryption of the system ...',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                          ),
                                        ),

                                        const SizedBox(height: 18),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),

                      // STICKY FOOTER luôn nằm trên bàn phím
                      Padding(
                        padding: EdgeInsets.fromLTRB(18, 10, 18, 14 + bottomInset),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              return ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                  if (!(formKey.currentState?.validate() ?? false)) return;
                                  setState(() => isLoading = true);

                                  // TODO: gọi API update ở đây, dùng giá trị từ controller / dropdowns
                                  await Future.delayed(const Duration(milliseconds: 600));

                                  Navigator.of(ctx).pop();

                                  showTopNotification(
                                    context,
                                    type: ToastType.success,
                                    title: 'Thành công',
                                    message: 'Sửa thông tin từ vựng thành công.',
                                  );

                                  setState(() => isLoading = false);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3A94E7),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: isLoading
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text('Xác nhận', style: TextStyle(fontSize: 16,color: Colors.white)),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // UI CHÍNH
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      appBar: AppBar(
        title: Text("Sổ tay của bạn/$notebookName",
            style: const TextStyle(fontWeight: FontWeight.w600)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.settings_outlined),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.search),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      needBottom: true,
      activeIndex: 1,
      bottomActions: [
            () => Navigator.pushReplacementNamed(context, '/home'),
            () => Navigator.pushNamed(context, '/notebooks'),
            () => Navigator.pushNamed(context, '/history_point'),
            () {},
      ],
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 140),
              children: [
                const SizedBox(height: 12),
                _buildVocabCard(
                  context,
                  title: "Encryption",
                  meaning: "Ý nghĩa: Đào giải, mã hóa",
                  phonetic: "ɛnˈkrɪpʃən",
                  type: "Danh từ",
                  level: "B1",
                  example: "The encryption of the system prevents the data leakage in the system.",
                  onEdit: () => _showEditVocabModal(context),
                ),

              ],
            ),
          ),
          Positioned(
            right: 24,
            bottom: 100,
            child: FloatingActionButton(
              onPressed: () => _showAddVocabModal(context),
              backgroundColor: const Color(0xFF3A94E7),
              elevation: 3,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 28, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
