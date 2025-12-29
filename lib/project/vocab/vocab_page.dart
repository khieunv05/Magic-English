import 'package:flutter/material.dart';
import 'package:magic_english_project/core/utils/toast_helper.dart';
import 'package:magic_english_project/project/vocab/flash_card_page.dart';
import 'package:magic_english_project/project/dto/vocabulary.dart';
import 'package:magic_english_project/project/vocab/vocab_api.dart';

enum _VocabMenuAction { edit, delete }

class VocabPage extends StatefulWidget {
  final String notebookName;
  final int notebookId;

  const VocabPage({
    super.key,
    required this.notebookName,
    required this.notebookId,
  });

  @override
  State<VocabPage> createState() => _VocabPageState();
}

class _VocabPageState extends State<VocabPage> {
  bool _isLoading = true;
  List<Vocabulary> _items = const [];

  static const List<String> _cefrOptions = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  static const Map<String, String> _posLabelsVi = {
    'noun': 'Danh từ',
    'verb': 'Động từ',
    'adjective': 'Tính từ',
    'adverb': 'Trạng từ',
    'preposition': 'Giới từ',
    'conjunction': 'Liên từ',
    'pronoun': 'Đại từ',
    'determiner': 'Từ hạn định',
    'interjection': 'Thán từ',
  };

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _isLoading = true);
    try {
      final data = await VocabApi.fetchByNotebookId(notebookId: widget.notebookId);
      if (!mounted) return;
      setState(() => _items = data);
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

  // ============================================================
  //                 MODAL THÊM / SỬA (FIX FULL)
  // ============================================================
  void _showVocabModal(BuildContext context, {Vocabulary? vocab}) {
    final isEdit = vocab != null;
    final formKey = GlobalKey<FormState>();

    final wordCtrl = TextEditingController(text: vocab?.word ?? '');
    final meaningCtrl = TextEditingController(text: vocab?.meaning ?? '');
    final ipaCtrl = TextEditingController(text: vocab?.ipa ?? '');
    final exampleCtrl = TextEditingController(text: vocab?.example ?? '');

    String? selectedPos = (vocab?.partOfSpeech.isNotEmpty ?? false) ? vocab!.partOfSpeech : null;
    if (selectedPos != null && !_posLabelsVi.containsKey(selectedPos)) {
      selectedPos = null;
    }

    String? selectedCefr =
    (vocab?.cefrLevel.isNotEmpty ?? false) ? vocab!.cefrLevel.toUpperCase() : null;
    if (selectedCefr != null && !_cefrOptions.contains(selectedCefr)) {
      selectedCefr = null;
    }

    final parentContext = context;

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        bool isSubmitting = false;
        bool isEnriching = false;

        Future<void> onEnrich(StateSetter setModalState) async {
          final word = wordCtrl.text.trim();
          if (word.isEmpty) {
            showTopNotification(
              parentContext,
              type: ToastType.error,
              title: 'Thiếu từ',
              message: 'Vui lòng nhập từ vựng trước',
            );
            return;
          }

          if (!sheetCtx.mounted) return;
          setModalState(() => isEnriching = true);
          try {
            final result = await VocabApi.enrich(word: word);

            if (!sheetCtx.mounted) return;
            final meaningVi = (result['meaning_vi'] ?? '').toString();
            final ipa = (result['ipa'] ?? '').toString();
            final pos = (result['part_of_speech'] ?? '').toString();
            final cefr = (result['cefr'] ?? '').toString().toUpperCase();
            final examplesRaw = result['examples'];
            final examples = examplesRaw is List
                ? examplesRaw.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList()
                : const <String>[];

            if (meaningVi.isNotEmpty) meaningCtrl.text = meaningVi;
            if (ipa.isNotEmpty) ipaCtrl.text = ipa;
            if (examples.isNotEmpty) exampleCtrl.text = examples.join('\n');

            if (_posLabelsVi.containsKey(pos)) selectedPos = pos;
            if (_cefrOptions.contains(cefr)) selectedCefr = cefr;
          } catch (e) {
            showTopNotification(
              parentContext,
              type: ToastType.error,
              title: 'Lỗi',
              message: e.toString(),
            );
          } finally {
            if (sheetCtx.mounted) {
              setModalState(() => isEnriching = false);
            }
          }
        }

        return StatefulBuilder(
          builder: (context, setModalState) {
            // AnimatedPadding để nút đáy tự đội lên khi mở bàn phím
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;

            return AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: bottomInset),
              child: DraggableScrollableSheet(
                initialChildSize: 0.92,
                minChildSize: 0.55,
                maxChildSize: 0.95,
                expand: false,
                builder: (context, scrollController) {
                  return Material(
                    color: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        // ===== Header (kéo xuống được + có nút đóng) =====
                        _ModalHeader(
                          title: isEdit ? 'Chỉnh sửa từ vựng' : 'Thêm từ vựng',
                          onClose: () => Navigator.of(sheetCtx).pop(),
                        ),


                        // ===== Form cuộn riêng (không đẩy nút xuống dưới) =====
                        Expanded(
                          child: ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                            children: [
                              Form(
                                key: formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'Từ vựng',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(fontWeight: FontWeight.w700),
                                              ),
                                              const TextSpan(
                                                text: ' *',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),

                                        // ===== Nút AI chuẩn mẫu =====
                                        _AiPillButton(
                                          isLoading: isEnriching,
                                          onPressed: isEnriching ? null : () => onEnrich(setModalState),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: wordCtrl,
                                      decoration: const InputDecoration(
                                        hintText: 'Nhập từ vựng',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Vui lòng nhập từ vựng';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Ý nghĩa',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(fontWeight: FontWeight.w700),
                                          ),
                                          const TextSpan(
                                            text: ' *',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: meaningCtrl,
                                      decoration: const InputDecoration(
                                        hintText: 'Nhập ý nghĩa',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Vui lòng nhập ý nghĩa';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    Text(
                                      'Phiên âm',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: ipaCtrl,
                                      decoration: const InputDecoration(
                                        hintText: 'Nhập phiên âm',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Loại từ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(fontWeight: FontWeight.w700),
                                          ),
                                          const TextSpan(
                                            text: ' *',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value: selectedPos,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                      ),
                                      items: _posLabelsVi.entries
                                          .map(
                                            (e) => DropdownMenuItem<String>(
                                          value: e.key,
                                          child: Text(e.value),
                                        ),
                                      )
                                          .toList(growable: false),
                                      onChanged: (v) => setModalState(() => selectedPos = v),
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Vui lòng chọn loại từ';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Cấp độ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(fontWeight: FontWeight.w700),
                                          ),
                                          const TextSpan(
                                            text: ' *',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value: selectedCefr,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                      ),
                                      items: _cefrOptions
                                          .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                                          .toList(growable: false),
                                      onChanged: (v) => setModalState(() => selectedCefr = v),
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'CEFR phải thuộc A1, A2, B1, B2, C1 hoặc C2.';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    Text(
                                      'Ví dụ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: exampleCtrl,
                                      decoration: const InputDecoration(
                                        hintText: 'Nhập ví dụ',
                                        border: OutlineInputBorder(),
                                      ),
                                      minLines: 3,
                                      maxLines: 6,
                                    ),

                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== Nút xác nhận GHIM ĐÁY (không bị quăng xuống dưới) =====
                        SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3A94E7),
                                  minimumSize: const Size.fromHeight(52),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                onPressed: isSubmitting
                                    ? null
                                    : () async {
                                  if (!(formKey.currentState?.validate() ?? false)) return;

                                  if (!sheetCtx.mounted) return;
                                  setModalState(() => isSubmitting = true);

                                  try {
                                    final word = wordCtrl.text.trim();
                                    final meaning = meaningCtrl.text.trim();
                                    final ipa = ipaCtrl.text.trim();
                                    final example = exampleCtrl.text.trim();
                                    final pos = (selectedPos ?? '').trim();
                                    final cefr = (selectedCefr ?? '').trim();

                                    if (isEdit) {
                                      await VocabApi.update(
                                        id: vocab!.id,
                                        word: word,
                                        meaning: meaning,
                                        partOfSpeech: pos,
                                        ipa: ipa,
                                        example: example,
                                        cefrLevel: cefr,
                                      );
                                    } else {
                                      await VocabApi.createInNotebook(
                                        notebookId: widget.notebookId,
                                        word: word,
                                        meaning: meaning,
                                        partOfSpeech: pos,
                                        ipa: ipa,
                                        example: example,
                                        cefrLevel: cefr,
                                      );
                                    }

                                    if (!mounted) return;

                                    if (sheetCtx.mounted && Navigator.of(sheetCtx).canPop()) {
                                      Navigator.of(sheetCtx).pop();
                                    }

                                    showTopNotification(
                                      parentContext,
                                      type: ToastType.success,
                                      title: 'Thành công',
                                      message: isEdit ? 'Đã cập nhật "$word"' : 'Đã thêm từ vựng "$word"',
                                    );
                                    await _reload();
                                  } catch (e) {
                                    if (!mounted) return;
                                    showTopNotification(
                                      parentContext,
                                      type: ToastType.error,
                                      title: 'Lỗi',
                                      message: e.toString(),
                                    );
                                  } finally {
                                    if (sheetCtx.mounted) {
                                      setModalState(() => isSubmitting = false);
                                    }
                                  }
                                },
                                child: isSubmitting
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Text(
                                  'Xác nhận',
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  //                 CARD VOCAB (GIỮ NGUYÊN)
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
        required VoidCallback onDelete,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 42, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                    onDelete();
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
  //                 MODAL XÓA (GIỮ NGUYÊN)
  // ============================================================
  void _showDeleteConfirm(BuildContext context, {required Vocabulary vocab}) {
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await VocabApi.delete(id: vocab.id);
                  if (!mounted) return;
                  showTopNotification(
                    context,
                    type: ToastType.success,
                    title: 'Đã xóa',
                    message: 'Đã xóa "${vocab.word}"',
                  );
                  await _reload();
                } catch (e) {
                  if (!mounted) return;
                  showTopNotification(
                    context,
                    type: ToastType.error,
                    title: 'Lỗi',
                    message: e.toString(),
                  );
                }
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  void _showEditVocabModal(BuildContext context, {required Vocabulary vocab}) {
    _showVocabModal(context, vocab: vocab);
  }

  // ============================================================
  //                          UI CHÍNH
  // ============================================================
  @override
  Widget build(BuildContext context) {
    // padding bottom để list không bị FAB che (nếu bạn có bottom nav thì tăng thêm)
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sổ tay của bạn/${widget.notebookName}",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: const [
          Icon(Icons.settings_outlined),
          SizedBox(width: 12),
          Icon(Icons.search),
          SizedBox(width: 12),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_items.isEmpty
          ? Center(
        child: Text(
          'Sổ tay ${widget.notebookName} chưa có từ vựng nào.',
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
      )
          : RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 96 + safeBottom),
          children: _items.map((v) {
            return _buildVocabCard(
              context,
              title: v.word,
              meaning: v.meaning.isEmpty ? '—' : v.meaning,
              phonetic: v.ipa.isEmpty ? '—' : v.ipa,
              type: v.partOfSpeech.isEmpty ? '—' : v.partOfSpeech,
              level: v.cefrLevel.isEmpty ? '—' : v.cefrLevel,
              example: v.example.isEmpty ? '—' : v.example,
              onEdit: () => _showEditVocabModal(context, vocab: v),
              onDelete: () => _showDeleteConfirm(context, vocab: v),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FlashCardPage(
                    notebookId: widget.notebookId,
                    initialVocabId: v.id,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3A94E7),
        onPressed: () => _showVocabModal(context),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }
}

// ============================================================
//                   HEADER MODAL (drag + close)
// ============================================================
class _ModalHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const _ModalHeader({
    required this.title,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

// ============================================================
//            NÚT "ĐIỀN BẰNG AI" CHUẨN GIỐNG MẪU
// ============================================================
class _AiPillButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const _AiPillButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: isLoading
          ? const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
          : const Icon(Icons.auto_awesome_rounded, size: 25),
      label: const Text(
        'Điền bằng AI',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        side: const BorderSide(color: Colors.black, width: 2),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
