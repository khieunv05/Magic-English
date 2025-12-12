import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:magic_english_project/core/utils/toast_helper.dart';
import 'package:magic_english_project/project/base/basescreen.dart';
import 'package:magic_english_project/project/database/database.dart';
import 'package:magic_english_project/project/dto/writingdto.dart';
import 'package:magic_english_project/project/pointanderror/errorandsuggest.dart';
import 'package:magic_english_project/project/pointanderror/writingparagraph.dart';
import 'package:magic_english_project/project/theme/apptheme.dart';
import 'package:magic_english_project/project/home/home_page.dart';

class HistoryPoint extends StatefulWidget{
  const HistoryPoint({super.key});

  @override
  State<HistoryPoint> createState() {
    return HistoryPointState();
  }

}
class HistoryPointState extends State<HistoryPoint> {
  late final Stream<QuerySnapshot> _paragraphStream;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if(user == null){
      _paragraphStream = const Stream.empty();
    }
    else{
      _paragraphStream = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('writing_history')
          .snapshots();

    }
  }
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if(user == null) {
      return const Center(child: Text('Vui lòng đăng nhập để xem lịch sử'),);
    }


    return Scaffold(appBar: AppBar(
      title: const Text('Lịch sử chấm điểm & sửa lỗi',),
      centerTitle: true,
    ), body: StreamBuilder<QuerySnapshot>(stream: _paragraphStream
      , builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
        if(snapshot.hasError){
          return Center(child: Text('Lỗi: ${snapshot.error}'),);
        }
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator(),);
        }
        if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
            return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Chưa có đoạn văn nào',style: Theme.of(context).textTheme.bodyMedium,),
              const SizedBox(height: 32,),
              SizedBox(
                width: double.infinity,
                child: TextButton(onPressed: (){
                  Navigator.push(context,MaterialPageRoute(builder: (context)=> const WritingParagraph()));
                }, child: Text('Viết đoạn văn',style:
                Theme.of(context).textTheme.labelLarge,)),
              ),
            ],
          );

        }
        List<WritingDto> data = snapshot.data!.docs.map((item){
          return WritingDto.fromMap(item.id,item.data() as Map<String,dynamic>);
        }).toList();
        return buildBody(data,context);
      },

    ),
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
  Widget buildBody(List<WritingDto> _data,BuildContext context){
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: _data.length,
            itemBuilder: (context, index) {
              final item = _data[index];
              return Card(
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  splashColor: Colors.black38.withAlpha(40),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      ErrorAndSuggest(
                        writingDto: WritingDto(
                          item.point,
                          item.content,
                          List<String>.from(item.errors),
                          item.suggests,
                        ),
                      ),
                    ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: getCardBackgroundColor(item.point),
                            radius: 24,
                            child: Text(item.point.toString(),
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
                                Text(item.content,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),

                              ],
                            ),
                          ),

                          IconButton(onPressed: (){
                            (item.id == null) ? print('Lỗi') : deleteParagraphButton(item.id!);
                          }, icon: const Icon(Icons.remove_circle_outline))
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
          child: TextButton(onPressed: (){
            Navigator.push(context,MaterialPageRoute(builder: (context)=> const WritingParagraph()));
          }, child: Text('Viết đoạn văn',style:
            Theme.of(context).textTheme.labelLarge,)),
        ),
        const SizedBox(height: AppTheme.singleChildScrollViewHeight,)
      ],
    );
  }
  void deleteParagraphButton(String paragraphId){
    showDialog(context: context, builder: (context){
      return AlertDialog(title: const Text('Bạn có muốn xóa không?'),
        titleTextStyle: Theme.of(context).textTheme.bodyMedium,
        actionsAlignment: MainAxisAlignment.spaceAround,
        actions: [
          IconButton(onPressed: (){
            Database.deleteParagraph(paragraphId);
            Navigator.pop(context);
            showTopNotification(context, type: ToastType.success, title:
                'Xóa thành công', message: '');
          }, icon: const Icon(Icons.verified_user_outlined)),
          IconButton(onPressed: (){
            Navigator.pop(context);
          }, icon: const Icon(Icons.cancel))
        ],
      );
    });
  }
}
