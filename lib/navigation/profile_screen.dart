import 'package:flutter/material.dart';
import 'package:magic_english_project/navigation/profile_information.dart';
import 'package:magic_english_project/project/base/basescreen.dart';
import 'package:magic_english_project/project/home/home_page.dart';
import 'package:magic_english_project/project/notebooks/notebooks_page.dart';
import 'package:magic_english_project/project/pointanderror/historypoint.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  List<VoidCallback> _getBottomActions(BuildContext context) {
    return [
          () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage())),
          () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NotebooksPage())),
          () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HistoryPoint())),
          () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const Color magicEnglishPurple = Color(0xFF4A148C);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa cho các item
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 4,
                    width: double.infinity,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        CircleAvatar(
                          radius: 35,
                          backgroundImage: AssetImage(
                            'assets/images/logo_login.png',
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                        SizedBox(width: 15),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'MAGIC ENGLISH',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: magicEnglishPurple,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              'ALL IN ONE',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: magicEnglishPurple,
                                letterSpacing: 1.0,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Nút "Thông tin cá nhân" đã được sửa lỗi cú pháp và thêm điều hướng
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // *** HÀM ĐƯỢC GỌI để chuyển đến PersonalInfoScreen (ProfileInformation) ***
                    Navigator.push(
                      context,
                      // Sử dụng ProfileInformation (được import)
                      MaterialPageRoute(builder: (_) => const PersonalInfoScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: const BorderSide(color: Colors.grey, width: 2.5),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Thông tin cá nhân',
                    style: TextStyle(
                      color: Color(0xFF1E88E5),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Nút "Đăng xuất"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Xử lý Đăng xuất')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: const BorderSide(color: Colors.grey, width: 2.5),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Đăng xuất',
                    style: TextStyle(
                      color: Color(0xFFE53935),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}