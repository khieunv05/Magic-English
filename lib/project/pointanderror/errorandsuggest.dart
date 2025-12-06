import 'package:flutter/material.dart';
import 'package:test_project/project/base/basescreen.dart';
import 'package:test_project/project/dto/writingdto.dart';
import 'package:test_project/project/theme/apptheme.dart';
class ErrorAndSuggest extends StatelessWidget {
  final WritingDto writingDto;
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
  Widget myListCard(Color backgroundCircleAvatarColor,IconData icon,List<String> message,BuildContext context){
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
              (writingDto.errors == null || writingDto.errors.isEmpty) ?
                  Expanded(child: Text('Không có lỗi',style:
                    Theme.of(context).textTheme.bodyMedium,))
              :
              Expanded(
                child: Column(
                  children:
                    List.generate(message.length,(index){
                      return Padding(padding: const EdgeInsets.all(8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: backgroundCircleAvatarColor,
                            child: Icon(icon),
                          ),
                          const SizedBox(width: 8,),
                          Expanded(child: Text(message[index],style: Theme.of(context).textTheme.bodyMedium,))
                        ],
                      ),);

                    })
                  ,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


  const ErrorAndSuggest({super.key, required this.writingDto,});

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
            backgroundColor: getBackgroundColorFromPoint(writingDto.point),
            radius: 32,
            child: Text(writingDto.point.toString(),style: Theme.of(context).textTheme.titleLarge,),
          ),
          const SizedBox(height: 32,),
          myCard(Theme.of(context).primaryColor,Icons.book_outlined,writingDto.content, context),
          const SizedBox(height: 32,),
          myListCard(Colors.redAccent,Icons.close,writingDto.errors, context),
          const SizedBox(height: 32,),
          myCard(Colors.greenAccent,Icons.edit_outlined,'Gợi ý: ${writingDto.suggests}', context),

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
