import 'package:flutter_bloc/flutter_bloc.dart';

class LangCubit extends Cubit<String> {
  LangCubit() : super('en');

  void toggle(String lang) => emit(lang);
}
