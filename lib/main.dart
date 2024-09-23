import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:rive/rive.dart';

import 'package:quiz/quest.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
      title: 'Flutter Demo',
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
      home: const MyHomePage(
          title: 'BISHOP ALPHONSE BILUNG SVD MEMORIAL, BIBLE QUIZ 2024'),
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
  SMIInput<bool>? _happy, _angry;

  AudioPlayer correctPlay = AudioPlayer();
  AudioPlayer wrongPlay = AudioPlayer();
  AudioPlayer overPlay = AudioPlayer();
  AudioPlayer startPlay = AudioPlayer();
  AudioPlayer notifyPlay = AudioPlayer();

  @override
  initState() {
    audio();
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

  void playCorrect() async {
    await stopAll();
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
        selectedColor: Colors.black,
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
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Center(
            child: RiveAnimation.asset(
              'assets/rive/breathing_animation.riv',
              fit: BoxFit.cover,
              alignment: Alignment.topLeft,
              stateMachines: const ['State Machine 1'],
              onInit: _onRiveInit,
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
              padding: const EdgeInsets.fromLTRB(600, 0, 20, 240),
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
              padding: const EdgeInsets.fromLTRB(0, 0, 900, 520),
              child: Container(
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
                setState(() {
                  showQuestions = false;
                  overPlayed = false;

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
    );
  }
}
