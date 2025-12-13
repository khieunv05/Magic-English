import 'package:flutter/material.dart';
import 'package:magic_english_project/project/dto/writingdto.dart';
import 'package:magic_english_project/project/theme/apptheme.dart';

class ErrorAndSuggest extends StatelessWidget {
  final WritingDto writingDto;

  const ErrorAndSuggest({super.key, required this.writingDto});

  // ------------------------------
  // 🔵 CARD CHUNG (Content + Suggest)
  // ------------------------------
  Widget buildInfoCard({
    required Color avatarColor,
    required IconData icon,
    required String text,
    required BuildContext context,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.07),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: avatarColor,
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.45,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------
  // 🔴 CARD LỖI (Many items)
  // ------------------------------
  Widget buildErrorListCard({
    required Color avatarColor,
    required IconData icon,
    required List<String> errors,
    required BuildContext context,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.07),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header icon
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: avatarColor,
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 16),
              Text(
                "Các lỗi bạn mắc phải",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (errors.isEmpty)
            Text(
              "Không có lỗi nào 🎉",
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            )
          else
            Column(
              children: List.generate(
                errors.length,
                    (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.circle, size: 8, color: Colors.redAccent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          errors[index],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  // ------------------------------
  // 🔵 MÀU CHO ĐIỂM
  // ------------------------------
  Color getBackgroundColorFromPoint(int point) {
    if (point < 5) return Colors.redAccent;
    if (point < 8) return Colors.orangeAccent;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chấm điểm & sửa lỗi", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        physics: const BouncingScrollPhysics(),

        child: Column(
          children: [

            const SizedBox(height: 24),

            // 🟢 ĐIỂM TRUNG TÂM
            CircleAvatar(
              radius: 42,
              backgroundColor: getBackgroundColorFromPoint(writingDto.point),
              child: Text(
                writingDto.point.toString(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 📝 BÀI LÀM
            buildInfoCard(
              avatarColor: Theme.of(context).primaryColor,
              icon: Icons.book_outlined,
              text: writingDto.content,
              context: context,
            ),

            const SizedBox(height: 28),

            // ❌ DANH SÁCH LỖI
            buildErrorListCard(
              avatarColor: Colors.redAccent,
              icon: Icons.close_rounded,
              errors: writingDto.errors,
              context: context,
            ),

            const SizedBox(height: 28),

            // ✨ GỢI Ý
            buildInfoCard(
              avatarColor: Colors.green,
              icon: Icons.lightbulb_outline,
              text: "Gợi ý cải thiện: ${writingDto.suggests}",
              context: context,
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
