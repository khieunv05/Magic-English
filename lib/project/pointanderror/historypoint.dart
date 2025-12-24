import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:magic_english_project/app/app.dart';
import 'package:magic_english_project/core/utils/toast_helper.dart';
import 'package:magic_english_project/project/base/basescreen.dart';
import 'package:magic_english_project/project/database/database.dart';
import 'package:magic_english_project/project/dto/writingdto.dart';
import 'package:magic_english_project/project/pointanderror/errorandsuggest.dart';
import 'package:magic_english_project/project/pointanderror/writingparagraph.dart';
import 'package:magic_english_project/project/provider/paragraphprovider.dart';
import 'package:magic_english_project/project/provider/userprovider.dart';
import 'package:magic_english_project/project/theme/apptheme.dart';
import 'package:magic_english_project/project/home/home_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/firebase_service.dart';
class HistoryPoint extends StatelessWidget {
  const HistoryPoint({super.key});


  @override
  Widget build(BuildContext context) {
    List<WritingDto>? paragraphs = context.watch<ParagraphProvider>().writingHistory;
    bool isLoading = context.watch<ParagraphProvider>().isLoading;
    int? userId = context.watch<UserProvider>().user?.id;
    if(paragraphs == null && !isLoading){
      context.read<ParagraphProvider>().initData();
      return const Center(child: CircularProgressIndicator(),);
    }
    if(isLoading) {
        return const Center(child: CircularProgressIndicator());
    }
    if (paragraphs == null) {
      return const Center(child: Text("Không có dữ liệu hoặc lỗi tải trang"));
    }
    if(paragraphs.isEmpty){
      return Scaffold(
        appBar: AppBar(
          title: const Text('Lịch sử chấm điểm & sửa lỗi'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const Text('Bạn chưa có đoạn văn nào'),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(onPressed: () async{
                    Navigator.push(context,MaterialPageRoute(builder: (context)=>  const WritingParagraph()));
                  }, child: Text('Viết đoạn văn',style:
                  Theme.of(context).textTheme.labelLarge,)),
                ),
              ],
            ),
          ),
        ),
      );
    }


    return Scaffold(appBar: AppBar(
      title: const Text('Lịch sử chấm điểm & sửa lỗi',),
      centerTitle: false,
    ), body:  buildBody(paragraphs, context)
    );
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
  Widget buildBody(List<WritingDto> data,BuildContext context){
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Card(
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  splashColor: Colors.black38.withAlpha(40),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      ErrorAndSuggest(
                        writingDto: item,
                      ),
                    ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: getCardBackgroundColor(item.score),
                            radius: 20,
                            child: Text(item.score.toString(),
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
                              children: [
                                Text(item.originalText,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text('Bấm vào để xem chi tiết',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w300,
                                  color: AppTheme.primaryColor
                                ),)
                              ],
                            ),
                          ),

                          IconButton(onPressed: (){
                           // (item.id == null) ? print('Lỗi') : deleteParagraphButton(context,item.id!);
                          }, icon: const Icon(Icons.remove_circle_outline,color: Colors.red,))
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: 20,);
            },
          ),
        ),
        const SizedBox(height: 32,),
        SizedBox(
          width: double.infinity,
          child: TextButton(onPressed: () async{
           Navigator.push(context,MaterialPageRoute(builder: (context)=>  const WritingParagraph()));
          }, child: Text('Viết đoạn văn',style:
            Theme.of(context).textTheme.labelLarge,)),
        ),
        const SizedBox(height: AppTheme.singleChildScrollViewHeight,)
      ],
    );
  }
  void deleteParagraphButton(BuildContext context,String paragraphId){
    showDialog(context: context, builder: (context){
      return AlertDialog(title: const Text('Bạn có muốn xóa không?'),
        titleTextStyle: Theme.of(context).textTheme.bodyMedium,
        actionsAlignment: MainAxisAlignment.spaceAround,
        actions: [
          IconButton(onPressed: ()async{
            Database db = Database();
            String? message = await db.deleteParagraph(paragraphId);
            if(!context.mounted) {
              return;
            }
            bool isSuccess = message == null;
            Navigator.of(context).pop();
             showTopNotification(context,
                 type: (isSuccess)? ToastType.success: ToastType.error,
                 title: (isSuccess)?'Chúc mừng':'Lỗi',
                 message: (isSuccess)?'Xóa thành công':message);
          }, icon: const Icon(Icons.verified_user_outlined)),
          IconButton(onPressed: (){
            Navigator.pop(context);
          }, icon: const Icon(Icons.cancel))
        ],
      );
    });
  }
}
