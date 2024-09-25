// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: avoid_print, unnecessary_overrides

import 'package:hydrated_bloc/hydrated_bloc.dart';

class AppBlocObserver extends BlocObserver {
  final bool showInfo;

  AppBlocObserver({
    required this.showInfo,
  });

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (showInfo) {
      print("***** EVENT *****");
      print(event);
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print(error);
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (showInfo) {
      print("***** CHANGE CURRENT *****");
      print(change.currentState);
      print("***** CHANGE NEXT *****");
      print(change.nextState);
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (showInfo) {
      print("***** TRANS CURRENT *****");
      print(transition.currentState);
      print("***** TRANS NEXT *****");
      print(transition.nextState);
    }
  }
}
