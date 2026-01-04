import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic_english_project/core/utils/toast_helper.dart';
import 'package:magic_english_project/navigator/tabnavigate.dart';
import 'package:magic_english_project/project/dto/category_english.dart';
import 'package:magic_english_project/project/pointanderror/historypoint.dart';
import 'package:magic_english_project/project/notebooks/notebooks_page.dart';
import 'package:magic_english_project/navigation/instruction_modal.dart';
import 'package:magic_english_project/navigation/profile_screen.dart';
import 'package:magic_english_project/project/provider/home_page_provider.dart';
import 'package:magic_english_project/project/provider/paragraphprovider.dart';
import 'dart:math';

import 'package:magic_english_project/project/theme/apptheme.dart';
import 'package:provider/provider.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MainAppWrapper(selectedIndex: 0),
    );
  }
}
class MainAppWrapper extends StatefulWidget {
  final int selectedIndex;

  const MainAppWrapper({super.key, required this.selectedIndex});

  @override
  State<MainAppWrapper> createState() => _MainAppWrapperState();
}
class _MainAppWrapperState extends State<MainAppWrapper> {
   int selectedIndex = 0;
  final navigatorStates = [
    GlobalKey<NavigatorState>(debugLabel: 'tabNavigator_0'),
    GlobalKey<NavigatorState>(debugLabel: 'tabNavigator_1'),
    GlobalKey<NavigatorState>(debugLabel: 'tabNavigator_2'),
    GlobalKey<NavigatorState>(debugLabel: 'tabNavigator_3')
  ];
  final tabList =  [
    const HomeScreenContent(),
    const NotebooksPage(),
    const HistoryPoint(),
    const ProfileScreen()
  ];
  Set<int> tabSelected = {0};

  @override
  Widget build(BuildContext context) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: null,
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: PopScope(
              canPop: false,
              onPopInvoked: (didPop) async{
                if(didPop) return;
                final currentNavigator = navigatorStates[selectedIndex].currentState;
                if(currentNavigator != null && currentNavigator.canPop()){
                  currentNavigator.pop();
                }
                else{
                  if(selectedIndex != 0){
                    setState(() {
                      selectedIndex = 0;
                    });
                  }
                  else {
                    await SystemNavigator.pop();
                  }
                }
              },

              child: IndexedStack(
                  index: selectedIndex,

                  children: List.generate(tabList.length, (index){
                    if(tabSelected.contains(index)){
                      return TabNavigate(root: tabList[index], navigatorKey: navigatorStates[index]);
                    }
                    else{
                      return const SizedBox();
                    }
                  }),
                  ),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: selectedIndex,
            selectedItemColor: AppTheme.appTheme.primaryColor,
              unselectedItemColor: AppTheme.blackColor,
              unselectedLabelStyle: const TextStyle(
                color: AppTheme.blackColor
              ),
              onTap: (index){
                setState(() {
                  selectedIndex = index;
                  tabSelected.add(index);
                });
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined),label: 'Trang chủ'),
                BottomNavigationBarItem(icon: Icon(Icons.book_outlined),label: 'Thêm từ'),
                BottomNavigationBarItem(icon: Icon(Icons.edit_outlined),label: 'Viết văn'),
                BottomNavigationBarItem(icon: Icon(Icons.person_2_outlined),label: 'Cá nhân'),
              ]),
          );
    }
  }
class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
   Map<String, double>? categoryData;
   CategoryEnglish? categoryEnglish;
   Map<String, int>? cefrData;
  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_){
      try {
        context.read<HomePageProvider>().initData();
      }
      catch(err){
        showTopNotification(context, type: ToastType.error, title: 'Lỗi',
            message: 'Lỗi khi lấy dữ liệu');
      }
    });
  }
  String _selectedBarLabel = '';
  int _selectedBarValue = 0;
  final int totalStudyDays = 200;
  // final int currentFireStreak = 12;


  String _getLevelDescription(int days) {
    if (days >= 1000) return 'Cấp độ: Huyền thoại ';
    if (days >= 500) return 'Cấp độ: Siêu bền vững';
    if (days >= 200) return 'Cấp độ: Bền bỉ';
    if (days >= 100) return 'Cấp độ: Bứt phá';
    if (days >= 30) return 'Cấp độ: Kiên trì';
    if (days >= 10) return 'Cấp độ: Khởi động';
    return 'Chưa đạt cấp độ (Đã đạt ${days} ngày)';
  }

  IconData _getLevelIcon(int days) {
    if (days >= 1000) return Icons.military_tech;
    if (days >= 500) return Icons.diamond;
    if (days >= 200) return Icons.emoji_events;
    if (days >= 100) return Icons.star;
    if (days >= 30) return Icons.auto_stories;
    if (days >= 10) return Icons.rocket_launch;
    return Icons.calendar_today;
  }

  Widget _buildAvatarItem() {
    return const Padding(
      padding: EdgeInsets.only(right: 8.0),
      child: CircleAvatar(
        radius: 12,
        backgroundColor: Color(0xFFFDD835),
        child: Icon(
          Icons.sentiment_satisfied_alt,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {required IconData currentIcon, required String label, bool isCalendar = false, bool isFire = false, String? tooltipText}) {
    Color iconColor = isFire ? Colors.red : (isCalendar ? Theme.of(context).primaryColor : Colors.grey);
    Color textColor = isFire ? Colors.red : Colors.black;

    if (isCalendar) {
      iconColor = Theme.of(context).primaryColor;
      textColor = Colors.black;
    }

    Widget statContent = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(currentIcon, color: iconColor, size: 20),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    if (tooltipText != null) {
      return Tooltip(
        message: tooltipText,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: const TextStyle(color: Colors.white),
        child: statContent,
      );
    }
    return statContent;
  }
  final List<Color> pieColors = const [
    Color(0xFF66BB6A),
    Color(0xFFFFEB3B),
    Color(0xFFE53935),
    Color(0xFF9FA8DA),
  ];

  void _showInstructionModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const InstructionModal();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomePageProvider>();
    final overview = provider.overviewData;
    int vocabFromApi = overview?.result?.totalVocabularyLearned ?? 0;
    int streakFromApi = overview?.result?.streak.streak ?? 0;
    categoryEnglish = context.watch<HomePageProvider>().categoryEnglish;
    categoryData = {
      'Danh từ': (categoryEnglish?.noun ?? 1)/(categoryEnglish?.totalVocab ?? 1) ,
      'Tính từ': (categoryEnglish?.adj ?? 1)/(categoryEnglish?.totalVocab ?? 1)  ,
      'Động từ':(categoryEnglish?.verb ?? 1)/(categoryEnglish?.totalVocab ?? 1)  ,
      'Còn lại':(categoryEnglish?.adv ?? 1)/(categoryEnglish?.totalVocab ?? 1)  ,
    };
   cefrData = {
     'A1':(categoryEnglish?.A1 ?? 1),
   'A2':(categoryEnglish?.A2 ?? 1),
   'B1':(categoryEnglish?.B1 ?? 1),
   'B2':(categoryEnglish?.B2 ?? 1),
   'C1':(categoryEnglish?.C1 ?? 1),
   'C2':(categoryEnglish?.C2 ?? 1),
   };
    return _buildBody(context, vocabFromApi, streakFromApi);
  }


   PreferredSizeWidget buildCustomAppBar(BuildContext context, {required int streak, required int totalStudyDays}){
     final String calendarTooltip = "Tổng số ngày học của bạn.  ${_getLevelDescription(totalStudyDays)}";
     final IconData calendarIcon = _getLevelIcon(totalStudyDays);
     const String fireTooltip = "Chuỗi học liên tục của bạn. ";
     const IconData fireIcon = Icons.local_fire_department;


     return PreferredSize(
       preferredSize: const Size.fromHeight(80.0),
       child: Container(
         padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 8),
         color: Colors.white,
         child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           crossAxisAlignment: CrossAxisAlignment.center,
           children: [
             _buildAvatarItem(),
             const SizedBox(width: 10),
             _buildStatItem(
               context,
               currentIcon: calendarIcon,
               label: totalStudyDays.toString(),
               isCalendar: true,
               tooltipText: calendarTooltip,
             ),
             const SizedBox(width: 10),
             _buildStatItem(
                 context,
                 currentIcon: fireIcon,
                 label: streak.toString(),
                 isFire: true,
                 tooltipText: fireTooltip
             ),
             const Icon(Icons.notifications_none, color: Colors.black, size: 28),
           ],
         ),
       ),
     );
   }
   Widget _buildBody(BuildContext context, int totalVocab, int streakCount){
    const Color infoIconColor = Color(0xFF1E88E5);
    const Color amberColor = Color(0xFFFFC107);
    const int defaultStudyDays = 200;
    categoryData ??= {
        'Danh từ': 0.25,
        'Tính từ': 0.25,
        'Động từ': 0.25,
        'Còn lại': 0.25,
      };
    cefrData ??=  {
      'A1': 30,
      'A2': 18,
      'B1': 27,
      'B2': 60,
      'C1': 42,
      'C2': 23,
    };
    return Scaffold(
      appBar: buildCustomAppBar(
        context,
        streak: streakCount,
        totalStudyDays: defaultStudyDays,
      ),
        body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bảng điều khiển tiến độ',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () => _showInstructionModal(context),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: infoIconColor, width: 1.5),
                        ),
                        child: const Icon(Icons.info_outline, size: 20, color: infoIconColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSubHeaderItem(
                                icon: Icons.folder_open,
                                text: 'Số từ vựng đã học',
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: 70,
                                height: 70,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: amberColor, width: 3),
                                  color: Colors.white,
                                ),
                                child: Text(
                                  '$totalVocab',
                                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: amberColor),
                                ),
                              ),
                            ],
                          ),


                          const SizedBox(height: 12),
                          _buildSubHeaderItem(
                            icon: Icons.dashboard_customize,
                            text: 'Phân loại từ vựng',
                          ),
                          const SizedBox(height: 20),
                          _buildSortOptionWithRefresh(
                            leadingIcon: Icons.pie_chart,
                            text: 'Phân loại theo từ loại',
                          ),
                          const SizedBox(height: 12),
                          _buildPieChartSection(context, categoryData!, pieColors),
                          const SizedBox(height: 20),
                          _buildSortOptionWithRefresh(
                            leadingIcon: Icons.bar_chart,
                            text: 'Phân loại theo cấp độ CEFR',
                          ),
                          const SizedBox(height: 12),
                          _buildBarChart(context, cefrData!),
                        ],
                      ),
                    ),

                  ],
                ),
              ],
            ),
        ),
      );
  }

  Widget _buildSubHeaderItem({required IconData icon, required String text, bool isHighlighted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartSection(BuildContext context, Map<String, double> data, List<Color> colors) {
    final List<String> legendLabels = ['Danh từ', 'Tính từ', 'Động từ', 'Còn lại'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.45,
            height: 160,
            child: CustomPaint(
              painter: PieChartPainter(data, colors, ringThickness: 30.0),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: legendLabels.asMap().entries.map((entry) {
                int index = entry.key;
                String label = entry.value;
                Color legendColor = colors[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 20,
                        decoration: BoxDecoration(
                          color: legendColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, Map<String, int> data) {
    double maxValue = 60;
    const Color defaultColor = Color(0xFFE0E0E0);
    final Color highlightColor = Theme.of(context).primaryColor;
    const double maxBarPixelHeight = 110;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.entries.map((entry) {
          String label = entry.key;
          int value = entry.value;

          double normalizedHeight = (value / maxValue) * maxBarPixelHeight;

          bool isSelected = _selectedBarLabel == label;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedBarLabel = label;
                _selectedBarValue = value;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: highlightColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                Container(
                  width: 18,
                  height: normalizedHeight > 0 ? normalizedHeight : 0,
                  decoration: BoxDecoration(
                    color: (label == 'B2' || isSelected) ? highlightColor : defaultColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(3),
                      topRight: Radius.circular(3),
                    ),
                    border: isSelected ? Border.all(color: highlightColor, width: 2) : null,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: (label == 'B2' || isSelected) ? highlightColor : Colors.black,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSortOptionWithRefresh({
    required String text,
    IconData? leadingIcon,
  }) {
    return Row(
      children: [
        if (leadingIcon != null)
          Icon(leadingIcon, color: Colors.black, size: 20),
        if (leadingIcon != null)
          const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black
            ),
          ),
        ),
      ],
    );
    }
  }
class PieChartPainter extends CustomPainter {
  final Map<String, double> data;
  final List<Color> colors;
  final double ringThickness;
  PieChartPainter(this.data, this.colors, {this.ringThickness = 30.0});
  @override
  void paint(Canvas canvas, Size size) {
    double total = data.values.fold(0, (sum, value) => sum + value);
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.shortestSide / 2;
    double innerRadius = radius - ringThickness;

    double startAngle = -pi / 2;

    data.values.toList().asMap().entries.forEach((entry) {
      int index = entry.key;
      double value = entry.value;

      final paint = Paint()
        ..color = colors[index % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringThickness
        ..strokeCap = StrokeCap.butt;

      double sweepAngle = (value / total) * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - ringThickness / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      double midAngle = startAngle + sweepAngle / 2;
      double textRadius = (innerRadius + radius) / 2;
      double x = center.dx + textRadius * cos(midAngle);
      double y = center.dy + textRadius * sin(midAngle);
      TextSpan span = TextSpan(
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        text: '${(value * 100).toInt()}%',
      );
      TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr);
      tp.layout();

      if (value / total > 0.05) {
        tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
      }

      startAngle += sweepAngle;
    });
    Paint innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, innerPaint);
  }

  @override
  bool shouldRepaint(covariant PieChartPainter oldDelegate) {
    return true;
  }
}