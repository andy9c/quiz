import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:rive/rive.dart';
import 'package:responsive_framework/responsive_framework.dart';

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

  // List<Map<String, String>> opts = [
  //   {"val": "A. PHARISSES\nफरीसी", "out": "TRUE"},
  //   {"val": "B. SADDUCEES\nसदूकी", "out": "FALSE"},
  //   {"val": "C. ESSENES\nएसेनेस", "out": "FALSE"},
  //   {"val": "D. ZEALOTS\nजेलोतेस", "out": "FALSE"},
  // ];

  List<String> questions = [
    "ROUND 2\nCHOOSE THE RIGHT ANSWER\nसही जवाब को चुने",
    "1. Which religious group frequently challenges Jesus and engages in debates with Him in the Gospel of Mark? \n\nकौन सा धार्मिक समुह अक्सर येसु को चुनौती देता है और मरकुस के सुसमाचार में उनके साथ वाद​-विवाद करता है ?",
    "2. In Mark 7:24-30, Jesus heals the daughter of a Syrophoenician woman. What  is the woman’s response to Jesus’ analogy about the children and the dogs ? \n\nमरकुस 7:24-30 में, येसु एक सुरुफिनीकी महिला की बेटी को ठीक करता है । बच्चों और कुत्तों के बारे में येसु की उपमा की क्या प्रतिक्रिया है?",
    "3. In Mark 10:17-27, what was the reason the rich young ruler went away sad after speaking to Jesus?\n\nमरकुस 10:17-27 में, क्या कारण था कि अमीर युवा शासक येसु से बात करने के बाद उदास होकर चला गया ?",
    "4. What term does Jesus often use in Mark’s Gospel to refer to Himself, emphasizing His humble and serving nature ?\n\nमरकुस के सुसमाचार में येसु अक्सर स्वयं को सम्बोधित करने के लिए किस शब्द का उपयोग करते हैं, अपने विनम्र और सेवारत स्वभाव पर जोर देने के लिए ?",
    "5. In the original ending of Mark’s Gospel (Mark 16:1-8), how do the women react to the news of Jesus’ resurrection ?\n\nमरकुस के सुसमाचार ( मरकुस 16:1-8) के मूल अंत में, महिलाएं येसु के पुनरुत्थान की खबर पर कैसे प्रतिक्रिया करती हैं ?",
    "6. According to Mark 16:15-18, what commission did Jesus give to His disciples after His resurrection?\n\nमरकुस 16:15-18 के अनुसार, पुनरुत्थान के बाद येसु ने अपने चेलों को क्या आदेश दिया ?",
    "ROUND 3\nBRING OUT THE MEANING\nअर्थ सामने लाओ",
    "1. In the Gospel of Mark, what is the significance of Jesus’ statement, “ The time is fulfilled and the kingdom of God is at hand; repent and believe in the gospel” (Mark 1:15) ?\n\nमरकुस के सुसमाचार में, येसु के इस कथन का क्या महत्व है,” समय पूरा हुआ है, और परमेश्वर का राज्य निकट आ गया है; मन फिराओ और सुसमाचार पर विश्वास करो । (मरकुस 1:15) ?",
    "2. What does the term “Abba” indicate when used by Jesus inMark 14:36 ?\n\nमरकुस 14:36 में येसु द्वारा इस्तेमाल किया गया शब्द ”अब्बा” क्या दर्शाता है ?",
    "3. What is the significance of the title “Son of Man” in the Gospel of Mark ?\n\nमरकुस के सुसमाचार में “मनुष्य का पुत्र“ शीर्षक का क्या महत्व है ?",
    "4. In Mark 10:45 “For the Son of Man came not to be served but to serve, and to give his life a ransom for many”, Jesus describes His mission as : \n\nमरकुस 10:45, “क्योंकि मानव पुत्र भी अपनी सेवा कराने नहीं, बल्कि सेवा करने और बहुतों के उद्धार के लिए अपने प्राण देने आया है” में येसु ने अपने उद्देश्य का वर्णन इस प्रकार किया है :",
    "5. Through Mark 9:37 “‘Whoever welcomes one such child in my name welcomes me, and whoever welcomes me welcomes not me but the one who sent me.’” what did Jesus mean to teach ?\n\nमरकुस 9:37 जो मेरे नाम पर इन बालकों में किसी एक का भी स्वागत करता है, वह मेरा स्वागत करता है और जो मेरा स्वागत करता ह, वह मेरा नहीं, बल्कि उसका स्वागत करता है, जिसने मुझे भेजा है । “ के माध्यम से, येसु क्या सिखाना चाहते थे ?",
    "6. What does Jesus make people understand in Mark 3:35 “‘Whoever does the will of God is my brother and sister and mother.”\n\nमरकुस 3:35 ”जो ईश्वर की इच्छा पूरी करता है, वही है मेरा भाई, मेरी बहन और मेरी माता” में येसु लोगों को क्या समझाते हैं ?",
  ];

  List<List<Map<String, String>>> options = [
    [
      {"val": "A. ", "out": "FALSE"},
      {"val": "B. ", "out": "FALSE"},
      {"val": "C. ", "out": "TRUE"},
      {"val": "D. ", "out": "FALSE"},
    ],
    [
      {"val": "A. PHARISSES\nफरीसी", "out": "TRUE"},
      {"val": "B. SADDUCEES\nसदूकी", "out": "FALSE"},
      {"val": "C. ESSENES\nएसेनेस", "out": "FALSE"},
      {"val": "D. ZEALOTS\nजेलोतेस", "out": "FALSE"},
    ],
    [
      {
        "val":
            "A. She becomes\nangry and leaves\nवह क्रोधित हो जाती\nहै और चली जाती है ।",
        "out": "FALSE"
      },
      {
        "val":
            "B. She agrees and\nhumbly asks for help\nवह सहमत है और\nविनम्रतापूर्वक मदद मांगती है ।",
        "out": "TRUE"
      },
      {
        "val":
            "C. She challenges\nJesus statement\nवह येसु के कथन को\nचुनौती देती है ।",
        "out": "FALSE"
      },
      {"val": "D. She remains\nsilent\nवे चुप रहतीं ", "out": "FALSE"},
    ],
    [
      {
        "val":
            "A. Jesus refused to\nheal his sick father.\nयेसु ने उसके बीमार पिता\nको ठीक करने से\nइंकार कर दिया ।",
        "out": "FALSE"
      },
      {
        "val":
            "B. Jesus criticized\nhis wealth.\nयेसु ने उसके\nधन की आलोचना की ।",
        "out": "FALSE"
      },
      {
        "val":
            "C. Jesus asked him to\nsell all his possessions.\nयेसु ने उससे अपनी सारी संपत्ति\nबेचने को कहा ।",
        "out": "TRUE"
      },
      {
        "val":
            "D. Jesus did not\nrecognize his status.\nयेसु ने उसकी स्थिति\nको नहीं पहचाना ।",
        "out": "FALSE"
      },
    ],
    [
      {"val": "A. Rabbi\nरबी", "out": "FALSE"},
      {"val": "B. Lord\nप्रभु", "out": "FALSE"},
      {"val": "C. Messiah\nमसीहा", "out": "FALSE"},
      {"val": "D. Son of Man\nमनुष्य का पुत्र​", "out": "TRUE"},
    ],
    [
      {
        "val":
            "A. They run away in fear\nand say nothing\nto anyone.\nडर के मारे\nभाग जाते हैं और किसी\nसे कुछ नहीं कहते ।",
        "out": "TRUE"
      },
      {
        "val":
            "B. They tell the\ndisciples and others.\nवे चेलों और अन्य\nलोगों को बताते हैं ।",
        "out": "FALSE"
      },
      {
        "val":
            "C. They doubt the news and\nquestion its authenticity.\nवे इस खबर पर संदेह करते\nहैं और इसकी प्रमाणिकता\nपर सवाल उठाते हैं ।",
        "out": "FALSE"
      },
      {
        "val":
            "D. They remain silent\nand puzzled.\nवे चुप और हैरान\nरहते हैं ।​",
        "out": "FALSE"
      },
    ],
    [
      {
        "val": "A. To baptize\nall nations.\nसभी राष्ट्रों को\nबपतिस्मा देना",
        "out": "FALSE"
      },
      {
        "val":
            "B. To heal the sick and\ncast out demons.\nबीमारों को ठीक करना और\nदुष्टात्माओं को बाहर निकालना ।",
        "out": "TRUE"
      },
      {
        "val": "C. To write down\nHis teachings.\nउनकी शिक्षाओं\nको लिखना ।",
        "out": "FALSE"
      },
      {
        "val":
            "D. To establish a new\nreligious order.\nएक नई धार्मिक\nव्यवस्था की स्थापना करना ।​",
        "out": "FALSE"
      },
    ],
    [
      {"val": "A. ", "out": "FALSE"},
      {"val": "B. ", "out": "FALSE"},
      {"val": "C. ", "out": "FALSE"},
      {"val": "D. ", "out": "FALSE"},
      {"val": "E. ", "out": "FALSE"},
      {"val": "F. ", "out": "FALSE"},
    ],
    [
      {
        "val": "A. Arrival of\nGod’s kingdom\nपरमेश्वर के\nराज्य​ के आगमन",
        "out": "TRUE"
      },
      {
        "val":
            "B. Need for\nreligious rituals\nधार्मिक अनुष्ठानों\nकी आवश्यकता",
        "out": "FALSE"
      },
      {
        "val":
            "C. Warning against\nfalse prophets\nझूठे भविष्यवक्ताओं\nके विरुद्ध चेतावनी",
        "out": "FALSE"
      },
      {"val": "D. ​Call to\nfaith\nविश्वास की\nबुलाहट", "out": "TRUE"},
      {"val": "E. Call to\nrepentance\nपश्चाताप​ की\nबुलाहट", "out": "TRUE"},
      {"val": "F. Good Deeds\nअच्छे कर्म", "out": "FALSE"},
    ],
    [
      {"val": "A. Respect\nसम्मान​", "out": "FALSE"},
      {"val": "B. Affection\nस्नेह", "out": "TRUE"},
      {"val": "C. Father​\nपिता", "out": "TRUE"},
      {"val": "D. Title\nउपाधि", "out": "FALSE"},
      {"val": "E. Familiarity\nअपनापन​", "out": "TRUE"},
      {
        "val": "F. A Hebrew\nexclamation\nइब्रानी विस्मयादिबोधक​",
        "out": "FALSE"
      },
    ],
    [
      {"val": "A. Jesus’\nhumanity\nयेसु की\nमानवता", "out": "TRUE"},
      {
        "val":
            "B. Jesus’ role as\na teacher\nशिक्षक के रुप\nमें येसु की भूमिका",
        "out": "FALSE"
      },
      {"val": "C. Jesus’\nMessianic role\nयेसु की मसीहाई", "out": "TRUE"},
      {"val": "D. Jesus’\ndivinity\nयेसु की दिव्यता", "out": "FALSE"},
      {
        "val": "E. Jesus’ royal\nlineage\nयेसु की\nशाही वंशावली",
        "out": "FALSE"
      },
      {"val": "F. One like us\nहमारे जैसा", "out": "TRUE"},
    ],
    [
      {
        "val":
            "A. To establish a\nnew religious order\nएक नई धार्मिक व्यवस्था\nकी स्थापना करना",
        "out": "FALSE"
      },
      {"val": "B. To sacrifice\nबलिदान करने\nके लिए", "out": "TRUE"},
      {
        "val": "C. To conquer\nRoman Empire\nरोमन साम्राज्य\nको जीतना",
        "out": "FALSE"
      },
      {
        "val": "D. To pay the\nprice for others\nदूसरों के लिए\nकीमत चुकाना",
        "out": "TRUE"
      },
      {"val": "E. To be\nselfless\nनिस्वार्थ होना", "out": "TRUE"},
      {
        "val": "F. To gather a\nlarge following\nएक बड़ा अनुयायी\nइकट्ठा करना",
        "out": "FALSE"
      },
    ],
    [
      {
        "val": "A. The oneness of\nFather and Son\nपिता और पुत्र\nकी एकता",
        "out": "TRUE"
      },
      {"val": "B. To be\nhospitable\nमेहमाननवाज़ होना", "out": "FALSE"},
      {"val": "C. Humility\nविनम्रता", "out": "TRUE"},
      {"val": "D. To give\nshelter\nआश्रय देना", "out": "FALSE"},
      {
        "val": "E. To seek\ntrue greatness\nसच्ची महानता\nकी तलाश करो",
        "out": "TRUE"
      },
      {"val": "F. To love\nchildren\nबच्चों से\nप्यार करना", "out": "FALSE"},
    ],
    [
      {
        "val":
            "A. To stay away\nfrom those not\nfollowing God’s\nwords\nईश्वर की इच्छा पूरा\nनहीं करने वालों\nसे दुर रहना",
        "out": "FALSE"
      },
      {
        "val":
            "B. To strengthen\nthe traditional\nfamily ties\nपारंपरिक पारिवारिक\nसंबंधों को मजबूत करें",
        "out": "FALSE"
      },
      {
        "val": "C. To leave\nyour family\nअपने परिवार\nको छोड़ देना",
        "out": "FALSE"
      },
      {"val": "D. Listen to God\nईश्वर को सुनना", "out": "TRUE"},
      {
        "val": "E. To follow\nGod’s words\nईश्वर की बातों का\nपालन करना",
        "out": "TRUE"
      },
      {
        "val": "F. Jesus’ true\nkindred\nयेसु के सच्चे\nपरिवार जन",
        "out": "TRUE"
      },
    ],
  ];

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
    List<Map<String, String>> opts = options[selectedQuestionIndex];
    // opts.shuffle();

    List<Widget> w = [];
    List<Widget> z = [];

    int count = 0;
    for (Map e in opts) {
      Widget g = Expanded(
        child: ElevatedButton(
          onPressed:
              e.entries.firstWhere((element) => element.key == "out").value ==
                      "TRUE"
                  ? _onHappy
                  : _onAngry,
          child: Text(
            e.entries.firstWhere((element) => element.key == "val").value,
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
                ? opts[count]
                                .entries
                                .firstWhere((element) => element.key == "out")
                                .value ==
                            "TRUE" &&
                        _selectedOptions[count] == true
                    ? Colors.green
                    : Theme.of(context).colorScheme.tertiaryContainer
                : opts[count]
                                .entries
                                .firstWhere((element) => element.key == "out")
                                .value ==
                            "TRUE" &&
                        _selectedOptionsSix[count] == true
                    ? Colors.green
                    : Theme.of(context).colorScheme.tertiaryContainer,
            // border: Border.all(color: Colors.black, width: 1.0),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              e.entries.firstWhere((element) => element.key == "val").value,
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
    }

    Widget t = Padding(
      padding: const EdgeInsets.all(8.0),
      child: ToggleButtons(
        direction: vertical ? Axis.vertical : Axis.horizontal,
        onPressed: (int index) {
          setState(() {
            selectedOptionIndex = index;

            String b = opts[index]
                .entries
                .firstWhere((element) => element.key == "out")
                .value;

            if (z.length == 4) {
              if (_selectedOptions[index] == false) {
                b == "TRUE" ? _onHappy() : _onAngry();
              } else {
                _onIdle();
              }

              _selectedOptions[index] = !_selectedOptions[index];
            } else {
              if (_selectedOptionsSix[index] == false) {
                b == "TRUE" ? _onHappy() : _onAngry();
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
              'assets/rive/grumpy_bear_4_720p.riv',
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
                  questions[selectedQuestionIndex],
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
              items: <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
                  .map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
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
