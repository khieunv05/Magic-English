import 'package:flutter/material.dart';
import 'package:test_project/project/base/basescreen.dart';
import 'package:test_project/project/pointanderror/errorandsuggest.dart';
import 'package:test_project/project/pointanderror/writingparagraph.dart';
import 'package:test_project/project/theme/apptheme.dart';
void main(){
  runApp(MaterialApp(
    theme: AppTheme.appTheme,
    home: const HistoryPoint(),
  ));
}
class HistoryPoint extends StatelessWidget {
  const HistoryPoint({super.key});
  static const List<Map<String,dynamic>> _data = [
    {'point':5,'title':'Hello,Me name is Khieu ','error':'Me ','suggest':'Me => My'},
    {'point':3,'title':'Hello,Me name is Khieu','error':'Me','suggest':'Me => My'},
    {'point':8,'title':'Hello,Me name is Khieu','error':'Me','suggest':'Me => My'},
    {'point':9,'title':'Hello,Me name is Khieu','error':'Me','suggest':'Me => My'},
  ];
  @override
  Widget build(BuildContext context) {
    return BaseScreen(appBar: AppBar(
      leading: IconButton(onPressed: (){}, icon: const Icon(Icons.arrow_back),),
      title: const Text('Lịch sử chấm điểm & sửa lỗi',),
      centerTitle: true,
    ), body: Column(
        children: [
          Expanded(child: ListView.separated(itemCount: _data.length,
            itemBuilder: (context,index){
            var item = _data[index];
            return Card(
              clipBehavior: Clip.hardEdge,

              child: InkWell(
                splashColor: Colors.black38.withAlpha(40),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>
                  ErrorAndSuggest(point: item['point'], paragraph: item['title'],
                      error: item['error'], suggest: item['suggest'])));
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: getCardBackgroundColor(item['point']),
                          radius: 24,
                          child: Text(item['point'].toString(),
                          style: Theme.of(context).textTheme.bodyMedium,),
                        ),
                        const VerticalDivider(
                          color: AppTheme.blackColor,
                          width: 20,
                          thickness: 1,
                          indent: 4,
                          endIndent: 4,

                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: 8,
                            children: [
                              Text(item['title'],style: Theme.of(context).textTheme.bodyLarge,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,),
                              Text.rich(TextSpan(
                                children:[
                                  TextSpan(text: 'Lỗi: ',style: Theme.of(context).textTheme.bodyMedium,),
                                  TextSpan(text: item['error'],style: Theme.of(context).textTheme.bodySmall ),
                                ]
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,),
                              Text.rich(TextSpan(
                                children: [
                                  TextSpan(text: 'Gợi ý: ',style: Theme.of(context).textTheme.bodyMedium),
                                  TextSpan(text: item['suggest'],style: Theme.of(context).textTheme.bodySmall)
                                ]
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,)
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }, separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(height: 20,);
          },)),
          const SizedBox(height: 32,),
          SizedBox(
            width: double.infinity,
            child: TextButton(onPressed: (){
              Navigator.push(context,MaterialPageRoute(builder: (context)=> const WritingParagraph()));
            }, child: Text('Viết đoạn văn',style:
              Theme.of(context).textTheme.labelLarge,)),
          ),
          const SizedBox(height: AppTheme.singleChildScrollViewHeight,)
        ],
      ),
    needBottom: true,);
  }
  Color getCardBackgroundColor(int point){
    if(point >=0 && point<5){
      return Colors.red;
    }
    else if(point >=5 && point <8) {
      return Colors.yellowAccent;
    }
    return Colors.green;
  }
}
