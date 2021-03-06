import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:my_workout_diary_app/global/components/ds_button.dart';
import 'package:my_workout_diary_app/global/components/plain_text_field.component.dart';
import 'package:my_workout_diary_app/global/enum/view_state.dart';
import 'package:my_workout_diary_app/global/model/user/model_request_sign_up.dart';
import 'package:my_workout_diary_app/global/provider/auth_provider.dart';
import 'package:my_workout_diary_app/global/provider/user_provider.dart';
import 'package:my_workout_diary_app/global/style/constants.dart';
import 'package:my_workout_diary_app/global/style/ds_text_styles.dart';
import 'package:my_workout_diary_app/global/util/util.dart';
import 'package:my_workout_diary_app/page_tabs.dart';
import 'package:provider/provider.dart';

class PageEmailSignUp extends StatefulWidget {
  const PageEmailSignUp({Key? key}) : super(key: key);

  @override
  State<PageEmailSignUp> createState() => _PageEmailSignUpState();
}

class _PageEmailSignUpState extends State<PageEmailSignUp> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tecEmail = TextEditingController();
  final TextEditingController _tecPassword = TextEditingController();
  final TextEditingController _tecPasswordCheck = TextEditingController();
  final TextEditingController _tecNickname = TextEditingController();

  @override
  void dispose() {
    _tecEmail.dispose();
    _tecPassword.dispose();
    _tecPasswordCheck.dispose();
    _tecNickname.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _body(),
    );
  }

  Widget _body() {
    var authProvider = context.watch<AuthProvider>();
    return authProvider.state == ViewState.Busy
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Column(
            children: [
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      Text(
                        "????????????.",
                        style: DSTextStyles.regularFont(fontSize: 18.0),
                      ),
                      const SizedBox(height: 53),
                      PlainTextField(
                        controller: _tecEmail,
                        hintText: "?????????",
                        keyboardType: TextInputType.emailAddress,
                        // textInputAction: TextInputAction.next,
                        onEditingComplete: () => context.nextEditableTextFocus(),
                        showClear: true,
                        onChanged: (value) {},
                        validator: (val) {
                          return val == null || !RegExp(Validation.emailRegex).hasMatch(val) ? "???????????? ????????? ??????????????????" : null;
                        },
                      ),
                      const SizedBox(height: 8),
                      PlainTextField(
                        controller: _tecPassword,
                        hintText: "????????????",
                        showSecure: true,
                        isSecure: true,
                        onEditingComplete: () => context.nextEditableTextFocus(),
                        validator: (value) {
                          return value == null || value.length < 6 ? "??????????????? 6 ?????? ???????????? ????????????" : null;
                        },
                      ),
                      const SizedBox(height: 8),
                      PlainTextField(
                        controller: _tecPasswordCheck,
                        hintText: "???????????? ??????",
                        showSecure: true,
                        isSecure: true,
                        onFieldSubmitted: (text) {
                          _signUp();
                        },
                        validator: (value) {
                          logger.i("$value == ${_tecPassword.text} = ${value == _tecPassword.text}");
                          return value == _tecPassword.text ? null : "??????????????? ?????? ????????????";
                        },
                      ),
                      PlainTextField(
                        controller: _tecNickname,
                        hintText: "?????????",
                        showClear: true,
                        onEditingComplete: () => context.nextEditableTextFocus(),
                        validator: (value) {
                          return value == null || value.isEmpty ? "???????????? ??????????????????" : null;
                        },
                      ),
                      const SizedBox(height: 24),
                      DSButton(
                        width: SizeConfig.screenWidth - 40,
                        text: "????????????",
                        press: () {
                          _signUp();
                        },
                      ),
                      const SizedBox(height: 8),
                      DSButton(
                          width: SizeConfig.screenWidth - 40,
                          text: "??????????????? ????????????",
                          // press: () {},
                          press: () {
                            Navigator.of(context).pop();
                          },
                          type: ButtonType.transparent),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          );
  }

  _signUp() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    bool result = await context.read<AuthProvider>().emailSignUp(
          email: _tecEmail.text,
          password: _tecPassword.text,
          name: _tecNickname.text,
        );

    if (result == true) {
      Navigator.of(context).pushNamedAndRemoveUntil('PageTabs', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('????????? ??????')));
      return;
    }
  }
}
