import 'package:flutter/material.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data'; 
import 'package:exif/exif.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget { 
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState(); 
}

class _MyHomePageState extends State<MyHomePage> { 
 final ImagePicker _picker = ImagePicker();
 final List<String> _datas = []; // Exif情報を格納用

  File? _image;

  Future _openGallery() async { // ギャラリーから画像を取得する
    final xfile = await _picker.pickImage(source: ImageSource.gallery);
    if(xfile == null){
      print("「 xfile == null 」時のエラーハンドリング");
    }
    final file = File(xfile!.path); // XFile → File

    Uint8List buffer = await file.readAsBytes(); // バイナリを取得
    final tags = await readExifFromBytes(buffer); // Exif情報を取得
    // Mapで返されるのでループする
    for (var MapEntry(key: key, value: value) in tags.entries) {
      print('key:$key value:$value'); // デバッグ表示
    }

    setState(() {
      if (xfile != null) {
        _image = File(xfile.path); // XFile → File
        
        // ListにExif情報を格納(2回目以降を考慮し、一旦クリア)
        _datas.clear();
        for (var MapEntry(key: key, value: value) in tags.entries) {
          _datas.add('[$key] $value');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageView = SizedBox(
        width: 200,
        height: 200,
        child: _image == null
            ? const Text("ギャラリーのビュー")
            : Image.file(_image!),
    );

  final list = ListView.builder( // Exif情報を表示するListView
      itemCount: _datas.length,
      itemBuilder: (c, i) => Text(_datas[i]),
    );

    final body = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          imageView,
          Expanded(child: list), // ListViewを配置
          const Text("↑入りきらない場合、スクロール可"),
        ],
      )
    );
      
    final fab = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton( // ギャラリーから画像を取得する
          onPressed: _openGallery,
          child: const Icon(Icons.image),
        ),
      ]
    );

    final sc = Scaffold(
      body: body, // ボディー   
      floatingActionButton: fab,     
    );
    return SafeArea(
      child: sc,
    );
  }
}