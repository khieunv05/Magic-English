import 'package:flutter/material.dart';
import 'package:magic_english_project/core/utils/toast_helper.dart';
import 'package:magic_english_project/project/dto/writingdto.dart';
import 'package:magic_english_project/project/pointanderror/errorandsuggest.dart';
import 'package:magic_english_project/project/provider/home_page_provider.dart';
import 'package:magic_english_project/project/provider/paragraphprovider.dart';
import 'package:magic_english_project/project/theme/apptheme.dart';
import 'package:provider/provider.dart';
class WritingParagraph extends StatefulWidget {
  const WritingParagraph({super.key});

  @override
  State<WritingParagraph> createState() => _WritingParagraphState();
}

class _WritingParagraphState extends State<WritingParagraph> {
  final TextEditingController _controller = TextEditingController();
  //bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
      leading: IconButton(onPressed: (){
        Navigator.of(context).pop();
      }, icon: const Icon(Icons.arrow_back),),
      title: const Text('Viết đoạn văn',),
      centerTitle: false,
    ), body: SingleChildScrollView(

      padding: const EdgeInsets.only(bottom: AppTheme.singleChildScrollViewHeight),

      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Viết đoạn văn bạn muốn chấm ở đây',
              suffixIcon: IconButton(onPressed: (){_controller.clear();}, icon:
              const Icon(Icons.delete,size: 28,))
            ),
            keyboardType: TextInputType.multiline,
            minLines: 15,
            maxLines: null,
          ),

          const SizedBox(height: 36,),

          SizedBox(
            width: double.infinity,
            child: TextButton(onPressed:() async {
              if(_controller.text.trim().isEmpty){
                showDialog(context: context, builder: (context){
                  return AlertDialog(
                    content: Text('Vui lòng không bỏ trống',
                    style: Theme.of(context).textTheme.titleLarge,),
                    actions: [
                      TextButton(onPressed: (){
                        Navigator.of(context).pop();
                      }, child: const Text('Đóng'))
                    ],
                  );
                });
              }


              else{
                  showLoading(context);

                  try {
                    WritingDto? writingDto = await context.read<
                        ParagraphProvider>().addData(_controller.text);

                    if(!context.mounted){
                      return;
                    }
                    await context.read<HomePageProvider>().reloadActivities();
                    if(!context.mounted){
                      return;
                    }
                    Navigator.of(context,rootNavigator: true).pop();
                    if (writingDto == null) {
                      showTopNotification(
                          context,
                          type: ToastType.error,
                          title: 'Lỗi',
                          message: 'Không nhận được dữ liệu phản hồi.'
                      );
                      return;
                    }

                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) =>
                        ErrorAndSuggest(
                            writingDto: writingDto),
                    ));
                  }
                  catch(err){
                    if (!context.mounted) return;

                    if(Navigator.of(context,rootNavigator: true).canPop()){
                      Navigator.of(context,rootNavigator: true).pop();
                    }

                    showTopNotification(context, type: ToastType.error, title: 'Lỗi'
                        , message: err.toString().replaceAll('Exception:', ''));
                  }
                }


            }, child:Text('Chấm điểm',
            style: Theme.of(context).textTheme.labelLarge,)),
          )
        ],
      ),
    ));
  }
  void showLoading(BuildContext context){
    showDialog(context: context,
        barrierDismissible: false
        , builder: (dialogContext){
      return const Center(
        child: CircularProgressIndicator(),
      );
    });
  }
}
