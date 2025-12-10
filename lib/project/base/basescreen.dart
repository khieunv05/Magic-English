import 'package:flutter/material.dart';
import 'package:test_project/project/theme/apptheme.dart';

class BaseScreen extends StatelessWidget {
  final PreferredSizeWidget appBar;
  final Widget body;
  final bool needBottom;
  final List<VoidCallback>? bottomActions; // optional callbacks for bottom nav
  final int activeIndex; // index of active bottom nav (-1 = none)
  final Color activeColor;
  const BaseScreen({super.key, required this.appBar, required this.body, required this.needBottom, this.bottomActions, this.activeIndex = -1, Color? activeColor})
      : activeColor = activeColor ?? const Color(0xFF3A94E7);

  @override
  Widget build(BuildContext context) {
    final actions = bottomActions ?? List<VoidCallback>.filled(4, () {});
    return Scaffold(
      extendBody: true,
      appBar: appBar,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: body,
      ),
      bottomNavigationBar: (needBottom == false)?null: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(onPressed: actions[0], icon: Icon(Icons.home_outlined, color: (activeIndex==0)? activeColor : AppTheme.blackColor)),
              IconButton(onPressed: actions[1], icon: Icon(Icons.book_outlined, color: (activeIndex==1)? activeColor : AppTheme.blackColor)),
              IconButton(onPressed: actions[2], icon: Icon(Icons.edit_outlined, color: (activeIndex==2)? activeColor : AppTheme.blackColor)),
              IconButton(onPressed: actions[3], icon: Icon(Icons.person_2_outlined, color: (activeIndex==3)? activeColor : AppTheme.blackColor)),
            ],
          ),
        ),
      ),
    );
  }
}
