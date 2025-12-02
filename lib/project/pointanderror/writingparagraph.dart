import 'package:flutter/material.dart';
import 'package:test_project/project/AI/sendtoAI.dart';
import 'package:test_project/project/base/basescreen.dart';
import 'package:test_project/project/pointanderror/errorandsuggest.dart';
import 'package:test_project/project/theme/apptheme.dart';
void main(){
  runApp(MaterialApp(
  theme: AppTheme.appTheme
  ,home: const WritingParagraph()));
}
class WritingParagraph extends StatefulWidget {
  const WritingParagraph({super.key});

  @override
  State<WritingParagraph> createState() => _WritingParagraphState();
}

class _WritingParagraphState extends State<WritingParagraph> {
  final TextEditingController _controller = TextEditingController();
  final SendToAI _AI = SendToAI();
  @override
  Widget build(BuildContext context) {
    return BaseScreen(appBar: AppBar(
      leading: IconButton(onPressed: (){
        Navigator.of(context).pop();
      }, icon: const Icon(Icons.arrow_back),),
      title: const Text('Viết đoạn văn',),
      centerTitle: true,
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
            child: TextButton(onPressed: () async {
              if(_controller.text == null || _controller.text.trim().isEmpty){
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
                final result = await _AI.checkGrammar(_controller.text);
                if(!context.mounted) return;
                Navigator.push(context,MaterialPageRoute(builder: (context) => ErrorAndSuggest(
                point: result['point'],paragraph: _controller.text,
                    error: result['errors'] ?? [], suggest: result['suggests']??'Không có gợi ý')));
              }
            }, child: Text('Chấm điểm',
            style: Theme.of(context).textTheme.labelLarge,)),
          )
        ],
      ),
    ), needBottom: true);
  }
}
