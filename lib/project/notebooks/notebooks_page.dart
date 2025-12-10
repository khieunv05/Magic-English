import 'package:flutter/material.dart';
import 'package:test_project/project/base/basescreen.dart';
import 'package:test_project/project/home/home_page.dart';
import 'package:test_project/project/pointanderror/historypoint.dart';
import 'package:test_project/core/utils/toast_helper.dart';

class NotebooksPage extends StatelessWidget {
  const NotebooksPage({super.key});

  Widget _buildNotebookCard(BuildContext context, String title, int count) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blue)),
                const Icon(Icons.bookmark_outline, size: 18),
              ],
            ),
            const SizedBox(height: 12),
            Text('$count', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 4),
            Text('Từ vựng', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Text('Ngày tạo: 21/12/2025', style: Theme.of(context).textTheme.bodySmall),
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
                // đảm bảo nội dung có thể scroll khi cần
                child: ConstrainedBox(
                  // cho phép modal mở rộng tối đa nhưng vẫn thu gọn với nội dung nhỏ
                  constraints: BoxConstraints(
                    maxHeight: maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: StatefulBuilder(builder: (context, setState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min, // rất quan trọng
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

                          Text('Thêm sổ tay', style: Theme.of(context).textTheme.titleLarge),
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
                                  : const Text('Xác nhận'),
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


  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      appBar: AppBar(
        leading: IconButton(onPressed: (){ Navigator.of(context).pop(); }, icon: const Icon(Icons.arrow_back)),
        title: const Text('Sổ tay của bạn'),
        centerTitle: false,
        elevation: 0,
      ),
      needBottom: true,
      activeIndex: 1,
      bottomActions: [
        () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage())),
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotebooksPage())),
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPoint())),
        () {},
      ],
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(onPressed: (){}, child: const Text('Tất cả')),
                  const SizedBox(width: 8),
                  OutlinedButton(onPressed: (){}, child: const Text('Sổ tay yêu thích')),
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
                    _buildNotebookCard(context, 'Sổ tay IT', 45),
                    _buildNotebookCard(context, 'Sổ tay marketing', 47),
                    _buildNotebookCard(context, 'Sổ tay du lịch', 66),
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
