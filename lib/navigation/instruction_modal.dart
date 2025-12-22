import 'package:flutter/material.dart';
class InstructionModal extends StatelessWidget {
  const InstructionModal({super.key});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topRight,
        children: <Widget>[
          // NỘI DUNG CHÍNH CỦA MODAL
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F0F8),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'HƯỚNG DẪN SỬ DỤNG BẢNG ĐIỀU KHIỂN TIẾN ĐỘ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF000000),
                    height: 1.5,
                  ),
                ),
                const Divider(color: Colors.blueGrey, thickness: 0.5, height: 20),
                _buildInstructionText(
                  'Bảng điều khiển cung cấp tổng quan về quá trình học từ vựng của bạn thông qua các chỉ số và biểu đồ trực quan.',
                ),
                const SizedBox(height: 10),

                // Các mục chi tiết
                _buildListItem(
                  title: 'Số từ vựng đã học',
                  description: 'Thể hiện tổng số từ vựng bạn đã tiếp thu và lưu trong hệ thống.',
                ),
                _buildListItem(
                  title: 'Phân loại theo từ loại',
                  description: 'Cho biết cơ cấu từ vựng của bạn theo danh từ, động từ, tính từ và các loại từ khác. Biểu đồ trình bày tỉ lệ và số lượng để giúp đánh giá mức độ cân bằng trong quá trình học.',
                ),
                _buildListItem(
                  title: 'Phân loại theo cấp độ CEFR',
                  description: 'Phân bổ số lượng từ vựng theo các cấp độ A1–C2, hỗ trợ theo dõi sự tiến bộ và định hướng lộ trình học phù hợp.',
                ),
                _buildListItem(
                  title: 'Tương tác với chế độ hiển thị',
                  description: 'Bạn có thể chuyển đổi chế độ hiển của của các màn hình khác nhau bằng thanh điều hướng và có thể tương tác với biểu đồ để hiện thị dữ liệu nhằm đảm bảo báo số liệu phản ánh đúng tiến độ hiện tại.',
                ),
                const SizedBox(height: 15),
                const Text(
                  'Chúc bạn sử dụng ứng dụng hiệu quả!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black87),
                ),
              ],
            ),
          ),

          // NÚT ĐÓNG (X)
          Positioned(
            top: -15, // Đẩy nút lên trên và ra ngoài khung một chút
            right: -15, // Đẩy nút sang phải và ra ngoài khung một chút
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
    );
  }

  Widget _buildListItem({required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• $title',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Colors.black),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: const TextStyle(fontSize: 13.5, color: Colors.black87, height: 1.3),
          ),
        ],
      ),
    );
  }
}