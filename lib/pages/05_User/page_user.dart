import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_workout_diary_app/global/components/ds_button.dart';
import 'package:my_workout_diary_app/global/components/ds_input_field.dart';
import 'package:my_workout_diary_app/global/components/ds_two_button_dialog.dart';
import 'package:my_workout_diary_app/global/enum/view_state.dart';
import 'package:my_workout_diary_app/global/model/user/model_request_update.dart';
import 'package:my_workout_diary_app/global/model/user/model_response_update.dart';
import 'package:my_workout_diary_app/global/model/user/model_user.dart';
import 'package:my_workout_diary_app/global/provider/auth_provider.dart';
import 'package:my_workout_diary_app/global/provider/file_provider.dart';
import 'package:my_workout_diary_app/global/provider/user_provider.dart';
import 'package:my_workout_diary_app/global/style/constants.dart';
import 'package:my_workout_diary_app/global/style/ds_colors.dart';
import 'package:my_workout_diary_app/global/style/ds_text_styles.dart';
import 'package:provider/provider.dart';

class PageUser extends StatefulWidget {
  const PageUser({Key? key}) : super(key: key);

  @override
  State<PageUser> createState() => _PageUserState();
}

class _PageUserState extends State<PageUser> {
  @override
  Widget build(BuildContext context) {
    return PageUserView();
  }
}

class PageUserView extends StatefulWidget {
  const PageUserView({Key? key}) : super(key: key);

  @override
  State<PageUserView> createState() => _PageUserViewState();
}

class _PageUserViewState extends State<PageUserView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textNameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _textNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(),
    );
  }

  _appBar() {
    return AppBar(
      title: const Text('??????'),
      centerTitle: false,
      automaticallyImplyLeading: false,
      actions: [
        PopupMenuButton<int>(
          onSelected: (value) {
            if (value == 0) {
              context.read<AuthProvider>().signOut();
              Navigator.of(context).pushNamedAndRemoveUntil('PageLogin', (route) => false);
            } else if (value == 1) {
              context.read<AuthProvider>().drop();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 0,
              child: Text('????????????', style: DSTextStyles.regular14Black),
            ),
            PopupMenuItem(
              value: 1,
              child: Text('????????????', style: DSTextStyles.regular14Tomato),
            ),
          ],
        ),
      ],
    );
  }

  Widget _body() {
    final FocusScopeNode node = FocusScope.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultHorizontalPadding, vertical: kDefaultVerticalPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                        if (image == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('???????????? ???????????? ????????????. ?????? ????????? ?????????.'),
                            ),
                          );
                          return;
                        }
                        var serverImagePath = await context.read<FileProvider>().uploadFile([File(image.path)]);
                        if (serverImagePath == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('???????????? ????????? ???????????? ????????????. ?????? ????????? ?????????.'),
                            ),
                          );
                          return;
                        }

                        ModelUser updatedMe = context.read<UserProvider>().me;
                        updatedMe.profileImage = serverImagePath;
                        var result = await context.read<UserProvider>().updateProfile(updatedMe);
                        if (result == false) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('????????? ????????? ???????????????. ?????? ????????? ?????????.'),
                            ),
                          );
                          return;
                        }
                      },
                      child: getProfileImage(),
                    ),
                    SizedBox(width: 18),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: '???????????????\n', style: DSTextStyles.bold18WarmGrey),
                              TextSpan(
                                  text: '${context.watch<UserProvider>().me.name}', style: DSTextStyles.bold18Black),
                              TextSpan(text: '???!', style: DSTextStyles.bold18WarmGrey),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 20),
                        Text(context.watch<UserProvider>().me.email!),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text('?????? ????????????', style: DSTextStyles.bold18Black),
                DSInputField(
                  controller: _textNameController,
                  hintText: "???????????? ????????? ??????????????????",
                  warningMessage: "????????? ??????????????????",
                  onEditingComplete: () => node.nextFocus(),
                  validator: (value) {
                    if (value!.length > 10) {
                      return "10??? ?????? ??????????????????.";
                    }
                    if (value.isEmpty) {
                      return "????????? ??????????????????.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                DSButton(
                    text: '????????????',
                    press: () async {
                      var result = await _modify();
                      if (result == true) {
                        _textNameController.clear();
                        FocusScope.of(context).unfocus();
                        await DSDialog.showOneButtonDialog(
                            context: context, title: '??????', subTitle: '???????????? ?????????????????? ????', btnText: '??????');
                      }
                    },
                    type: ButtonType.normal,
                    width: SizeConfig.screenWidth),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getProfileImage() {
    if (context.read<UserProvider>().state == ViewState.Busy) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Container(
      height: 80,
      width: 80,
      child: Stack(
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(300),
              child: CachedNetworkImage(
                imageUrl: context.watch<UserProvider>().me.profileImage ?? defaultUser,
                fit: BoxFit.cover,
                height: 80,
                width: 80,
              )),
          Positioned(
            top: 60,
            left: 60,
            child: Container(
              alignment: Alignment.center,
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                  color: DSColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(width: 1, color: DSColors.grey_06)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.camera_alt,
                    color: DSColors.grey_06,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    bool result = await context.read<AuthProvider>().signOut();
    if (result) {
      Navigator.of(context).pushNamed('PageLogin');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('??????????????? ??????????????????. ?????? ??????????????????.'),
        ),
      );
    }
  }

  Future<bool?> _modify() async {
    var result = _formKey.currentState?.validate();
    if (result == false) {
      return false;
    }
    result = await DSDialog.showTwoButtonDialog(
      context: context,
      title: '????????????',
      subTitle: '???????????? ?????????????????????????',
      btn1Text: '?????????,',
      btn2Text: '???,',
    );
    if (result == false) {
      return false;
    }

    ModelUser updatedMe = context.read<UserProvider>().me;
    updatedMe.name = _textNameController.text;

    result = await context.read<UserProvider>().updateProfile(updatedMe);
    if (result == false) {
      return false;
    }
    return true;
  }
}
