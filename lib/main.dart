import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission/permission.dart';
import 'package:wave_generator/wave_generator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AudioCache audioCache = AudioCache();
  AudioPlayer advancedPlayer = AudioPlayer();
  String _path = "";

  @override
  void initState() {
    test();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Scaffold(
            appBar: AppBar(),
            body: Center(
              child: GestureDetector(
                  onTap: () => _play(_path),
                  child: Icon(
                    Icons.play_circle_filled,
                    color: Colors.blue,
                    size: 100,
                  )),
            )));
  }

  void test() async {
    await Permission.requestPermissions([PermissionName.Storage]);
    var generator = WaveGenerator(
        /* sample rate */
        22000,
        BitDepth.Depth8bit);

    var note = Note(
        /* frequency */
        200,
        /* msDuration */ 3000,
        /* waveform */ Waveform.Triangle,
        /* volume */ 0.5);

    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    String path = "${appDocDirectory.path}/output.wav";
    setState(() {
      _path = path;
    });
    var file = new File(path);

    List<int> bytes = List<int>();
    await for (int byte in generator.generate(note)) {
      bytes.add(byte);
    }

    await file.writeAsBytes(bytes, mode: FileMode.write);

    _play(path);
  }

  void _play(String path) {
    advancedPlayer.play(path, isLocal: true);
  }
}
