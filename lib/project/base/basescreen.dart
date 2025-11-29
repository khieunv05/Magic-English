import 'package:flutter/material.dart';
import 'package:test_project/project/theme/apptheme.dart';
void main(){
  runApp(MaterialApp(
    theme: AppTheme.appTheme,
    home: BaseScreen(appBar: AppBar(
      leading: IconButton(onPressed: (){}, icon: Icon(Icons.arrow_back)),
      title: const Text('Lịch sử chấm điểm & sửa lỗi'),
    ), body: const Text('Test'),
    needBottom: true,),
    debugShowCheckedModeBanner: false,
  ));
}
class BaseScreen extends StatelessWidget {
  final AppBar appBar;
  final Widget body;
  final bool needBottom;
  const BaseScreen({super.key, required this.appBar, required this.body, required this.needBottom});

  @override
  Widget build(BuildContext context) {
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
              IconButton(onPressed: (){}, icon: const Icon(Icons.home_outlined)),
              IconButton(onPressed: (){}, icon: const Icon(Icons.book_outlined),),
              IconButton(onPressed: (){}, icon: const Icon(Icons.edit_outlined),),
              IconButton(onPressed: (){}, icon: const Icon(Icons.person_2_outlined),)
            ],
          ),
        ),
      ),
    );
  }
}
