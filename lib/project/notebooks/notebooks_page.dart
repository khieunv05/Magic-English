import 'package:flutter/material.dart';
import 'package:magic_english_project/core/utils/toast_helper.dart';
import 'package:magic_english_project/project/vocab/vocab_page.dart';
import 'package:magic_english_project/core/utils/popup_helper.dart';
import 'package:magic_english_project/project/dto/notebook.dart';
import 'package:magic_english_project/project/notebooks/notebook_api.dart';
import 'package:provider/provider.dart';
import 'package:magic_english_project/project/provider/home_page_provider.dart';

enum _NotebookFilter { all, favorites }

class NotebooksPage extends StatefulWidget {
  const NotebooksPage({super.key});

  @override
  State<NotebooksPage> createState() => _NotebooksPageState();
}

class _NotebooksPageState extends State<NotebooksPage> {
  _NotebookFilter _filter = _NotebookFilter.all;
  bool _isLoading = true;
  List<Notebook> _notebooks = const [];

  @override
  void initState() {
    super.initState();
    _reloadNotebooks();
  }

  Future<void> _reloadNotebooks() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await NotebookApi.fetchNotebooks(perPage: 50);
      if (!mounted) return;
      setState(() {
        _notebooks = data;
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Notebook> get _filteredNotebooks {
    if (_filter == _NotebookFilter.favorites) {
      return _notebooks.where((n) => n.isFavorite).toList();
    }
    return _notebooks;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--/--/----';
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return '$dd/$mm/${date.year}';
  }

  Future<void> _toggleFavorite(Notebook notebook) async {
    final updated = notebook.copyWith(isFavorite: !notebook.isFavorite);
    setState(() {
      _notebooks = _notebooks
          .map((n) => n.id == notebook.id ? updated : n)
          .toList(growable: false);
    });
    try {
      await NotebookApi.update(
        notebook: notebook,
        isFavorite: updated.isFavorite,
      );
    } catch (e) {
      if (!mounted) return;
      // rollback
      setState(() {
        _notebooks = _notebooks
            .map((n) => n.id == notebook.id ? notebook : n)
            .toList(growable: false);
      });
      showTopNotification(
        context,
        type: ToastType.error,
        title: 'Lỗi',
        message: e.toString(),
      );
    }
  }

  Widget _buildNotebookCard(BuildContext context, Notebook notebook) {
    return Container(
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
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(width: 6, color: const Color(0xFF3A94E7)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE + ICONS
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notebook.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _toggleFavorite(notebook),
                          child: Icon(
                            notebook.isFavorite
                                ? Icons.bookmark
                                : Icons.bookmark_outline,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 6),

                        // MORE BUTTON
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 18),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditNotebookModal(
                                context,
                                notebook: notebook,
                              );
                            } else if (value == 'delete') {
                              showDeleteConfirm(
                                context: context,
                                notebookName: notebook.name,
                                onConfirm: () async {
                                  try {
                                    await NotebookApi.delete(id: notebook.id);
                                    if (!mounted) return;
                                    await context.read<HomePageProvider>().initData();
                                    showTopNotification(
                                      context,
                                      type: ToastType.success,
                                      title: 'Đã xóa',
                                      message:
                                          'Sổ tay "${notebook.name}" đã được xóa',
                                    );
                                    await _reloadNotebooks();
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
                              );
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text('Sửa sổ tay'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Xóa sổ tay',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        '${notebook.vocabulariesCount}',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Text('Từ vựng',
                        style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    Text(
                      'Ngày tạo: ${_formatDate(notebook.createdAt)}',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _showCreateNotebookModal(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    String name = '';
    final parentContext = context;

    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (BuildContext ctx) {
          bool isLoading = false;
          final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
          final maxHeight = MediaQuery.of(ctx).size.height * 0.90; // tối đa 90% màn hình

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: StatefulBuilder(builder: (context, setState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min, 
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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

                          Text('Thêm sổ tay', style: Theme.of(context).textTheme.titleLarge,),
                          const SizedBox(height: 12),

                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Tên sổ tay ',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),

                          Form(
                            key: _formKey,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                hintText: 'Nhập tên sổ tay',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                              onChanged: (v) => name = v,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Vui lòng nhập tên sổ tay';
                                }
                                return null;
                              },
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                            ),
                          ),

                          const SizedBox(height: 18),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3A94E7),

                                minimumSize: const Size.fromHeight(52),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: isLoading ? null : () async {
                                if (!(_formKey.currentState?.validate() ?? false)) return;
                                setState(() { isLoading = true; });
                                try {
                                  await NotebookApi.create(
                                    name: name.trim(),
                                    description: '',
                                    isFavorite: false,
                                  );
                                  if (!mounted) return;
                                  Navigator.of(ctx).pop();
                                    await parentContext.read<HomePageProvider>().initData();
                                  showTopNotification(
                                    parentContext,
                                    type: ToastType.success,
                                    title: 'Thành công',
                                    message: 'Tạo mới sổ tay "$name" thành công',
                                  );
                                  await _reloadNotebooks();
                                } catch (e) {
                                  if (!mounted) return;
                                  showTopNotification(
                                    parentContext,
                                    type: ToastType.error,
                                    title: 'Lỗi',
                                    message: e.toString(),
                                  );
                                } finally {
                                  setState(() { isLoading = false; });
                                }
                              },
                              child: isLoading
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,

                                ),
                              )
                                  : const Text('Xác nhận', style: TextStyle(fontSize: 16,color: Colors.white))
                            ),
                          ),

                          const SizedBox(height: 16),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          );
        }


    );
  }

  void _showEditNotebookModal(
      BuildContext context, {
        required Notebook notebook,
      }) {
    final formKey = GlobalKey<FormState>();
    String name = notebook.name;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.only(
            bottom: bottomInset,
            left: 16,
            right: 16,
            top: 12,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              bool isLoading = false;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const Text(
                    'Sửa sổ tay',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Form(
                    key: formKey,
                    child: TextFormField(
                      initialValue: notebook.name,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tên sổ tay',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => name = v,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Vui lòng nhập tên sổ tay';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              setState(() {
                                isLoading = true;
                              });
                              try {
                                await NotebookApi.update(
                                  notebook: notebook,
                                  name: name.trim(),
                                );
                                if (!mounted) return;
                                Navigator.pop(ctx);
                                await context.read<HomePageProvider>().initData();
                                showTopNotification(
                                  context,
                                  type: ToastType.success,
                                  title: 'Thành công',
                                  message: 'Đã cập nhật sổ tay "$name"',
                                );
                                await _reloadNotebooks();
                              } catch (e) {
                                if (!mounted) return;
                                showTopNotification(
                                  context,
                                  type: ToastType.error,
                                  title: 'Lỗi',
                                  message: e.toString(),
                                );
                              } finally {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A94E7),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Lưu'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        );
      },
    );
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sổ tay của bạn'),
        centerTitle: false,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _filter = _NotebookFilter.all;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _filter == _NotebookFilter.all
                          ? const Color(0xFF3A94E7)
                          : Colors.white,
                    ),
                    child: Text(
                      'Tất cả',
                      style: TextStyle(
                        color: _filter == _NotebookFilter.all
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _filter = _NotebookFilter.favorites;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _filter == _NotebookFilter.favorites
                            ? const Color(0xFF3A94E7)
                            : Colors.white,
                      ),
                      child: Text(
                        'Sổ tay yêu thích',
                        style: TextStyle(
                          color: _filter == _NotebookFilter.favorites
                              ? Colors.white
                              : Colors.black,
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (_filteredNotebooks.isEmpty
                        ? const Center(child: Text('Chưa có sổ tay'))
                        : GridView.count(
                            padding: const EdgeInsets.only(bottom: 120),
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 3 / 3.5,
                            children: _filteredNotebooks.map((notebook) {
                              return GestureDetector(
                                onTap: () async {
                                  final result = await Navigator.push<Map<String, dynamic>>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VocabPage(
                                        notebookName: notebook.name,
                                        notebookId: notebook.id,
                                      ),
                                    ),
                                  );
                                  if (!mounted) return;
                                  final changed = result?['changed'] == true;
                                  final rawCount = result?['count'];
                                  final count = rawCount is int
                                      ? rawCount
                                      : int.tryParse(rawCount?.toString() ?? '');
                                  if (changed && count != null) {
                                    setState(() {
                                      _notebooks = _notebooks
                                          .map(
                                            (n) => n.id == notebook.id
                                                ? n.copyWith(vocabulariesCount: count)
                                                : n,
                                          )
                                          .toList(growable: false);
                                    });
                                  }
                                },
                                child: _buildNotebookCard(context, notebook),
                              );
                            }).toList(),
                          )),
              ),
            ],
          ),
          Positioned(
              right: 16,
              bottom: 90,
              child: FloatingActionButton(
                onPressed: () => _showCreateNotebookModal(context),
                shape: const CircleBorder(),
                backgroundColor: const Color(0xFF3A94E7),
                child: const Icon(Icons.add, color: Colors.white),
              )
          ),
        ],
      ),
    );
  }
}
