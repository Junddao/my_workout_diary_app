import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_workout_diary_app/global/components/ds_button.dart';
import 'package:my_workout_diary_app/global/components/ds_input_field.dart';
import 'package:my_workout_diary_app/global/components/plain_text_field.component.dart';
import 'package:my_workout_diary_app/global/enum/view_state.dart';
import 'package:my_workout_diary_app/global/provider/auth_provider.dart';
import 'package:my_workout_diary_app/global/provider/user_provider.dart';
import 'package:my_workout_diary_app/global/style/constants.dart';
import 'package:my_workout_diary_app/global/style/ds_colors.dart';
import 'package:my_workout_diary_app/global/style/ds_text_styles.dart';
import 'package:provider/provider.dart';

class PageLogin extends StatefulWidget {
  const PageLogin({Key? key}) : super(key: key);

  @override
  State<PageLogin> createState() => _PageLoginState();
}

class _PageLoginState extends State<PageLogin> {
  @override
  Widget build(BuildContext context) {
    return const PageLoginView();
  }
}

class PageLoginView extends StatefulWidget {
  const PageLoginView({Key? key}) : super(key: key);

  @override
  State<PageLoginView> createState() => _PageLoginViewState();
}

class _PageLoginViewState extends State<PageLoginView> {
  final _formKey = GlobalKey<FormState>();
  late final FocusScopeNode node;
  bool isLoading = false;

  final TextEditingController _tecEmail = TextEditingController();
  final TextEditingController _tecPassword = TextEditingController();

  @override
  void dispose() {
    _tecEmail.dispose();
    _tecPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    node = FocusScope.of(context);
    return Scaffold(
      body: _body(),
    );
  }

  Widget _body() {
    return Consumer<AuthProvider>(builder: (_, watch, __) {
      if (watch.state == ViewState.Busy) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              flex: 2,
              child: Center(
                child: Text('?????? ?????? ????????????', style: DSTextStyles.bold24Grey06),
              ),
            ),
            Expanded(
              flex: 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20.0),
                  _buildEmailLogin(),
                  _buildKakaoLogin(),
                  Platform.isIOS ? const SizedBox(height: 20.0) : const SizedBox.shrink(),
                  Platform.isIOS ? _buildAppleLogin() : const SizedBox.shrink(),
                  const SizedBox(height: 40.0),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEmailLogin() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // const SizedBox(height: 100),
            // Hero(
            //   tag: 'logo',
            //   child: Image.asset(
            //     "assets/icons/ic_logo_text.png",
            //     width: 209,
            //     height: 50,
            //   ),
            // ),
            const SizedBox(height: 80),
            PlainTextField(
              controller: _tecEmail,
              hintText: '???????????? ???????????????.',
              textInputAction: TextInputAction.next,
              onChanged: (value) {},
              onEditingComplete: () => node.nextFocus(),
              validator: (val) {
                return val == null || !RegExp(Validation.emailRegex).hasMatch(val) ? '????????? ????????? ?????????????????????.' : null;
              },
            ),
            const SizedBox(height: 8),
            PlainTextField(
              controller: _tecPassword,
              hintText: '??????????????? ???????????????.',
              showSecure: true,
              isSecure: true,
              onChanged: (value) {},
              onEditingComplete: () => onLogin(),
              validator: (value) {
                return value == null || value.length > 3 ? null : '??????????????? 4?????? ????????? ???????????????.';
              },
            ),
            const SizedBox(height: 8),
            // Container(
            //   alignment: Alignment.centerRight,
            //   padding: EdgeInsets.symmetric(horizontal: 20),
            //   child: InkWell(
            //     onTap: () {
            //       logger.i("TODO");
            //       // TODO
            //       // Navigator.push(
            //       //   context,
            //       //   MaterialPageRoute(
            //       //     builder: (context) {
            //       //       return LoginScreen();
            //       //     },
            //       //   ),
            //       // );
            //     },
            //     child: Text(
            //       LocaleKeys.forgot_password.tr(),
            //       style: TextStyle(
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 8),

            const SizedBox(height: 48),
            DSButton(
              width: SizeConfig.screenWidth - 40,
              text: '?????????',
              press: () {
                onLogin();
              },
            ),
            DSButton(
              width: SizeConfig.screenWidth - 40,
              type: ButtonType.transparent,
              text: '????????????',
              press: () => Navigator.of(context).pushNamed('PageEmailSignUp'),
            ),
            Divider(color: DSColors.divider),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  _buildAppleLogin() {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () async {
        bool result = await context.read<AuthProvider>().appleLogin();

        if (result == true) {
          Navigator.of(context).pushNamedAndRemoveUntil('PageTabs', (route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('????????? ??????')));
        }

        result = await context.read<UserProvider>().getMe();
        if (!result) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('?????? ????????? ??????????????? ???????????????. ?????? ????????? ?????????.'),
            ),
          );
          return;
        }

        if (result == true) {
          Navigator.of(context).pushNamedAndRemoveUntil('PageTabs', (route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('????????? ??????')));
          return;
        }
      },
      child: Container(
        width: size.width - 40,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.black,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(width: 22),
            Icon(
              FontAwesomeIcons.apple,
              size: 24,
              color: DSColors.white,
            ),
            Spacer(),
            Text('Apple??? ?????????', style: DSTextStyles.regular18white),
            Spacer(),
            SizedBox(width: 24),
            SizedBox(width: 22),
          ],
        ),
      ),
    );
  }

  _buildKakaoLogin() {
    return InkWell(
      onTap: () async {
        bool result = await context.read<AuthProvider>().kakaoLogin();
        if (!result) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('???????????? ???????????????. ?????? ????????? ?????????.'),
            ),
          );
          return;
        }

        result = await context.read<UserProvider>().getMe();
        if (!result) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('?????? ????????? ???????????? ???????????????. ?????? ????????? ?????????.'),
            ),
          );
          return;
        }

        if (result == true) {
          Navigator.of(context).pushNamedAndRemoveUntil('PageTabs', (route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('????????? ??????')));
          return;
        }
      },
      child: Container(
        width: SizeConfig.screenWidth - 40,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.yellow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 22),
            Image.asset(
              "assets/images/ic_logo_kakao.png",
              width: 24,
              height: 24,
            ),
            const Spacer(),
            const Text('???????????? ?????????', style: DSTextStyles.regular18black),
            const Spacer(),
            const SizedBox(width: 24),
            const SizedBox(width: 22),
          ],
        ),
      ),
    );
  }

  onLogin() async {
    var result = await context.read<AuthProvider>().emailSignIn(email: _tecEmail, password: _tecPassword);
    if (result == true) {
      Navigator.of(context).pushNamedAndRemoveUntil('PageTabs', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('????????? ??????')));
      return;
    }
  }
}
