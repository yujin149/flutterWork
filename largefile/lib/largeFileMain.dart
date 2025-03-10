import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LargeFileMain extends StatefulWidget {
  State<StatefulWidget> createState() => _LargeFileMain();
}

class _LargeFileMain extends State<LargeFileMain> {
  //내려받을 이미지 주소
  final imgUrl =
      'https://images.pexels.com/photos/240040/pexels-photo-240040.jpeg'
      '?auto=compress';
  bool downloading = false; //지금 내려받는 중인지 확인하는 변수
  var progressString = ""; //현재 얼마나 내려받았는지 표시하는 변수
  String file = ""; //내려받은 파일

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Large File Example')),
      body: Center(
        child:
            downloading
                ? Container(
                  height: 120.0,
                  width: 200.0,
                  child: Card(
                    color: Colors.black,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(),
                        SizedBox(height: 20.0),
                        Text(
                          'Downloading File : $progressString',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                )
                : //downloading 이 false일 때 코드는 다음 단계에서 작성함
                FutureBuilder(
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        print('none');
                        return Text('데이터 없음');
                      case ConnectionState.waiting:
                        print('waiting');
                        return CircularProgressIndicator();
                      case ConnectionState.active:
                        print('active');
                        return CircularProgressIndicator();
                      case ConnectionState.done:
                        print('done');
                        if (snapshot.hasData) {
                          return snapshot.data as Widget;
                        }
                    }
                    print('end process');
                    return Text('데이터 없음');
                  },
                  future: downloadWidget(file!),
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          downloadFile();
        },
        child: Icon(Icons.file_download),
      ),
    );
  }

  Future<void> downloadFile() async {
    Dio dio = Dio();
    try {
      var dir = await getApplicationDocumentsDirectory();
      //                  src         desc      기능
      await dio.download(
        imgUrl,
        '${dir.path}/myimage.jpg',
        onReceiveProgress: (rec, total) {
          print('Rec: $rec, Total: $total');
          file = '${dir.path}/myimage.jpg';
          setState(() {
            downloading = true;
            progressString =
                ((rec / total) * 100).toStringAsFixed(0) + '%';
          });
        },
      );
    } catch (e) {
      print(e);
    }
    setState(() {
      downloading = false;
      progressString = 'Completed';
    });
    print('Download completed');
  }

  Future<Widget> downloadWidget(String filePath) async {
    File file = File(filePath);
    bool exist = await file.exists();
    new FileImage(file).evict(); //캐시 초기화 하기
    //만약 이미지가 존재하면 실행
    if (exist) {
      // 이미지 출력
      return Center(
        child: Column(children: <Widget>[Image.file(file)]),
      );
    } else {
      return Text('No Date');
    }
  }
}
