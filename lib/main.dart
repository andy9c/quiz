import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Map<int, List<int>> groupRoundList = {};
  List<int> groupARoundLanding = [];

  AudioPlayer correctPlay = AudioPlayer();
  AudioPlayer wrongPlay = AudioPlayer();
  AudioPlayer overPlay = AudioPlayer();
  AudioPlayer startPlay = AudioPlayer();
  AudioPlayer notifyPlay = AudioPlayer();
  AudioPlayer fireworksPlay = AudioPlayer();
  AudioPlayer backgroundPlay = AudioPlayer();
  AudioPlayer fiftyfiftyPlay = AudioPlayer();

  double bgAudioLevel = 0.2;
  int timeOutTimerSeconds = 30;

  bool fiftyfifty = false;
  Map<String, bool> ftft = {};
  Color? fillerColor = Colors.red;

  List<Timer> activeTimers = [];
  RiveFile? _dayNight, _fireworks, _bear, _frog;

  void scheduleTask(Duration duration, Function callback) {
    // Cancel all existing timers
    for (var timer in activeTimers) {
      timer.cancel();
    }
    activeTimers.clear();

    // Create and schedule the new timer
    Timer newTimer = Timer(duration, () {
      callback();
    });
    activeTimers.add(newTimer);
  }

  selectQuestion(int? val) {
    setState(() {
      showOptions = false;
      overPlayed = false;

      _themeToggled!.change(false);

      _selectedOptionsOne = List<bool>.filled(1, false);
      _selectedOptionsTwo = List<bool>.filled(2, false);
      _selectedOptionsFour = List<bool>.filled(4, false);
      _selectedOptionsSix = List<bool>.filled(6, false);
      selectedQuestionIndex = val!;

      fiftyfifty = false;

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

  Future<Map<String, dynamic>> readFile(String fileName) async {
    try {
      // Get the path to the 'My Documents older' folder
      final myDocumentsFolderPath =
          (await getApplicationDocumentsDirectory()).path;

      // Create a File object
      final file = File('$myDocumentsFolderPath\\$fileName');

      // Read the file contents
      final contents = await file.readAsString();
      Map<String, dynamic> jsonData = jsonDecode(contents);

      return jsonData;
    } catch (e) {
      // Handle errors (e.g., file not found)
      //print('Error reading file: $e');
      return {
        "PRANOLD": 100,
        "AMAN": 200,
        "SMIRITY": 300,
        "KAMLES": 100,
        "SNEHA": 200,
        "DIVYA": 300
      }; // Or throw an exception, depending on your error handling strategy
    }
  }

  loadResultsArranged(BuildContext ctx, String title) async {
    // final String fileContents =
    //     await readFile('my_text_file.txt');

    // Map<String, dynamic> jsonData = jsonDecode(fileContents);

    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<Map<String, dynamic>>(
          future: readFile("res.txt"),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: AlertDialog(
                  title: const Text('Error'),
                  content: SizedBox(
                      key: UniqueKey(),
                      width: 30.sw,
                      height: 40.sh,
                      child: Text('Error:   ${snapshot.error}')),
                ),
              );
            } else {
              Map<String, dynamic> data = snapshot.data!;
              // Convert to List of MapEntry
              List<MapEntry<String, dynamic>> entries = data.entries.toList();

              // Sort the List
              entries.sort((a, b) => b.value.compareTo(a.value));

              // Convert back to a LinkedHashMap (preserves insertion order)
              Map<String, dynamic> sortedData =
                  LinkedHashMap.fromEntries(entries);

              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: AlertDialog(
                  title: Text(
                    title,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                  ),
                  content: SizedBox(
                    key: UniqueKey(),
                    width: 40.sw,
                    height: 80.sh,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: sortedData.entries.toList().length,
                      itemBuilder: (BuildContext context, int index) {
                        String key =
                            sortedData.keys.elementAt(index).split(';')[0];
                        return Column(
                          children: <Widget>[
                            ListTile(
                              dense: false,
                              isThreeLine: false,
                              title: Text(
                                key,
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: index % 2 == 0
                                        ? Colors.pinkAccent
                                        : Colors.blueAccent),
                              ),
                              subtitle: Text(
                                sortedData.keys.elementAt(index).split(';')[1],
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: index % 2 == 0
                                        ? Colors.pinkAccent
                                        : Colors.blueAccent),
                              ),
                              trailing: Text(
                                "${sortedData.values.elementAt(index)}",
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: index % 2 == 0
                                        ? Colors.pinkAccent
                                        : Colors.blueAccent),
                              ),
                            ),
                            const Divider(
                              height: 2.0,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }

  loadResults(BuildContext ctx, String title) async {
    // final String fileContents =
    //     await readFile('my_text_file.txt');

    // Map<String, dynamic> jsonData = jsonDecode(fileContents);

    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<Map<String, dynamic>>(
          future: readFile("res.txt"),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: AlertDialog(
                  title: const Text('Error'),
                  content: SizedBox(
                      key: UniqueKey(),
                      width: 30.sw,
                      height: 40.sh,
                      child: Text('Error:   ${snapshot.error}')),
                ),
              );
            } else {
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: AlertDialog(
                  title: Text(
                    title,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                  ),
                  content: SizedBox(
                    key: UniqueKey(),
                    width: 40.sw,
                    height: 50.sh,
                    child: GridView.count(
                      key: UniqueKey(),
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 1,
                      crossAxisCount: 3, // 3 columns in the grid
                      children: List.generate(
                        snapshot.data!.length,
                        (index) {
                          final random = Random();
                          return Column(
                            children: [
                              CircleAvatar(
                                radius: 6.sw,
                                backgroundColor: Color.fromRGBO(
                                  random.nextInt(256),
                                  random.nextInt(256),
                                  random.nextInt(256),
                                  1,
                                ),
                                child: Text(
                                  "${snapshot.data!.entries.toList()[index].key.split(" ").first.toUpperCase()}\n${snapshot.data!.entries.toList()[index].value}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: const [
                                        Shadow(
                                            // bottomLeft
                                            offset: Offset(-1.5, -1.5),
                                            color: Colors.black),
                                        Shadow(
                                            // bottomRight
                                            offset: Offset(1.5, -1.5),
                                            color: Colors.black),
                                        Shadow(
                                            // topRight
                                            offset: Offset(1.5, 1.5),
                                            color: Colors.black),
                                        Shadow(
                                            // topLeft
                                            offset: Offset(-1.5, 1.5),
                                            color: Colors.black),
                                      ]),
                                ),
                              ),
                              // Text(
                              //   jsonData.entries.toList()[index].key,
                              // ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }

  loadQuestions(BuildContext ctx, int set) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            title: Text(
              questionSets[groupARoundLanding[set - 1]]
                  .entries
                  .firstWhere((e) => e.key == "title")
                  .value,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            content: BlocBuilder<TempCubit, TempState>(
              bloc: BlocProvider.of<TempCubit>(ctx),
              buildWhen: (prev, current) => true,
              builder: (context, state) {
                List<int> totalRounds = groupRoundList.entries
                    .firstWhere((e) => e.key == set,
                        orElse: () => const MapEntry(0, []))
                    .value;

                return SizedBox(
                  key: UniqueKey(),
                  width: 30.sw,
                  height: totalRounds.length < 13 ? 50.sh : 70.sh,
                  child: GridView.count(
                    key: UniqueKey(),
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                    childAspectRatio: 1.78,
                    crossAxisCount: 3, // 3 columns in the grid
                    children: List.generate(totalRounds.length, (index) {
                      // Generate 12 buttons
                      return ElevatedButton(
                        key: UniqueKey(),
                        onPressed: () {
                          int origIndex = totalRounds[index];

                          if (state.doneQuestionIndex.contains(origIndex)) {
                            //Navigator.of(context).pop();
                            selectQuestion(groupARoundLanding[set - 1]);
                          }

                          BlocProvider.of<TempCubit>(ctx)
                              .processIndex(origIndex);

                          if (!state.doneQuestionIndex.contains(origIndex)) {
                            //Navigator.of(context).pop();
                            selectQuestion(origIndex);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state.doneQuestionIndex
                                  .contains(totalRounds[index])
                              ? Colors.red
                              : Colors.green,
                          foregroundColor: Colors.white,
                          textStyle: TextStyle(fontSize: 22.sp),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                              fontSize: 24.sp, fontWeight: FontWeight.bold),
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
            actions: <Widget>[
              // TextButton(
              //   onPressed: () {
              //     _startAction();
              //     Navigator.of(context).pop();
              //   },
              //   child: const Text('START'),
              // ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _startAction() {
    Map<String, bool> opts = questionSets[selectedQuestionIndex]
        .entries
        .firstWhere((e) => e.key == "options")
        .value;

    scheduleTask(Duration(seconds: timeOutTimerSeconds), () async {
      // if (showOptions == true && overPlayed == false) {
      //   playOver();
      //   overPlayed = true;

      //   await stopAll();
      // }

      playOver();
      overPlayed = true;

      await stopAll();
    });

    setState(() {
      showOptions = opts.length == 1 ? false : true;
      overPlayed = false;

      _themeToggled!.change(true);

      playStart();
      _onIdle();

      _selectedOptionsOne = List<bool>.filled(1, false);
      _selectedOptionsTwo = List<bool>.filled(2, false);
      _selectedOptionsFour = List<bool>.filled(4, false);
      _selectedOptionsSix = List<bool>.filled(6, false);

      fiftyfifty = false;

      endTime = DateTime.now().add(
        Duration(
          minutes: 0,
          seconds: timeOutTimerSeconds + 1,
        ),
      );
    });
  }

  Widget _resultButton() {
    return IconButton(
      onPressed: () {
        playNotify();

        showDialog(
          context: context,
          builder: (BuildContext _) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AlertDialog(
                title: Text(
                  "Results Awaiting ...",
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                content: SizedBox(
                  width: 40.sw,
                  height: 50.sh,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Center(
                        child: _frog == null
                            ? Container()
                            : RiveAnimation.direct(
                                _frog!,
                                fit: BoxFit.cover,
                                alignment: Alignment.bottomCenter,
                                stateMachines: const ['State Machine v03'],
                              ),
                      ),
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      playNotify();
                      // loadResults(context, "Results");
                      loadResultsArranged(context, "Leaderboard");
                    },
                    child: const Text('Load Results'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        );
      },
      icon: const Icon(Icons.settings),
      tooltip: "Results",
    );
  }

  Future<void> preload() async {
    // Initialize Rive before importing the file
    await RiveFile.initialize();

    await rootBundle.load('assets/rive/dark_light_theme.riv').then(
      (data) async {
        // Load the RiveFile from the binary data.
        setState(() {
          _dayNight = RiveFile.import(data);
        });
      },
    );

    await rootBundle.load('assets/rive/fireworks.riv').then(
      (data) async {
        // Load the RiveFile from the binary data.
        setState(() {
          _fireworks = RiveFile.import(data);
        });
      },
    );

    await rootBundle.load('assets/rive/grumpy_bear_2_rev.riv').then(
      (data) async {
        // Load the RiveFile from the binary data.
        setState(() {
          _bear = RiveFile.import(data);
        });
      },
    );

    await rootBundle.load('assets/rive/happy_frog.riv').then(
      (data) async {
        // Load the RiveFile from the binary data.
        setState(() {
          _frog = RiveFile.import(data);
        });
      },
    );
  }

  @override
  initState() {
    audio();
    makeCalculations(context);
    playBackground();

    groupA.add(_resultButton());

    super.initState();
    preload();
  }

  Future<void> audio() async {
    try {
      await correctPlay.setPlayerMode(PlayerMode.lowLatency);
      await wrongPlay.setPlayerMode(PlayerMode.lowLatency);
      await overPlay.setPlayerMode(PlayerMode.lowLatency);
      await startPlay.setPlayerMode(PlayerMode.lowLatency);
      await notifyPlay.setPlayerMode(PlayerMode.lowLatency);
      await fireworksPlay.setPlayerMode(PlayerMode.lowLatency);
      await backgroundPlay.setPlayerMode(PlayerMode.lowLatency);
      await fiftyfiftyPlay.setPlayerMode(PlayerMode.lowLatency);

      await correctPlay.setSourceAsset("audio/y.mp3");
      await wrongPlay.setSourceAsset("audio/o.mp3");
      await overPlay.setSourceAsset("audio/over.mp3");
      await startPlay.setSourceAsset("audio/bgm.mp3");
      await notifyPlay.setSourceAsset("audio/not.mp3");
      await fireworksPlay.setSourceAsset("audio/fireworks.mp3");
      await backgroundPlay.setSourceAsset("audio/quiz.mp3");
      await fiftyfiftyPlay.setSourceAsset("audio/fifty.mp3");

      await backgroundPlay.setReleaseMode(ReleaseMode.loop);
      await backgroundPlay.setVolume(bgAudioLevel);
      // ignore: empty_catches
    } catch (e) {}
  }

  List<bool> _selectedOptionsOne = <bool>[
    false,
  ];

  List<bool> _selectedOptionsTwo = <bool>[
    false,
    false,
  ];

  List<bool> _selectedOptionsFour = <bool>[
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

  // DateTime endTime = DateTime.now().add(
  //   const Duration(
  //     minutes: 0,
  //     seconds: 0,
  //   ),
  // );

  DateTime endTime = DateTime.utc(1970, 1, 1);

  bool showOptions = false;
  bool overPlayed = false;

  void _onRiveInitBear(Artboard artboard) {
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
    correctPlay.resume();
    fireworksPlay.resume();
    backgroundPlay.setVolume(bgAudioLevel);
  }

  void playWrong() async {
    await stopAll();
    await wrongPlay.resume();
    backgroundPlay.setVolume(bgAudioLevel);
  }

  void playOver() async {
    overPlay.resume();
    await stopAll();
    backgroundPlay.setVolume(bgAudioLevel);
  }

  void playStart() async {
    await stopAll();
    var opts = questionSets[selectedQuestionIndex]
        .entries
        .firstWhere((e) => e.key == "options")
        .value;

    if (showOptions || opts.length == 1) {
      await backgroundPlay.setVolume(0.0);
      // await backgroundPlay.resume();
      await startPlay.resume();
    }
  }

  void playNotify() async {
    await stopAll();
    await notifyPlay.resume();
    backgroundPlay.setVolume(bgAudioLevel);
  }

  void playFireworks() async {
    await fireworksPlay.resume();
    backgroundPlay.setVolume(bgAudioLevel);
  }

  void playBackground() async {
    backgroundPlay.resume();
  }

  void playFiftyfifty() async {
    await stopAll();
    await fiftyfiftyPlay.resume();
    backgroundPlay.setVolume(bgAudioLevel);
  }

  Future<void> stopAll() async {
    _isFireworks!.change(false);
    await startPlay.stop();
    await correctPlay.stop();
    await wrongPlay.stop();
    // await overPlay.stop();
    await notifyPlay.stop();
    await fireworksPlay.stop();
    await fiftyfiftyPlay.stop();
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
      groupRoundList.addAll({s: c});
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

      groupA.add(Badge(
        label: Text('${(s - 1) % 5 + 1}'),
        child: IconButton(
          onPressed: () {
            selectQuestion(groupARoundLanding[s - 1]);
            loadQuestions(context, s);
          },
          icon: s < 6
              ? const Icon(Icons.adobe_rounded)
              : const Icon(Icons.ac_unit),
          tooltip: questionSets[groupARoundLanding[s - 1]]
              .entries
              .firstWhere((e) => e.key == "title")
              .value,
        ),
      ));
    }
  }

  Map<String, bool> getRandomEntriesFiftyFifty(Map<String, bool> map) {
    List<MapEntry<String, bool>> trueEntries = [];
    List<MapEntry<String, bool>> falseEntries = [];

    // Separate entries based on their boolean values
    for (var entry in map.entries) {
      if (entry.value) {
        trueEntries.add(entry);
      } else {
        falseEntries.add(entry);
      }
    }

    // Check if we have at least one true and one false entry
    if (trueEntries.isEmpty || falseEntries.isEmpty) {
      return {};
    }

    // Randomly select one entry from each list
    Random random = Random();
    MapEntry<String, bool> randomTrueEntry =
        trueEntries[random.nextInt(trueEntries.length)];
    MapEntry<String, bool> randomFalseEntry =
        falseEntries[random.nextInt(falseEntries.length)];

    if (random.nextBool()) {
      return Map.fromEntries([randomTrueEntry, randomFalseEntry]);
    } else {
      return Map.fromEntries([randomFalseEntry, randomTrueEntry]);
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, bool> opts = questionSets[selectedQuestionIndex]
        .entries
        .firstWhere((e) => e.key == "options")
        .value;
    // opts.shuffle();

    List<Widget> optionButtons = [];

    int count = 0;

    opts.forEach((key, value) {
      Color bg = Colors.green;

      // if (selectedQuestionIndex < 7) {
      //   switch (opts.length) {
      //     case 1:
      //       bg = value == true && _selectedOptionsOne[count] == true
      //           ? Colors.green
      //           : Theme.of(context).colorScheme.errorContainer;
      //       break;
      //     case 2:
      //       bg = value == true && _selectedOptionsTwo[count] == true
      //           ? Colors.green
      //           : Theme.of(context).colorScheme.errorContainer;
      //       break;
      //     case 4:
      //       bg = value == true && _selectedOptionsFour[count] == true
      //           ? Colors.green
      //           : Theme.of(context).colorScheme.errorContainer;
      //     case 6:
      //       bg = value == true && _selectedOptionsSix[count] == true
      //           ? Colors.green
      //           : Theme.of(context).colorScheme.errorContainer;
      //   }

      // }

      switch (opts.length) {
        case 1:
          bg = value == true && _selectedOptionsOne[count] == true
              ? Colors.green
              : Theme.of(context).colorScheme.errorContainer;
          break;
        case 2:
          bg = value == true && _selectedOptionsTwo[count] == true
              ? Colors.green
              : Theme.of(context).colorScheme.errorContainer;
          break;
        case 4:
          bg = value == true && _selectedOptionsFour[count] == true
              ? Colors.green
              : Theme.of(context).colorScheme.errorContainer;
        case 6:
          bg = value == true && _selectedOptionsSix[count] == true
              ? Colors.green
              : Theme.of(context).colorScheme.errorContainer;
      }

      optionButtons.add(
        Container(
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: bg,
            // border: Border.all(color: Colors.black, width: 1.0),
            borderRadius: const BorderRadius.all(Radius.circular(16)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: opts.length == 1 ? 30.sw : 15.sw,
              child: Text(
                fiftyfifty
                    ? ftft.containsKey(key)
                        ? key
                        : "---"
                    : key,
                textAlign: TextAlign.center,
                softWrap: true,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
        ),
      );

      count = count + 1;
    });

    Widget allOptions = Padding(
      padding: const EdgeInsets.all(8.0),
      child: ToggleButtons(
        direction: vertical ? Axis.vertical : Axis.horizontal,
        onPressed: (int index) {
          setState(() {
            selectedOptionIndex = index;

            bool b = opts.entries.toList()[index].value;
            fillerColor = b ? Colors.green : Colors.red;

            if (opts.length == 1) {
              if (_selectedOptionsOne[index] == false) {
                b == true ? _onHappy() : _onAngry();
              } else {
                _onIdle();
              }

              _selectedOptionsOne[index] = !_selectedOptionsOne[index];
            } else if (opts.length == 2) {
              if (_selectedOptionsTwo[index] == false) {
                b == true ? _onHappy() : _onAngry();
              } else {
                _onIdle();
              }

              _selectedOptionsTwo[index] = !_selectedOptionsTwo[index];
            } else if (opts.length == 4) {
              if (_selectedOptionsFour[index] == false) {
                b == true ? _onHappy() : _onAngry();
              } else {
                _onIdle();
              }

              _selectedOptionsFour[index] = !_selectedOptionsFour[index];
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
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        //selectedBorderColor: Colors.red[700],
        //splashColor: Colors.amber,
        selectedColor: Colors.red,
        //fillColor: Colors.blue[200],
        color: Theme.of(context).buttonTheme.colorScheme!.primary,
        fillColor: fillerColor,
        hoverColor: Theme.of(context).highlightColor,
        isSelected: optionButtons.length == 1
            ? _selectedOptionsOne
            : optionButtons.length == 2
                ? _selectedOptionsTwo
                : optionButtons.length == 4
                    ? _selectedOptionsFour
                    : _selectedOptionsSix,
        textStyle: const TextStyle(
            // fontWeight: FontWeight.bold,
            // fontSize: 28,
            shadows: [
              // Shadow(
              //     // bottomLeft
              //     offset: Offset(-1.5, -1.5),
              //     color: Colors.white),
              // Shadow(
              //     // bottomRight
              //     offset: Offset(1.5, -1.5),
              //     color: Colors.white),
              Shadow(
                  // topRight
                  offset: Offset(1.5, 1.5),
                  color: Colors.white),
              // Shadow(
              //     // topLeft
              //     offset: Offset(-1.5, 1.5),
              //     color: Colors.white),
            ]),
        children: optionButtons,
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
      body: LayoutBuilder(builder: (context, constraints) {
        return Stack(
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
            // Center(
            //   child: RiveAnimation.asset(
            //     'assets/rive/dark_light_theme.riv',
            //     fit: BoxFit.cover,
            //     alignment: Alignment.topLeft,
            //     stateMachines: const ['State Machine 1'],
            //     onInit: _onRiveInitDayNight,
            //   ),
            // ),
            Center(
              child: _dayNight == null
                  ? Container()
                  : RiveAnimation.direct(
                      _dayNight!,
                      fit: BoxFit.cover,
                      alignment: Alignment.topLeft,
                      stateMachines: const ['State Machine 1'],
                      onInit: _onRiveInitDayNight,
                    ),
            ),
            Center(
              child: _fireworks == null
                  ? Container()
                  : RiveAnimation.direct(
                      _fireworks!,
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                      stateMachines: const ['State Machine 1'],
                      onInit: _onRiveInitFireworks,
                    ),
            ),
            Center(
              child: _bear == null
                  ? Container()
                  : RiveAnimation.direct(
                      _bear!,
                      fit: BoxFit.cover,
                      alignment: Alignment.topLeft,
                      stateMachines: const ['State Machine 1'],
                      onInit: _onRiveInitBear,
                    ),
            ),
            IgnorePointer(
              ignoring: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(30.sw, 0, 1.sw, 7.sh),
                child: showOptions ? allOptions : Container(),
              ),
            ),
            IgnorePointer(
              ignoring: true,
              child: Padding(
                padding: EdgeInsets.fromLTRB(40.sw, 1.sw, 1.sw, 40.sh),
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
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
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
                    timeTextStyle: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                      fontSize: 28.sp,
                    ),
                    descriptionTextStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                    onEnd: () {
                      // if (showOptions == true && overPlayed == false) {
                      //   playOver();
                      //   overPlayed = true;
                      // }
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
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OverflowBar(
                    alignment: MainAxisAlignment.end,
                    spacing: 8.0,
                    overflowSpacing: 8.0,
                    children: <Widget>[
                      TextButton(
                        child: const Text('5 sec'),
                        onPressed: () {
                          setState(() {
                            _selectedOptionsOne = List<bool>.filled(1, false);
                            _selectedOptionsTwo = List<bool>.filled(2, false);
                            _selectedOptionsFour = List<bool>.filled(4, false);
                            _selectedOptionsSix = List<bool>.filled(6, false);

                            timeOutTimerSeconds = 5;
                            _startAction();
                          });
                        },
                      ),
                      TextButton(
                        child: const Text('30 sec'),
                        onPressed: () {
                          setState(() {
                            _selectedOptionsOne = List<bool>.filled(1, false);
                            _selectedOptionsTwo = List<bool>.filled(2, false);
                            _selectedOptionsFour = List<bool>.filled(4, false);
                            _selectedOptionsSix = List<bool>.filled(6, false);

                            timeOutTimerSeconds = 30;
                            _startAction();
                          });
                        },
                      ),
                      TextButton(
                        child: const Text('35 sec'),
                        onPressed: () {
                          setState(() {
                            _selectedOptionsOne = List<bool>.filled(1, false);
                            _selectedOptionsTwo = List<bool>.filled(2, false);
                            _selectedOptionsFour = List<bool>.filled(4, false);
                            _selectedOptionsSix = List<bool>.filled(6, false);

                            timeOutTimerSeconds = 35;
                            _startAction();
                          });
                        },
                      ),
                      TextButton(
                        child: const Text('60 sec'),
                        onPressed: () {
                          setState(() {
                            _selectedOptionsOne = List<bool>.filled(1, false);
                            _selectedOptionsTwo = List<bool>.filled(2, false);
                            _selectedOptionsFour = List<bool>.filled(4, false);
                            _selectedOptionsSix = List<bool>.filled(6, false);

                            timeOutTimerSeconds = 60;
                            _startAction();
                          });
                        },
                      ),
                      SizedBox(
                        width: 200,
                        height: 20,
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 25,
                            inactiveTrackColor:
                                Theme.of(context).colorScheme.tertiaryContainer,
                          ),
                          child: Stack(children: [
                            Slider(
                              label: bgAudioLevel.toString(),
                              value: bgAudioLevel,
                              onChanged: (value) {
                                setState(() {
                                  bgAudioLevel = value;
                                  backgroundPlay.setVolume(bgAudioLevel);
                                  // backgroundPlay.resume();
                                });
                              },
                            ),
                            Center(
                              child: Text('${(bgAudioLevel * 100).round()}',
                                  style: TextStyle(
                                    color: bgAudioLevel > 0.5
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onInverseSurface
                                        : Theme.of(context)
                                            .colorScheme
                                            .onTertiaryContainer,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10.sp,
                                  )),
                            )
                          ]),
                        ),
                      ),
                      // TextButton(
                      //   child: const Text('Start'),
                      //   onPressed: () {
                      //     _startAction();
                      //   },
                      // ),

                      TextButton(
                        child: const Text('50-50'),
                        onPressed: () {
                          if (opts.length == 4 && showOptions == true) {
                            playFiftyfifty();
                            setState(() {
                              _selectedOptionsOne = List<bool>.filled(1, false);
                              _selectedOptionsTwo = List<bool>.filled(2, false);
                              _selectedOptionsFour =
                                  List<bool>.filled(4, false);
                              _selectedOptionsSix = List<bool>.filled(6, false);

                              ftft = getRandomEntriesFiftyFifty(opts);
                              fiftyfifty = true;
                            });
                          }
                        },
                      ),
                      // TextButton(
                      //   child: const Text('Hide'),
                      //   onPressed: () {
                      //     setState(() {
                      //       _themeToggled!.change(false);
                      //       showOptions = false;
                      //     });
                      //   },
                      // ),
                      // TextButton(
                      //   child: const Text('Show'),
                      //   onPressed: () {
                      //     setState(() {
                      //       _themeToggled!.change(true);
                      //       showOptions = true;
                      //     });
                      //   },
                      // ),
                      Switch(
                        value: showOptions,
                        onChanged: (value) {
                          setState(() {
                            _themeToggled!.change(true);

                            _selectedOptionsOne = List<bool>.filled(1, false);
                            _selectedOptionsTwo = List<bool>.filled(2, false);
                            _selectedOptionsFour = List<bool>.filled(4, false);
                            _selectedOptionsSix = List<bool>.filled(6, false);

                            showOptions = value;
                          });
                        },
                      ),
                      TextButton(
                        child: const Text('Prev'),
                        onPressed: () {
                          setState(() {
                            _isFireworks!.change(false);
                            _themeToggled!.change(true);

                            _selectedOptionsOne = List<bool>.filled(1, false);
                            _selectedOptionsTwo = List<bool>.filled(2, false);
                            _selectedOptionsFour = List<bool>.filled(4, false);
                            _selectedOptionsSix = List<bool>.filled(6, false);

                            if (selectedQuestionIndex > 0) {
                              selectedQuestionIndex = selectedQuestionIndex - 1;
                            }
                          });
                        },
                      ),
                      TextButton(
                        child: const Text('Next'),
                        onPressed: () {
                          setState(() {
                            _isFireworks!.change(false);
                            _themeToggled!.change(true);

                            _selectedOptionsOne = List<bool>.filled(1, false);
                            _selectedOptionsTwo = List<bool>.filled(2, false);
                            _selectedOptionsFour = List<bool>.filled(4, false);
                            _selectedOptionsSix = List<bool>.filled(6, false);
                            if (selectedQuestionIndex <
                                questionSets.length - 1) {
                              selectedQuestionIndex = selectedQuestionIndex + 1;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
