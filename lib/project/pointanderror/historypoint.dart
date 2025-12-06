import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:test_project/project/base/basescreen.dart';
import 'package:test_project/project/dto/writingdto.dart';
import 'package:test_project/project/pointanderror/errorandsuggest.dart';
import 'package:test_project/project/pointanderror/writingparagraph.dart';
import 'package:test_project/project/theme/apptheme.dart';
void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    theme: AppTheme.appTheme,
    home:  const HistoryPoint(),
  ));
}

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


    return BaseScreen(appBar: AppBar(
      leading: IconButton(onPressed: (){}, icon: const Icon(Icons.arrow_back),),
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
        if(snapshot.data!.docs.isEmpty){
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
          return WritingDto.fromMap(item.data() as Map<String,dynamic>);
        }).toList();
        return buildBody(data,context);
      },

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
  Widget buildBody(List<WritingDto> _data,BuildContext context){
    return Column(
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
                      ErrorAndSuggest(writingDto: WritingDto(item.point,item.content,
                          List<String>.from(item.errors),item.suggests))));
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
                            spacing: 8,
                            children: [
                              Text(item.content,style: Theme.of(context).textTheme.bodyLarge,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,),
                              Text('Lỗi: ',style: Theme.of(context).textTheme.bodyLarge),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: List.generate(item.errors.length>=2 ? 2: item.errors.length, (index){
                                    return Row(
                                      children: [
                                        const CircleAvatar(backgroundColor: Colors.red,
                                        child: Icon(Icons.close),),
                                        const SizedBox(width: 8,),
                                        Expanded(child: Text(item.errors[index],
                                            style: Theme.of(context).textTheme.bodyMedium))
                                      ],
                                    );
                                  })
                                ),
                              ),
                              Text.rich(TextSpan(
                                  children: [
                                    TextSpan(text: 'Gợi ý: ',style: Theme.of(context).textTheme.bodyMedium),
                                    TextSpan(text: item.suggests,style: Theme.of(context).textTheme.bodySmall)
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
    );
  }
}
