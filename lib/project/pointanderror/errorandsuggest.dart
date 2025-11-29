import 'package:flutter/material.dart';
import 'package:test_project/project/base/basescreen.dart';
import 'package:test_project/project/theme/apptheme.dart';
void main(){
  runApp(MaterialApp(theme: AppTheme.appTheme
  ,home:const ErrorAndSuggest(paragraph: 'My name is Khieu,My name is Khieu,My name is Khieu,My name is Khieu,My name is Khieu,My name is Khieu,My name is Khieu',
        error: 'Test', suggest: 'Test',point: 3,),));
}
class ErrorAndSuggest extends StatelessWidget {
  final int point;
  final String paragraph;
  final String error;
  final String suggest;
  Widget myCard(Color backgroundCircleAvatarColor,IconData icon,String message,BuildContext context){
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: backgroundCircleAvatarColor,
                child: Icon(icon),
              ),
              const VerticalDivider(
                width: 28,
                thickness: 2,
                color: AppTheme.blackColor,
                indent: 4,
                endIndent: 4,
              ),
              Expanded(child: Text(message,style: Theme.of(context).textTheme.bodyMedium,),)
            ],
          ),
        ),
      ),
    );
}
  const ErrorAndSuggest({super.key,required this.point, required this.paragraph, required this.error, required this.suggest});


  @override
  Widget build(BuildContext context) {
    return BaseScreen(appBar: AppBar(
      leading: IconButton(onPressed: (){
        Navigator.of(context).pop();
      }, icon: const Icon(Icons.arrow_back),),
      title: const Text('Chấm điểm & sửa lỗi',),
      centerTitle: true,
    ), body: SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppTheme.singleChildScrollViewHeight),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: getBackgroundColorFromPoint(point),
            radius: 32,
            child: Text(point.toString(),style: Theme.of(context).textTheme.titleLarge,),
          ),
          const SizedBox(height: 32,),
          myCard(Theme.of(context).primaryColor,Icons.book_outlined,paragraph, context),
          const SizedBox(height: 32,),
          myCard(Colors.redAccent,Icons.close,'Lỗi: $error', context),
          const SizedBox(height: 32,),
          myCard(Colors.greenAccent,Icons.edit_outlined,'Gợi ý: $suggest', context),

        ],
      ),
    ), needBottom: true);
  }
  Color getBackgroundColorFromPoint(int point){
    if(point >=0 && point<5){
      return Colors.red;
    }
    else if(point >=5 && point <8) {
      return Colors.yellowAccent;
    }
    return Colors.green;
  }
}
