import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart'; // 导入 url_launcher 包

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '良友电台-同行频道',
      theme: ThemeData(
        // 这里配置亮色主题
        useMaterial3: true,
        primarySwatch: Colors.blue,
        focusColor: const Color.fromARGB(255, 109, 110, 0), //焦点选中的颜色
        brightness: Brightness.light,
        inputDecorationTheme: const InputDecorationTheme(
          //floatingLabelBehavior: FloatingLabelBehavior.always, // 设置浮动 一直浮动
          labelStyle: TextStyle(
            color: Colors.blue, // 设置浮动后的颜色
          ),
          border: UnderlineInputBorder(
            borderRadius: BorderRadius.only(), // 设置外框为直角
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue), // 设置获得焦点时的边框颜色为绿色
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 33, 54, 243),
          ),
        ),
      ),
      darkTheme: ThemeData(
        // 这里配置暗黑主题
        useMaterial3: true,
        primarySwatch: Colors.blue,
        focusColor: const Color.fromARGB(255, 109, 110, 0), //焦点选中的颜色
        brightness: Brightness.dark,
        inputDecorationTheme: const InputDecorationTheme(
          //floatingLabelBehavior: FloatingLabelBehavior.always, // 设置浮动 一直浮动
          labelStyle: TextStyle(
            color: Colors.blue, // 设置浮动后的颜色
          ),
          border: UnderlineInputBorder(
            borderRadius: BorderRadius.only(), // 设置外框为直角
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue), // 设置获得焦点时的边框颜色为绿色
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 33, 54, 243),
          ),
        ),
      ),
      themeMode: ThemeMode.system, // 根据系统设置选择主题
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final player = AudioPlayer();
  var source1 = "https://ly729.out.airtime.pro/ly729_a";
  var source2 = "https://c20.radioboss.fm/stream/572";
  var source3 = "https://listen.729ly.net:8001/ly729_a";
  var source4 = "";
  final TextEditingController customController = TextEditingController();
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  bool AutoScreenLock = false; // 播放时候是允许熄屏

  var isPlaying = false;
  String? selectedSource;

  _MyHomePageState() {
    selectedSource = source1; // 默认选中 source1
  }
  @override
  void initState() {
    super.initState();
    initPage();
  }

  Future<void> initPage() async {
    final prefsInstance = await prefs;
    source4 = prefsInstance.getString("source4") ?? "";
    AutoScreenLock = prefsInstance.getBool("preventScreenLock") ?? false;
  }

  @override
  void dispose() {
    super.dispose();
    player.stop(); // 停止播放
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 50,
            ),
            ElevatedButton(
              onPressed: () async {
                if (isPlaying) {
                  setState(() {
                    isPlaying = false;
                  });
                  await _stop(context);
                } else {
                  setState(() {
                    isPlaying = true;
                  });
                  _play(selectedSource!, context);
                }
              },
              child: isPlaying
                  ? const Icon(Icons.pause, size: 200)
                  : const Icon(Icons.play_arrow, size: 200),
            ),
            RadioListTile<String>(
              title: const Text('Source 1'),
              value: source1,
              groupValue: selectedSource,
              onChanged: (String? value) async {
                setState(() {
                  selectedSource = value;
                });
                if (isPlaying) {
                  await _play(selectedSource!, context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Source 2'),
              value: source2,
              groupValue: selectedSource,
              onChanged: (String? value) async {
                setState(() {
                  selectedSource = value;
                });
                if (isPlaying) {
                  await _play(selectedSource!, context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Source 3'),
              value: source3,
              groupValue: selectedSource,
              onChanged: (String? value) async {
                setState(() {
                  selectedSource = value;
                });
                if (isPlaying) {
                  await _play(selectedSource!, context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('自定义'),
              value: source4,
              groupValue: selectedSource,
              onChanged: (String? value) async {
                if (source4 == "") {
                  //对话框提示先配置
                  await showCupertinoDialog(
                    context: context,
                    builder: (context) {
                      return CupertinoAlertDialog(
                        title: const Text('提示'),
                        content: const Text('请先配置自定义源'),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: const Text('确定'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }
                setState(() {
                  selectedSource = value;
                });
                if (isPlaying) {
                  await _play(selectedSource!, context);
                }
              },
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: () async {
                  await showCupertinoDialog(
                    context: context,
                    builder: (context) {
                      return CupertinoAlertDialog(
                        title: const Text('输入自定义源:只支持http/s协议'),
                        content: CupertinoTextField(
                          controller: customController,
                          decoration: const BoxDecoration(
                            color:
                                Color.fromARGB(255, 99, 120, 129), // 设置背景颜色为淡蓝色
                          ),
                        ),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: const Text('确定'),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              //检查 customController.text 是否是一个url地址
                              Uri? uri;
                              try {
                                uri = Uri.parse(customController.text);
                                // ignore: empty_catches
                              } catch (e) {}

                              if (uri == null) {
                                await showCupertinoDialog(
                                  context: context,
                                  builder: (context) {
                                    return CupertinoAlertDialog(
                                      title: const Text('提示'),
                                      content: const Text('地址格式错误'),
                                      actions: <Widget>[
                                        CupertinoDialogAction(
                                          child: const Text('确定'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                                return;
                              }
                              if (customController.text == source1 ||
                                  customController.text == source2 ||
                                  customController.text == source3) {
                                await showCupertinoDialog(
                                  context: context,
                                  builder: (context) {
                                    return CupertinoAlertDialog(
                                      title: const Text('提示'),
                                      content: const Text('和内置地址一样'),
                                      actions: <Widget>[
                                        CupertinoDialogAction(
                                          child: const Text('确定'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                                return;
                              }
                              setState(() {
                                source4 = customController.text;
                                selectedSource = customController.text;
                              });
                              //写入到缓存
                              final prefsInstance = await prefs;
                              prefsInstance.setString("source4", source4);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text("配置自定义源"),
              ),
            ),
            SwitchListTile(
              title: const Text('播放时自动熄屏'),
              value: AutoScreenLock,
              onChanged: (bool value) async {
                setState(() {
                  AutoScreenLock = value;
                });
                if (AutoScreenLock &&
                    (Theme.of(context).platform == TargetPlatform.android ||
                        Theme.of(context).platform == TargetPlatform.iOS)) {
                  Wakelock.disable();
                } else {
                  if ((Theme.of(context).platform == TargetPlatform.android ||
                      Theme.of(context).platform == TargetPlatform.iOS)) {
                    Wakelock.enable();
                  }
                }
                //写入到缓存
                final prefsInstance = await prefs;
                prefsInstance.setBool("preventScreenLock", AutoScreenLock);
              },
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 250,
              child: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    if (isPlaying)
                      const TextSpan(
                        text: "▶",
                        style: TextStyle(
                          color: Color.fromARGB(255, 13, 150, 1),
                        ),
                      ),
                    if (!isPlaying)
                      const TextSpan(
                        text: "〓",
                        style: TextStyle(
                          color: Color.fromARGB(255, 245, 159, 0),
                        ),
                      ),
                    TextSpan(
                      text: "地址:$selectedSource",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 245, 159, 0),
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Clipboard.setData(
                              ClipboardData(text: selectedSource!));
                        },
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const SizedBox(
              width: 250,
              child: Text("自定义源 支持http/https协议，支持m3u8源。",
                  style: TextStyle(
                    color: Color.fromARGB(255, 117, 117, 117),
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
                width: 250,
                child: GestureDetector(
                  onTap: () => _launchURL(
                      url: "https://dev.leiyanhui.com/new/radio-ly/"),
                  child: const Text(
                    "部分源可能被监管者屏蔽，你可能需要加密上网才能使用",
                    style: TextStyle(
                      color: Color.fromARGB(255, 117, 117, 117),
                    ),
                  ),
                )),
            const SizedBox(
              height: 50,
            ),
            SizedBox(
                width: 250,
                child: GestureDetector(
                  onTap: () => _launchURL(
                      url: "https://dev.leiyanhui.com/new/radio-ly/"),
                  child: const Text(
                    "主页: https://dev.leiyanhui.com/",
                    style: TextStyle(
                      color: Color.fromARGB(255, 42, 96, 139),
                    ),
                  ),
                )),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
                width: 250,
                child: GestureDetector(
                  onTap: () => _launchURL(
                      url: "https://github.com/joyanhui/radio_ly/releases"),
                  child: const Text(
                    "检查新版",
                    style: TextStyle(
                      color: Color.fromARGB(255, 42, 96, 139),
                    ),
                  ),
                )),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      )),
    );
  }

  Future _launchURL({required String url}) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url)); // 使用 launchUrl
    } else {}
  }

  Future _stop(BuildContext context) async {
    try {
      await player.stop();
      if (Theme.of(context).platform == TargetPlatform.android ||
          Theme.of(context).platform == TargetPlatform.iOS) {
        Wakelock.disable(); //允许熄屏
      }
    } catch (e) {
      await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('提示'),
            content: Text('停止错误 ${e.toString()}'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('确定'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future _play(String url, BuildContext context) async {
    try {
      if (isPlaying) {
        await player.stop();
      }
      await player.play(UrlSource(selectedSource!));
      if (!AutoScreenLock &&
          (Theme.of(context).platform == TargetPlatform.android ||
              Theme.of(context).platform == TargetPlatform.iOS)) {
        Wakelock.enable(); // 根据设置决定是否禁止熄屏
      }
    } catch (e) {
      await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('提示'),
            content: Text('播放错误 ${e.toString()}'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('确定'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
