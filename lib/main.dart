import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';


void main() {
  runApp(MyApp());
}

class Country{
  final String name;
  final String capital;
  final String subregion;
  final int population;

  Country({this.name, this.capital, this.subregion, this.population});


  factory Country.fromJson(Map<String, dynamic> json){
    return Country(
      name:  json['name'],
      capital:  json['capital'],
      subregion:  json['subregion'],
      population:   json['population'],
    );
  }

}

Future<List<Country>> fetchCountry() async{
  final response = await http.get('https://restcountries.eu/rest/v2/lang/es');

  var countries=List<Country>();

  if(response.statusCode == 200){
    var countriesJson = json.decode(response.body);
    for(var countryJson in countriesJson){
      countries.add(Country.fromJson(countryJson));
    }
    return countries;
  } else {
    throw Exception('No se pueden cargar los países');
  }

}




class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  File _imageFile;
  void _pickImageFromGalley() async{
    var picture = await ImagePicker().getImage(
        source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      _imageFile = File(picture.path);
    });
  }

  File _imageFileCamera;

  void _openCamera() async{
    var picture = await ImagePicker().getImage(
        source: ImageSource.camera);
    if(picture != null && picture.path != null){
      GallerySaver.saveImage(picture.path);
    }
    setState(() {
      _imageFile = File(picture.path);
    });
  }

  File _videoFile;
  VideoPlayerController _controller;

  void _pickVideoFromGalley() async{
    var video = await ImagePicker().getVideo(
        source: ImageSource.gallery);
    _videoFile = File(video.path);
    _controller = VideoPlayerController.file(_videoFile)
      ..initialize().then((_){
        setState(() {});
        _controller.play();
      });

  }

  File _videoFileCamera;

  void _openVideo() async{
    var video = await ImagePicker().getVideo(
        source: ImageSource.camera);
    if(video != null && video.path != null){
      GallerySaver.saveVideo(video.path);
    }
    setState(() {
      _videoFileCamera = File(video.path);
    });
  }

  List<Country> _countries=List<Country>();
  List<Country> _countriesForDisplay=List<Country>();

  @override
  void initState(){
    fetchCountry().then((value) {
      setState(() {
        _countries.addAll(value);
        _countriesForDisplay = _countries;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: ListView(
              padding: const EdgeInsets.all(8), children: <Widget>[
            if(_imageFile !=null)
              Image.file(_imageFile)
            else
              Text("Elegir una Imagen para seleccionar una Imagen"),
            Padding(
              padding: const EdgeInsets.fromLTRB(60,  8, 60, 8),
              child: RaisedButton(
                  onPressed: (){
                    _pickImageFromGalley();
                  },
                  color: Colors.red,
                  child: Text("Elige una imagen de galeria")),
            ),
            Text("Tomar una foto para abrir la Camara", style: TextStyle(fontSize: 16),),

            Padding(
              padding: const EdgeInsets.fromLTRB(60,  8, 60, 8),
              child: RaisedButton(
                  onPressed: (){
                    _openCamera();
                  },
                  color: Colors.orange,
                  child: Text("Tomar foto")),
            ),

            if(_videoFile !=null)
              _controller.value.initialized
                  ? AspectRatio(aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
                  :Container()
            else
              Text("Elegir un video para seleccionar un video",
                style: TextStyle(fontSize: 16),),

            Padding(
              padding: const EdgeInsets.fromLTRB(60,  8, 60, 8),
              child: RaisedButton(
                  onPressed: (){
                    _pickVideoFromGalley();
                  },
                  color: Colors.yellowAccent,
                  child: Text("Eligir un video de galeria")),
            ),

            Text("Grabar video para abrir la Camara", style: TextStyle(fontSize: 16),),
            Padding(
              padding: const EdgeInsets.fromLTRB(60,  8, 60, 8),
              child: RaisedButton(
                  onPressed: (){
                    _openVideo();
                  },
                  color: Colors.blue,
                  child: Text("Grabar Video")),
            ),
            ListView.builder(
              itemBuilder: (context, index){
                return index==0 ? _searchBar() : _listItem(index-1);

              },
              itemCount:_countriesForDisplay.length+1,
            ),


          ]

          )
      ),


    );
  }

  _searchBar(){
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        decoration: InputDecoration(hintText: 'Buscar'),
        onChanged: (text){
          text = text.toLowerCase();
          setState(() {
            _countriesForDisplay=_countries.where((country){
              var contName = country.name.toLowerCase();
              return contName.contains(text);
            }).toList();
          });
        },
      ),
    );
  }

  _listItem(index){
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(_countriesForDisplay[index].name,
              style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
            Text(_countriesForDisplay[index].capital,
              style: TextStyle(fontSize: 20, color: Colors.white),),
            Text(_countriesForDisplay[index].subregion,
              style: TextStyle(fontSize: 20, color: Colors.white),),
            Text(_countriesForDisplay[index].population.toString(),
              style: TextStyle(fontSize: 20, color: Colors.white),),

          ],
        ),
      ),

    );
  }

}
