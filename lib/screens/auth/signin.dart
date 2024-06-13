
import 'package:flutter/material.dart';
import 'package:tfnd_app/Controllors/login_controllor.dart';
import 'package:tfnd_app/screens/auth/forgotpassword.dart';
import 'package:tfnd_app/screens/auth/signup.dart';
import 'package:tfnd_app/themes/color.dart';
import 'package:tfnd_app/widgets/reusable_button.dart';
import 'package:tfnd_app/widgets/reusable_text.dart';
import 'package:tfnd_app/widgets/reusable_textformfield.dart';

class signin extends StatefulWidget {
    String email2;
   signin({super.key, required this.email2});


  @override
  State<signin> createState() => _signinState();
}

class _signinState extends State<signin> {
     SignInController? _controller ;

       void initState() {
    super.initState();
    _controller = SignInController(context);
  }

  bool _passwordVisible = false;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  @override
  void dispose() {
   _controller!.emailController .dispose();
  _controller!.passwordController.dispose();
    super.dispose();
  }

    FocusNode namenode = FocusNode();
    FocusNode passwordsnode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
               controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Container(
                    height: 250,
                    width: 250,
                    child: const Image(
                      image: AssetImage("assets/images/tfndd.png"),
                    ),
                  ),
                  const ReusableText(
                    title: "Sign In",
                    color: AppColor.blackColor,
                    size: 27,
                    weight: FontWeight.bold,
                  ),
                  const SizedBox(height: 15),
                  const ReusableText(
                    textAlign: TextAlign.center,
                    title: "Enter your email address and password to access your account",
                    color: AppColor.textColor,
                  ),
                  const SizedBox(height: 30),
                  ReusableTextForm(
                    focusNode: namenode,
              onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(passwordsnode);
                    },
                    keyboardType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                    controller: _controller!.emailController,
                    hintText: "Email",
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "This field is required";
                      } else if (!v.contains("@")) {
                        return "Email badly formatted";
                      } else {
                        return null;
                      }
                    },
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColor.hintColor,
                    ), 
                  ),
                  const SizedBox(height: 20),
                  ReusableTextForm(
                    focusNode: passwordsnode,
                    textCapitalization: TextCapitalization.none,
                    controller: _controller!.passwordController,
                    hintText: "Password",
                    obscureText: !_passwordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                        color: AppColor.btnColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Password should not be empty";
                      } else {
                        return null;
                      }
                    },
                    prefixIcon: const Icon(
                      Icons.password_outlined,
                      color: AppColor.hintColor,
                    )
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) => const ForgotPassword(),
                            ),
                          );
                        },
                        child: const ReusableText(
                          title: "Forgot Password?",
                          color: Color(0xffb99ca0),
                          weight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                 _controller!.isLoading
                      ? const CircularProgressIndicator(color: AppColor.blackColor)
                      : ReusableButton(
                          title: "Sign In",
                          onTap: () async {
                              if (_formKey.currentState!.validate()) {
                           await _controller!.userLogin();
                            }

                          },
                        ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const ReusableText(
                        title: "Create a new account?",
                        color: AppColor.textColor,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) => Signup(email: widget.email2),
                            ),
                          );
                        },
                        child: const ReusableText(
                          title: "   Sign Up",
                          color: AppColor.btnColor,
                          weight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
