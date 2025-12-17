import 'package:flutter/material.dart';
import 'package:magic_english_project/core/utils/toast_helper.dart';
import 'package:magic_english_project/project/base/baseloginscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:magic_english_project/project/database/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:magic_english_project/project/home/home_page.dart';
import '../theme/apptheme.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  late String _username;
  late String _password;
  bool? checkBoxSaveAcoount = false;
  bool canViewPassword = false;
  String errorMessage = '';
  @override
  Widget build(BuildContext context) {
    return BaseLoginScreen(bodyContent:
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hãy đăng nhập nào ...!',style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8,),
          Text('Đăng nhập vào tài khoản của bạn để tiếp tục quá trình học tập',
          style: Theme.of(context).textTheme.bodyMedium,),
          const SizedBox(height: 16,),
          LoginForm(),
          const SizedBox(height: 16,),
          Row(
            children: [
              Checkbox(value: checkBoxSaveAcoount, onChanged: (newValue){
                setState(() {
                  checkBoxSaveAcoount = newValue;
                });
              }),
              Text('Lưu tài khoản',style: Theme.of(context).textTheme.bodyMedium,),
              const Spacer(),
              TextButton(onPressed: (){},
                style: TextButton.styleFrom(backgroundColor: Colors.transparent,
                ),
                child: const Text('Quên mật khẩu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.blackColor
              ),),),

            ],
          ),
          const SizedBox(height: 16,),
          SizedBox(
            height: 60,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned(left: 0,right: 0,top: 0,bottom: 0
                    ,child: ElevatedButton(onPressed: () {
                      signIn();
                    }, child: const Text(
                        'ĐĂNG NHẬP'))),
                const Positioned(right: 8,top: 0,bottom: 0,child: CircleAvatar(backgroundColor: Colors.white,
                  child: Icon(Icons.arrow_forward,size: 16,),))
              ],
            ),
          ),
        ],
      ),
      isLogin: true,
    );
  }
  Widget LoginForm(){
    return Form(key: _formKey,child:
    Column(children: [
      TextFormField(
        decoration: const InputDecoration(
            hintText: 'Tài khoản',
            prefixIcon: Icon(Icons.person_2_outlined,size: 16,)

        ),
        validator: (value){
          if(value == null || value.trim().isEmpty){
            return 'Vui lòng không bỏ trống';
          }
          else {
            return null;
          }
        },
        onSaved: (value){
          _username = value!;
        },
      ),
      const SizedBox(height: 12,),
      TextFormField(
        obscureText: (canViewPassword == true) ? false : true,
        decoration: InputDecoration(
            hintText: 'Mật khẩu',
            prefixIcon: const Icon(Icons.lock_outline,size: 16,),
            suffixIcon: IconButton(onPressed: (){
              setState(() {
                canViewPassword = !canViewPassword;
              });
            },icon: Icon((canViewPassword == true) ?
            Icons.visibility : Icons.visibility_off,size: 16,),)
        ),
        validator: (value){
          if(value == null || value.trim().isEmpty){
            return 'Vui lòng không bỏ trống';
          }
          else {
            return null;
          }
        },
        onSaved: (value){
          _password = value!;
        },
        
      ),
      Text(errorMessage,style: const TextStyle(
        color: Colors.red,fontSize: 16,fontWeight: FontWeight.w500
      ),)


    ],));
  }
  Future<void> signIn() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    try {
      Database db = Database();
      Map<String,String?> rs = await db.login(_username,_password);

      if (!mounted) return;
      if(rs['id'] == null){
        setState(() {
          errorMessage = rs['message']??"Đăng nhập thất bại";
        });
        return;
      }
      final sharedPre = await SharedPreferences.getInstance();
      sharedPre.setString('userId', rs['id']??"");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );

    }catch (e) {

      setState(() {
        errorMessage = 'Lỗi không xác định';
      });
    }
  }
}
