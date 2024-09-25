import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'temp_state.dart';

class TempCubit extends Cubit<TempState> with HydratedMixin {
  TempCubit() : super(const TempState()) {
    hydrate();
  }

  TempState getCopy() {
    return TempState.fromMap(TempState.toMap(state));
  }

  void processIndex(int index) {
    Set<int> tempCopy = getCopy().doneQuestionIndex;

    if (state.doneQuestionIndex.contains(index)) {
      tempCopy.remove(index);
    } else {
      tempCopy.add(index);
    }

    emit(state.copyWith(doneQuestionIndex: tempCopy));
  }

  @override
  TempState? fromJson(Map<String, dynamic> json) {
    return TempState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(TempState state) {
    return TempState.toMap(state);
  }
}
