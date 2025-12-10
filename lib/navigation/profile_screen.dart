import 'package:flutter/material.dart';
import 'package:test_project/project/base/basescreen.dart';
import 'package:test_project/project/home/home_page.dart';
import 'package:test_project/project/notebooks/notebooks_page.dart';
import 'package:test_project/project/pointanderror/historypoint.dart';
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
    return BaseScreen(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage())),
        ),
        title: const Text('Thông tin cá nhân'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      needBottom: true,
      activeIndex: 3,
      bottomActions: _getBottomActions(context),

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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        CircleAvatar(
                          radius: 35,
                          backgroundImage: const AssetImage(
                            'assets/images/logo_login.png',
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                        const SizedBox(width: 15),
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chức năng Thông tin cá nhân chưa được triển khai')),
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