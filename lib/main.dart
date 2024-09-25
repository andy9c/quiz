import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:rive/rive.dart';

import 'package:quiz/cubit/cubit.dart';
import 'package:quiz/lib.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );

  Bloc.observer = AppBlocObserver(showInfo: false);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          builder: (context, child) => ResponsiveBreakpoints.builder(
            child: child!,
            breakpoints: [
              const Breakpoint(start: 0, end: 450, name: MOBILE),
              const Breakpoint(start: 451, end: 800, name: TABLET),
              const Breakpoint(start: 801, end: 1920, name: DESKTOP),
              const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
            ],
          ),
          debugShowCheckedModeBanner: false,
          title: 'Bible Quiz',
          theme: ThemeData(
            // This is the theme of your application.
            //
            // TRY THIS: Try running your application with "flutter run". You'll see
            // the application has a blue toolbar. Then, without quitting the app,
            // try changing the seedColor in the colorScheme below to Colors.green
            // and then invoke "hot reload" (save your changes or press the "hot
            // reload" button in a Flutter-supported IDE, or press "r" if you used
            // the command line to start the app).
            //
            // Notice that the counter didn't reset back to zero; the application
            // state is not lost during the reload. To reset the state, use hot
            // restart instead.
            //
            // This works for code too, not just values: Most code changes can be
            // tested with just a hot reload.
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => TempCubit(),
              ),
            ],
            child: const MyHomePage(
                title: 'BISHOP ALPHONSE BILUNG SVD MEMORIAL, BIBLE QUIZ 2024'),
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SMIInput<bool>? _happy, _angry, _isFireworks, _themeToggled;
  List<Widget> groupA = [];
  Map<int, List<int>> groupARoundList = {};
  List<int> groupARoundLanding = [];

  AudioPlayer correctPlay = AudioPlayer();
  AudioPlayer wrongPlay = AudioPlayer();
  AudioPlayer overPlay = AudioPlayer();
  AudioPlayer startPlay = AudioPlayer();
  AudioPlayer notifyPlay = AudioPlayer();

  selectQuestion(int? val) {
    setState(() {
      showQuestions = false;
      overPlayed = false;

      _themeToggled!.change(false);

      _selectedOptions = List<bool>.filled(4, false);
      _selectedOptionsSix = List<bool>.filled(6, false);
      selectedQuestionIndex = val!;

      endTime = DateTime.now().add(
        const Duration(
          minutes: 0,
          seconds: 0,
        ),
      );

      _onIdle();
      playNotify();
    });
  }

  loadQuestions(BuildContext ctx, int set) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            questionSets[groupARoundLanding[set - 1]]
                .entries
                .firstWhere((e) => e.key == "title")
                .value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 100, fontWeight: FontWeight.bold),
          ),
          content: BlocBuilder<TempCubit, TempState>(
            bloc: BlocProvider.of<TempCubit>(ctx),
            buildWhen: (prev, current) => true,
            builder: (context, state) {
              return SizedBox(
                key: UniqueKey(),
                width: 85.sw,
                height: 70.sh,
                child: GridView.count(
                  key: UniqueKey(),
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  childAspectRatio: 1.78,
                  crossAxisCount: 3, // 3 columns in the grid
                  children: List.generate(
                      groupARoundList.entries
                          .firstWhere((e) => e.key == set,
                              orElse: () => const MapEntry(0, []))
                          .value
                          .length, (index) {
                    // Generate 12 buttons
                    return ElevatedButton(
                      key: UniqueKey(),
                      onPressed: () {
                        int origIndex = groupARoundList.entries
                            .firstWhere((e) => e.key == set,
                                orElse: () => const MapEntry(0, []))
                            .value[index];

                        if (state.doneQuestionIndex.contains(origIndex)) {
                          //Navigator.of(context).pop();
                          selectQuestion(groupARoundLanding[set - 1]);
                        }

                        BlocProvider.of<TempCubit>(ctx).processIndex(origIndex);

                        if (!state.doneQuestionIndex.contains(origIndex)) {
                          //Navigator.of(context).pop();
                          selectQuestion(origIndex);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: state.doneQuestionIndex.contains(
                                groupARoundList.entries
                                    .firstWhere((e) => e.key == set,
                                        orElse: () => const MapEntry(0, []))
                                    .value[index])
                            ? Colors.red
                            : Colors.green,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                            fontSize: 100, fontWeight: FontWeight.bold),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  initState() {
    audio();
    makeCalculations(context);

    super.initState();
  }

  Future<void> audio() async {
    try {
      await correctPlay.setPlayerMode(PlayerMode.lowLatency);
      await wrongPlay.setPlayerMode(PlayerMode.lowLatency);
      await overPlay.setPlayerMode(PlayerMode.lowLatency);
      await startPlay.setPlayerMode(PlayerMode.lowLatency);
      await notifyPlay.setPlayerMode(PlayerMode.lowLatency);

      await correctPlay.setSourceAsset("audio/y.mp3");
      await wrongPlay.setSourceAsset("audio/o.mp3");
      await overPlay.setSourceAsset("audio/over.mp3");
      await startPlay.setSourceAsset("audio/bgm.mp3");
      await notifyPlay.setSourceAsset("audio/not.mp3");
      // ignore: empty_catches
    } catch (e) {}
  }

  List<bool> _selectedOptions = <bool>[
    false,
    false,
    false,
    false,
  ];

  List<bool> _selectedOptionsSix = <bool>[
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  bool vertical = false;
  int selectedOptionIndex = 0, selectedQuestionIndex = 0;

  DateTime endTime = DateTime.now().add(
    const Duration(
      minutes: 0,
      seconds: 0,
    ),
  );

  bool showQuestions = false;
  bool overPlayed = false;

  void _onRiveInit(Artboard artboard) {
    final StateMachineController? controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1');

    if (controller != null) {
      artboard.addController(controller);
      _happy = controller.findInput<bool>('Happy');
      _angry = controller.findInput<bool>('Angry');
    }
  }

  void _onRiveInitFireworks(Artboard artboard) {
    final StateMachineController? controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1');

    if (controller != null) {
      artboard.addController(controller);
      _isFireworks = controller.findInput<bool>('isFireworksout');
    }
  }

  void _onRiveInitDayNight(Artboard artboard) {
    final StateMachineController? controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1');

    if (controller != null) {
      artboard.addController(controller);
      _themeToggled = controller.findInput<bool>('Theme toggled');
    }
  }

  void playCorrect() async {
    await stopAll();
    _isFireworks!.change(true);
    await correctPlay.resume();
  }

  void playWrong() async {
    await stopAll();
    await wrongPlay.resume();
  }

  void playOver() async {
    await stopAll();
    await overPlay.resume();
  }

  void playStart() async {
    await stopAll();
    if (showQuestions) await startPlay.resume();
  }

  void playNotify() async {
    await stopAll();
    await notifyPlay.resume();
  }

  Future<void> stopAll() async {
    _isFireworks!.change(false);
    await startPlay.stop();
    await correctPlay.stop();
    await wrongPlay.stop();
    await overPlay.stop();
    await notifyPlay.stop();
  }

  void _onHappy() {
    _happy!.change(true);
    _angry!.change(false);

    playCorrect();
  }

  void _onAngry() {
    _happy!.change(false);
    _angry!.change(true);

    playWrong();
  }

  void _onIdle() {
    _happy!.change(false);
    _angry!.change(false);
  }

  void makeCalculations(BuildContext context) {
    Set<int> uniqueSets = {};

    for (var map in questionSets) {
      if (map.containsKey("set")) {
        uniqueSets.add(map["set"]);
      }
    }

    for (int s in uniqueSets) {
      int index = 0;
      List<int> c = [];
      for (var map in questionSets) {
        if (map.containsKey("set") &&
            map["set"] == s &&
            !map.containsKey("main")) {
          c.add(index);
        }
        index = index + 1;
      }
      groupARoundList.addAll({s: c});
    }

    for (int s in uniqueSets) {
      int index = 0;
      for (var map in questionSets) {
        if (map.containsKey("set") &&
            map["set"] == s &&
            map.containsKey("main")) {
          groupARoundLanding.add(index);
        }
        index = index + 1;
      }

      groupA.add(IconButton(
        onPressed: () {
          selectQuestion(groupARoundLanding[s - 1]);
          loadQuestions(context, s);
        },
        icon: const Icon(Icons.ac_unit),
        tooltip: questionSets[groupARoundLanding[s - 1]]
            .entries
            .firstWhere((e) => e.key == "title")
            .value,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, bool> opts = questionSets[selectedQuestionIndex]
        .entries
        .firstWhere((e) => e.key == "options")
        .value;
    // opts.shuffle();

    List<Widget> w = [];
    List<Widget> z = [];

    int count = 0;

    opts.forEach((key, value) {
      Widget g = Expanded(
        child: ElevatedButton(
          onPressed: value == true ? _onHappy : _onAngry,
          child: Text(
            key,
            textAlign: TextAlign.center,
            softWrap: true,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
        ),
      );
      w.add(g);

      z.add(
        Container(
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: selectedQuestionIndex < 7
                ? value == true && _selectedOptions[count] == true
                    ? Colors.green
                    : Theme.of(context).colorScheme.tertiaryContainer
                : value == true && _selectedOptionsSix[count] == true
                    ? Colors.green
                    : Theme.of(context).colorScheme.tertiaryContainer,
            // border: Border.all(color: Colors.black, width: 1.0),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              key,
              textAlign: TextAlign.center,
              softWrap: true,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
        ),
      );

      count = count + 1;
      w.add(const SizedBox(
        width: 16,
        height: 16,
      ));
    });

    Widget t = Padding(
      padding: const EdgeInsets.all(8.0),
      child: ToggleButtons(
        direction: vertical ? Axis.vertical : Axis.horizontal,
        onPressed: (int index) {
          setState(() {
            selectedOptionIndex = index;

            bool b = opts.entries.toList()[index].value;

            if (z.length == 4) {
              if (_selectedOptions[index] == false) {
                b == true ? _onHappy() : _onAngry();
              } else {
                _onIdle();
              }

              _selectedOptions[index] = !_selectedOptions[index];
            } else {
              if (_selectedOptionsSix[index] == false) {
                b == true ? _onHappy() : _onAngry();
              } else {
                _onIdle();
              }

              _selectedOptionsSix[index] = !_selectedOptionsSix[index];
            }
          });
        },
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        selectedBorderColor: Colors.red[700],
        splashColor: Colors.amber,
        selectedColor: Colors.red,
        fillColor: Colors.blue[200],
        color: Theme.of(context).buttonTheme.colorScheme!.primary,
        hoverColor: Theme.of(context).highlightColor,
        constraints: BoxConstraints(
          minHeight: 100.0,
          minWidth: z.length == 4 ? 250.0 : 180,
        ),
        isSelected: z.length == 4 ? _selectedOptions : _selectedOptionsSix,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
        children: z,
      ),
    );
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: groupA,
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Center(
            //   child: RiveAnimation.asset(
            //     'assets/rive/breathing_animation.riv',
            //     fit: BoxFit.cover,
            //     alignment: Alignment.topLeft,
            //     stateMachines: const ['State Machine 1'],
            //     onInit: _onRiveInit,
            //   ),
            // ),
            Center(
              child: RiveAnimation.asset(
                'assets/rive/dark_light_theme.riv',
                fit: BoxFit.cover,
                alignment: Alignment.topLeft,
                stateMachines: const ['State Machine 1'],
                onInit: _onRiveInitDayNight,
              ),
            ),
            Center(
              child: RiveAnimation.asset(
                'assets/rive/fireworks.riv',
                fit: BoxFit.cover,
                alignment: Alignment.topLeft,
                stateMachines: const ['State Machine 1'],
                onInit: _onRiveInitFireworks,
              ),
            ),
            Center(
              child: RiveAnimation.asset(
                'assets/rive/grumpy_bear_2_rev.riv',
                fit: BoxFit.cover,
                alignment: Alignment.topLeft,
                stateMachines: const ['State Machine 1'],
                onInit: _onRiveInit,
              ),
            ),
            IgnorePointer(
              ignoring: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 0, 50),
                // child: Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                //   children: w,
                // ),
                child: showQuestions ? t : Container(),
              ),
            ),
            IgnorePointer(
              ignoring: true,
              child: Padding(
                padding: EdgeInsets.fromLTRB(40.sw, 0, 1.sw, 30.sh),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.white38,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: Text(
                    questionSets[selectedQuestionIndex]
                        .entries
                        .firstWhere((e) => e.key == "question")
                        .value,
                    softWrap: true,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                ),
              ),
            ),
            IgnorePointer(
              ignoring: true,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 60.sw, 65.sh),
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  key: GlobalKey(),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    // border: Border.all(color: Colors.black, width: 1.0),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TimerCountdown(
                    format: CountDownTimerFormat.minutesSeconds,
                    endTime: endTime,
                    timeTextStyle: const TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                      fontSize: 72,
                    ),
                    descriptionTextStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    onEnd: () {
                      if (showQuestions == true && overPlayed == false) {
                        playOver();
                        overPlayed = true;
                      }
                    },
                  ),
                ),
              ),
            ),
            IgnorePointer(
              ignoring: false,
              child: DropdownButton<int>(
                value: selectedQuestionIndex,
                items: List.generate(questionSets.length, (index) => index)
                    .map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(questionSets[value]
                        .entries
                        .firstWhere((e) => e.key == "title")
                        .value),
                  );
                }).toList(),
                onChanged: (val) {
                  selectQuestion(val);
                },
              ),
            ),
            IgnorePointer(
              ignoring: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(200, 0, 0, 10),
                child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showQuestions = true;
                        overPlayed = false;

                        _themeToggled!.change(true);

                        playStart();
                        _onIdle();

                        _selectedOptions = List<bool>.filled(4, false);
                        _selectedOptionsSix = List<bool>.filled(6, false);

                        endTime = DateTime.now().add(
                          const Duration(
                            minutes: 1,
                            seconds: 0,
                          ),
                        );
                      });
                    },
                    child: const Text("Start")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
