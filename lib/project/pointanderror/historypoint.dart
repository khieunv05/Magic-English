import 'package:flutter/material.dart';
import 'package:magic_english_project/core/utils/toast_helper.dart';
import 'package:magic_english_project/project/dto/writingdto.dart';
import 'package:magic_english_project/project/pointanderror/errorandsuggest.dart';
import 'package:magic_english_project/project/pointanderror/writingparagraph.dart';
import 'package:magic_english_project/project/provider/paragraphprovider.dart';
import 'package:magic_english_project/project/theme/apptheme.dart';
import 'package:provider/provider.dart';
class HistoryPoint  extends StatefulWidget{
  const HistoryPoint({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HistoryPointState();
  }

}
class HistoryPointState extends State<HistoryPoint> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      final provider = context.read<ParagraphProvider>();
      if(provider.writingHistory == null && !provider.isLoading){
        try{provider.initData();
        }
        catch(err){
          showTopNotification(context, type: ToastType.error, title: 'Lỗi'
              , message: 'Lỗi lấy data');
        }
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    List<WritingDto>? paragraphs = context.watch<ParagraphProvider>().writingHistory;
    bool isLoading = context.watch<ParagraphProvider>().isLoading;
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
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
  Widget buildBody(List<WritingDto> data,BuildContext parentContext){
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: data.length,
            itemBuilder: (itemContext, index) {
              final item = data[index];
              return Card(
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  splashColor: Colors.black38.withAlpha(40),
                  onTap: () {
                    Navigator.push(parentContext, MaterialPageRoute(builder: (context) =>
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
                              style: Theme.of(parentContext).textTheme.bodyMedium,),
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
                                  style: Theme.of(parentContext).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text('Bấm vào để xem chi tiết',
                                style: Theme.of(parentContext).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w300,
                                  color: AppTheme.primaryColor
                                ),)
                              ],
                            ),
                          ),

                          IconButton(onPressed: (){
                            if(item.id == null){
                              showTopNotification(parentContext, type: ToastType.error
                                  , title: 'Lỗi', message: 'id của đoạn văn không tồn tại');
                              return;
                            }
                            deleteParagraphButton(parentContext,item.id!,index);
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
           Navigator.push(parentContext,MaterialPageRoute(builder: (context)=>  const WritingParagraph()));
          }, child: Text('Viết đoạn văn',style:
            Theme.of(parentContext).textTheme.labelLarge,)),
        ),
        const SizedBox(height: AppTheme.singleChildScrollViewHeight,)
      ],
    );
  }
  void deleteParagraphButton(BuildContext context,int? paragraphId,int index){
    showDialog(context: context, builder: (dialogContext){
      return AlertDialog(title: const Text('Bạn có muốn xóa không?'),
        titleTextStyle: Theme.of(dialogContext).textTheme.bodyMedium,
        actionsAlignment: MainAxisAlignment.spaceAround,
        actions: [
          IconButton(onPressed: ()async {
            String? message;
            try {
              Navigator.of(dialogContext).pop();
              await Future.delayed(const Duration(milliseconds: 200));
              if(!context.mounted){
                return;
              }
              message = await context.read<ParagraphProvider>()
                  .deleteData(paragraphId, index);
              if (!context.mounted) {
                return;
              }
              showTopNotification(context,
                  type: ToastType.success,
                  title: 'Chúc mừng',
                  message: message);
            }
            catch(err){
              if (!context.mounted) {
                return;
              }
              showTopNotification(context,
                  type: ToastType.error,
                  title: 'Lỗi',
                  message: err.toString().replaceAll('Exception:', ''));
              }
            }
          ,
              icon: const Icon(Icons.verified_user_outlined)),


          IconButton(onPressed: (){
            Navigator.pop(dialogContext);
          }, icon: const Icon(Icons.cancel))
        ],
      );
    });
  }
}
