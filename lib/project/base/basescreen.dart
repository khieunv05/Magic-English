import 'package:flutter/material.dart';
import 'package:magic_english_project/project/theme/apptheme.dart';

class BaseScreen extends StatelessWidget {
  final PreferredSizeWidget appBar;
  final Widget body;
  final bool needBottom;
  final List<VoidCallback>? bottomActions;
  final int activeIndex;
  final Color activeColor;
  const BaseScreen({
    super.key,
    required this.appBar,
    required this.body,
    required this.needBottom,
    this.bottomActions,
    this.activeIndex = -1,
    Color? activeColor,
  }) : activeColor = activeColor ?? const Color(0xFF3A94E7);

  @override
  Widget build(BuildContext context) {
    final actions = bottomActions ?? List<VoidCallback>.filled(4, () {});

    Widget _buildNavItem(IconData icon, int index) {
      final bool isActive = index == activeIndex;
      return Expanded(
        child: InkWell(
          onTap: actions.length > index ? actions[index] : () {},
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 26, color: isActive ? activeColor : AppTheme.blackColor),
                const SizedBox(height: 6),
                // dot indicator
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? activeColor : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      appBar: appBar,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: body,
      ),
      bottomNavigationBar: (needBottom == false)
          ? null
          : Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: activeColor.withOpacity(0.12), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildNavItem(Icons.home_outlined, 0),
              _buildNavItem(Icons.book_outlined, 1),
              _buildNavItem(Icons.edit_outlined, 2),
              _buildNavItem(Icons.person_2_outlined, 3),
            ],
          ),
        ),
      ),
    );
  }
}
