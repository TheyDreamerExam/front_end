import 'package:coord_converter/features/presentation/converter_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConverterCubit extends Cubit<ConverterState> {
  ConverterCubit() : super(const ConverterState());

  TextEditingController longTextController = TextEditingController();
  TextEditingController latTextController = TextEditingController();

}