import 'package:coord_converter/features/presentation/app_dialog.dart';
import 'package:coord_converter/features/presentation/converter/converter_bloc.dart';
import 'package:coord_converter/features/presentation/converter/converter_state.dart';
import 'package:coord_converter/features/presentation/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  static String routeName = "/converterScreen";

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  double statusBarHeight = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mq = MediaQuery.of(context);
      setState(() {
        statusBarHeight = mq.padding.top;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final titleBarHeight = AppBar().preferredSize.height;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final containerHeight = height - (titleBarHeight + statusBarHeight);
    final bloc = context.read<ConverterCubit>();
    final longController = bloc.longTextController;
    final latController = bloc.latTextController;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: TextWidget(
              text: "COORDS CONVERTER",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const ScrollPhysics(),
          child: SizedBox(
            height: containerHeight,
            width: width,
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  width: width,
                  height: containerHeight,
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const UIEventsWidget(),
                      const UIErrorMessage(),
                      SizedBox(height: 10.h),
                      const TextWidget(text: "LONGITUDE"),
                      TextFieldWidget(
                        controller: longController,
                        onTextChanged: (val) {
                          bloc.hideAndClearUIIndicators();
                        },
                      ),
                      SizedBox(height: 10.h),
                      const TextWidget(text: "LATITUDE"),
                      TextFieldWidget(
                        controller: latController,
                        onTextChanged: (val) {
                          bloc.hideAndClearUIIndicators();
                        },
                      ),
                      SizedBox(height: 10.h),
                      Button(
                        text: "CONVERT COORDS",
                        onPress: () {
                          bloc.convertToDMS();
                        },
                      ),
                      SizedBox(height: 20.h),
                      const ConvertedResults(),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: EdgeInsets.only(right: 20.w),
                    child: Button(
                      text: "SETTINGS",
                      onPress: () {
                        context.pushNamed(SettingsScreen.routeName);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onTextChanged;
  final bool allowFormatter;
  final bool isKeyboardDecimal;

  const TextFieldWidget({
    required this.controller,
    required this.onTextChanged,
    this.allowFormatter = true,
    this.isKeyboardDecimal = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160.w,
      child: TextField(
        onChanged: onTextChanged,
        controller: controller,
        keyboardType: !isKeyboardDecimal
            ? null
            : const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: !allowFormatter
            ? []
            : [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
        decoration: const InputDecoration(
          labelText: "",
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class Button extends StatelessWidget {
  final String text;
  final Function() onPress;

  const Button({required this.text, required this.onPress, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPress,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5.h,
        ),
      ),
    );
  }
}

class TextWidget extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const TextWidget({required this.text, this.style, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style ??
          TextStyle(
            fontSize: 11.h,
          ),
    );
  }
}

class UIErrorMessage extends StatelessWidget {
  const UIErrorMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConverterCubit, ConverterState>(
      buildWhen: (prev, current) =>
          prev.uiErrorMessage != current.uiErrorMessage,
      builder: (context, state) {
        return Text(
          state.uiErrorMessage,
          style: TextStyle(
            fontSize: 11.h,
            color: Colors.red,
          ),
        );
      },
    );
  }
}

class UIEventsWidget extends StatelessWidget {
  const UIEventsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConverterCubit, ConverterState>(
      child: const SizedBox(),
      listenWhen: (prev, current) => prev.uiEvents != current.uiEvents,
      listener: (context, state) {
        final event = state.uiEvents;
        switch (event) {
          case UIEvents.showToastMessage:
            Fluttertoast.showToast(msg: state.message);
            break;
          case UIEvents.showLoading:
            AppDialog.loading(context);
            break;
          case UIEvents.hideLoading:
            AppDialog.hide(context);
            break;
          default:
            break;
        }
      },
    );
  }
}

class ConvertedResults extends StatelessWidget {
  const ConvertedResults({super.key});

  void onSave(BuildContext context) {
    final bloc = context.read<ConverterCubit>();
    bloc.saveCoordinates();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ConverterCubit>();
    return BlocBuilder<ConverterCubit, ConverterState>(
      buildWhen: (prev, current) =>
          prev.showResult != current.showResult ||
          prev.latResult != current.latResult ||
          prev.longResult != current.longResult,
      builder: (context, state) {
        if (!state.showResult) {
          return const SizedBox();
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextWidget(
              text: "DMS RESULT",
              style: TextStyle(
                fontSize: 14.h,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 5.h),
            ResultItem(label: "LONGITUDE:", data: state.longResult),
            SizedBox(height: 15.h),
            ResultItem(label: "LATITUDE:", data: state.latResult),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(
                  text: "NOTES",
                  style: TextStyle(
                    fontSize: 13.h,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: TextFieldWidget(
                    isKeyboardDecimal: false,
                    allowFormatter: false,
                    controller: bloc.notesController,
                    onTextChanged: (val) {},
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Button(
              text: "SAVE",
              onPress: () {
                onSave(context);
              },
            ),
          ],
        );
      },
    );
  }
}

class ResultItem extends StatelessWidget {
  final String label;
  final String data;

  const ResultItem({required this.label, required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextWidget(
          text: label,
          style: TextStyle(
            fontSize: 13.h,
            fontWeight: FontWeight.w400,
          ),
        ),
        TextWidget(
          text: data,
          style: TextStyle(
            fontSize: 13.h,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
