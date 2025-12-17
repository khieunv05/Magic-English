import 'package:flutter/material.dart';
import 'package:magic_english_project/project/AI/sendtoAI.dart';
import 'package:magic_english_project/project/base/basescreen.dart';
import 'package:magic_english_project/project/database/database.dart';
import 'package:magic_english_project/project/dto/writingdto.dart';
import 'package:magic_english_project/project/pointanderror/errorandsuggest.dart';
import 'package:magic_english_project/project/theme/apptheme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WritingParagraph extends StatefulWidget {
  String? userId;
  WritingParagraph({super.key,this.userId});

  @override
  State<WritingParagraph> createState() => _WritingParagraphState();
}

class _WritingParagraphState extends State<WritingParagraph> {
  final TextEditingController _controller = TextEditingController();
  final SendToAI _AI = SendToAI();
  bool didChange = false;
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
      leading: IconButton(onPressed: (){
        Navigator.of(context).pop(didChange);
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
            child: TextButton(onPressed:(isLoading == true)? null:  () async {
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
                setState(() {
                  isLoading = true;
                });
                final result = await _AI.checkGrammar(_controller.text);
                if(!context.mounted) return;
                WritingDto writingDto = WritingDto(result['point'], _controller.text,
                    List<String>.from(result['mistakes' ] ?? []), result['suggests'] ?? '');
                Database db = Database();
                await db.addParagraph(widget.userId!, writingDto);
                setState(() {
                  isLoading = false;
                });
                didChange = true;
                 Navigator.push(context,MaterialPageRoute(builder: (context) => ErrorAndSuggest(
                  writingDto: WritingDto(result['point'], _controller.text,
                      List<String>.from(result['mistakes'] ?? []), result['suggests'] ?? ''),
                )));
              }
            }, child:(isLoading == true)?const CircularProgressIndicator() :Text('Chấm điểm',
            style: Theme.of(context).textTheme.labelLarge,)),
          )
        ],
      ),
    ));
  }

}
