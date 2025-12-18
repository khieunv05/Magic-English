import 'package:flutter/material.dart';
import 'package:magic_english_project/project/base/basescreen.dart';
import 'package:magic_english_project/project/home/home_page.dart';
import 'package:magic_english_project/project/pointanderror/historypoint.dart';
import 'package:magic_english_project/core/utils/toast_helper.dart';
import 'package:magic_english_project/project/vocab/vocab_page.dart';
import 'package:magic_english_project/core/utils/popup_helper.dart';

class NotebooksPage extends StatelessWidget {
  const NotebooksPage({super.key});

  Widget _buildNotebookCard(
      BuildContext context,
      String title,
      int count,
      ) {
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
                            title,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const Icon(Icons.bookmark_outline, size: 18),
                        const SizedBox(width: 6),

                        // MORE BUTTON
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 18),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditNotebookModal(
                                context,
                                oldName: title,
                              );
                            } else if (value == 'delete') {
                              showDeleteConfirm(
                                context: context,
                                notebookName: title,
                                onConfirm: () {
                                  showTopNotification(
                                    context,
                                    type: ToastType.success,
                                    title: 'Đã xóa',
                                    message: 'Sổ tay "$title" đã được xóa',
                                  );
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
                    Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text('Từ vựng',
                        style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    const Text(
                      'Ngày tạo: 21/12/2025',
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
                                await Future.delayed(const Duration(milliseconds: 600));
                                Navigator.of(ctx).pop();
                                // show top notification instead of snackbar
                                showTopNotification(parentContext, type: ToastType.success, title: 'Thành công', message: 'Tạo mới sổ tay "' + name + '" thành công');
                                setState(() { isLoading = false; });
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
        required String oldName,
      }) {
    final formKey = GlobalKey<FormState>();
    String name = oldName;

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
                      initialValue: oldName,
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
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        Navigator.pop(ctx);
                        showTopNotification(
                          context,
                          type: ToastType.success,
                          title: 'Thành công',
                          message: 'Đã cập nhật sổ tay "$name"',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A94E7),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Lưu'),
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
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A94E7),
                    ),
                    child: const Text('Tất cả',style: TextStyle(color: Colors.white),),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: (){},style: ElevatedButton.styleFrom(
                    backgroundColor:  Colors.white,
                  ), child: const Text('Sổ tay yêu thích',style:TextStyle(color:Colors.black) )),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.count(
                  padding: const EdgeInsets.only(bottom: 120),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3/3.5,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VocabPage(notebookName: "Sổ tay IT"),
                          ),
                        );
                      },
                      child: _buildNotebookCard(context, 'Sổ tay IT', 45),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VocabPage(notebookName: "Sổ tay IT"),
                          ),
                        );
                      },
                      child: _buildNotebookCard(context, 'Sổ tay Marketing', 131),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VocabPage(notebookName: "Sổ tay IT"),
                          ),
                        );
                      },
                      child: _buildNotebookCard(context, 'Sổ tay NET', 31),
                    ),
                  ],
                ),
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
