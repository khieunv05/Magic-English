import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:magic_english_project/core/utils/toast_helper.dart';
import 'package:magic_english_project/project/base/baseloginscreen.dart';
import 'package:magic_english_project/project/theme/apptheme.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool canViewPassword = false;
  bool canViewRewritePassword = false;
  bool isLoading = false;
  String textErrorMessage = '';
  late String _username;
  late String _password;
  late String _rewritePassword;
  @override
  Widget build(BuildContext context) {
    return BaseLoginScreen(bodyContent:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bắt đầu nào',style: TextStyle(
            fontSize: 20,fontWeight: FontWeight.bold,color: AppTheme.blackColor
          ),),
          const SizedBox(height: 8,),
          Text('Tạo một tài khoản để bắt đầu quá trình tự học của bạn',
          style: Theme.of(context).textTheme.bodyMedium,),
          const SizedBox(height: 20,),
          LoginForm(),
          const SizedBox(height: 16,),
          SizedBox(
            height: 60,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned(left: 0,right: 0,top: 0,bottom: 0
                    ,child: ElevatedButton(onPressed: (){
                      (isLoading == true)? null:
                      createNewAccount();
                    }, child: (isLoading == true) ? const CircularProgressIndicator(color: Colors.white,)
                        :const Text(
                       'ĐĂNG KÍ'))),
                const Positioned(right: 8,top: 0,bottom: 0,child: CircleAvatar(backgroundColor: Colors.white,
                  child: Icon(Icons.arrow_forward,size: 16,),))
              ],
            ),
          ),
        ],
      ),
      isLogin: false,
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
      const SizedBox(height: 12,),
      TextFormField(
        obscureText: (canViewRewritePassword == true)? false : true,
        decoration: InputDecoration(
            hintText: 'Nhập lại mật khẩu',
            prefixIcon: const Icon(Icons.lock_outline,size: 16,),
          suffixIcon: IconButton(onPressed: (){
            setState(() {
              canViewRewritePassword = !canViewRewritePassword;
            });
          },icon: Icon((canViewRewritePassword == true) ?
          Icons.visibility : Icons.visibility_off,size: 16,),),

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
          _rewritePassword = value!;
        },
      ),
      const SizedBox(height: 8,),
      Text(textErrorMessage,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 12,
        ),),


    ],));
  }
  Future<void> createNewAccount() async{
    if(_formKey.currentState!.validate()){
      try {
        _formKey.currentState!.save();
        if(_password != _rewritePassword){
          setState(() {
            textErrorMessage = 'Hai mật khẩu không trùng nhau';
          });
          return;
        }
        setState(() {
          isLoading = true;
          textErrorMessage = '';
        });
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _username,
            password: _password);
        String userId = userCredential.user!.uid;
        FirebaseFirestore.instance.collection('users').doc(userId).set({
          'email': _username,
          'created_at': FieldValue.serverTimestamp(),
        }
        );
        if(mounted){
          showTopNotification(context, type: ToastType.success, title:
              'Chúc mừng', message: 'Đăng ký thành công');
        }
      }

      on FirebaseAuthException catch(e){
        if(!mounted) return;
        setState(() {
          if(e.code == 'weak-password') {
            textErrorMessage = 'Mật khẩu yếu';
          }
          else if(e.code == 'email-already-in-use'){
            textErrorMessage = 'Email đã được sử dụng';
          }
          else if(e.code == 'invalid-email'){
            textErrorMessage = 'Không đúng định dạng gmail';
          }
        });

      }
      finally{
        setState(() {
          isLoading = false;
        });
      }
    }

  }
}
