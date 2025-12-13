import 'package:flutter/material.dart';
import 'package:magic_english_project/project/login/signup.dart';

import '../theme/apptheme.dart';
class BaseLoginScreen extends StatelessWidget {
  final bool isLogin;
  final Widget bodyContent;


  const BaseLoginScreen({super.key, required this.bodyContent, required this.isLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppTheme.appTheme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height/4,
                width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircleAvatar(backgroundImage: AssetImage('assets/images/logo_login.png',
                      ),radius: AppTheme.avartarCircleRadiusLogin,
                      ),
                      const SizedBox(width: 16,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('MAGIC ENGLISH',style: Theme.of(context).textTheme.headlineLarge,),
                          Text('ALL IN ONE',style: Theme.of(context).textTheme.bodyMedium,)
                        ],
                      )
                    ],
                  ),
              ),
              bodyContent,
              const SizedBox(height: 16,),
              Text('Hoặc tiếp tục với',style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,),
              const SizedBox(height: 16,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar(backgroundColor: Colors.white,radius: 20,
                  child: Padding(padding: const EdgeInsets.all(8),
                  child: Image.asset('assets/images/google.png'),),),
                  CircleAvatar(backgroundColor: Colors.white,radius: 20,
                    child: Padding(padding: const EdgeInsets.all(8),
                      child: Image.asset('assets/images/iphone.png'),),),
                ],
              ),
              const SizedBox(height: 16,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text((isLogin == true) ? 'Bạn chưa có tài khoản?':
                    'Bạn dã có tài khoản?',style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,),
                  TextButton(onPressed: (){
                    (isLogin == true) ? Navigator.push(context, MaterialPageRoute(builder: (context){
                      return const SignUp();
                    })) : Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: AppTheme.primaryColor,
                    textStyle: const TextStyle(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                      fontSize: 20
                    )
                  ), child: Text((isLogin == true)? 'ĐĂNG KÍ' : 'ĐĂNG NHẬP'),)
                ],
              )

          
            ],
          ),
        ),
      ),
    );
  }
}
