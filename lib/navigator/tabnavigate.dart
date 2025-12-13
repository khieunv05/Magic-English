import 'package:flutter/material.dart';
class TabNavigate extends StatelessWidget {
  final Widget root;
  final GlobalKey<NavigatorState> navigatorKey;
  const TabNavigate({super.key, required this.root, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings){
        return MaterialPageRoute(builder: (context){
          return PrimaryScrollController.none(child: root);
        });
      },
    );
  }
}
