part of 'temp_cubit.dart';

class TempState extends Equatable {
  final Set<int> doneQuestionIndex;

  const TempState({
    this.doneQuestionIndex = const {},
  });

  @override
  List<Object> get props => [doneQuestionIndex];

  TempState copyWith({
    Set<int>? doneQuestionIndex,
  }) {
    return TempState(
      doneQuestionIndex: doneQuestionIndex ?? this.doneQuestionIndex,
    );
  }

  static Map<String, dynamic> toMap(TempState state) {
    return <String, dynamic>{
      'doneQuestionIndex': state.doneQuestionIndex.toList(),
    };
  }

  factory TempState.fromMap(Map<String, dynamic> map) {
    return TempState(
      doneQuestionIndex: Set<int>.from(map['doneQuestionIndex']),
    );
  }

  String toJson(TempState state) => json.encode(toMap(state));

  factory TempState.fromJson(String source) =>
      TempState.fromMap(json.decode(source));

  @override
  String toString() => 'TempState(doneQuestionIndex: $doneQuestionIndex)';
}
