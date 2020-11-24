import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

String concatenate(String s, String a){
  return s == null ? a : s + " " + a;
}

class CameraProcessor extends StatefulWidget {
  @override
  _CameraProcessorState createState() => _CameraProcessorState();
}

class _CameraProcessorState extends State<CameraProcessor>{
  //Atributos
  File _image;
  bool _busy = false;
  String _text = "";

  //Metodos para seleccionar una imagen

  //Tomar una foto
  selectFromCamera() async{
    PickedFile selectedImage = await ImagePicker().getImage(source: ImageSource.camera);
    File image = File(selectedImage.path);
    if( image == null ) return;
    setState(() {
      _image = image;
      _busy = true;
    });
    //Llamar al metodo que haga la lectura de la imagen y retorne el texto
    processImage(image);
  }

  //Elegir una imagen de la galería
  selectFromGallery() async{
    PickedFile selectedImage = await ImagePicker().getImage(source: ImageSource.gallery);
    File image = File(selectedImage.path);
    if( image == null ) return;
    setState(() {
      _image = image;
      _busy = true;
    });
    //Llamar al metodo que haga la lectura de la imagen y retorne el texto
    processImage(image);
  }

  //Procesando una imagen
  Future processImage(File image) async{
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);
    final TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
    final VisionText visionText = await textRecognizer.processImage(visionImage);

    var text = "";

    //Extraer la información
    for( TextBlock block in visionText.blocks ){
      // final Rect boundingBox = block.boundingBox;
      // final List<Offset> cornerPoints = block.cornerPoints;
      // //final String text = block.text;
      // final List<RecognizedLanguage> languages = block.recognizedLanguages;

      for( TextLine line in block.lines ){
        for( TextElement element in line.elements ){
          text = concatenate(text, element.text);
        }
      }
      text = concatenate(text, "\n");
      //print(text);
    }

    setState(() {
      _text = text.toLowerCase();
    });

  }


  @override
  Widget build(BuildContext context){

    //Tamaño de la pantalla
    Size size = MediaQuery.of(context).size;
    final height = (size.height*27.8)/100.0;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Home"),
        backgroundColor: Colors.blueAccent,
        // leading: IconButton(
        //   icon: Icon(Icons.menu),
        //   tooltip: "Menu",
        //   onPressed: (){
        //     print("Menu pressed");
        //   },
        // ),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              //color: Color(0xffeeeeee),
              width: size.width,
              margin: EdgeInsets.all(20.0),
              height: size.height/2,
              child: Center(
                child: _busy ? Image.file(_image) : Text("No se ha cargando una imagen para procesar"),
              ),
            ),
            Container(
              color: Color(0xffeeeeee),
              width: size.width,
              margin: EdgeInsets.all(10.0),
              height: height,
              child: _busy ?
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: height
                ),
                child: SelectableText(
                  _text,
                  //cursorColor: Colors.red,
                  showCursor: true,
                  scrollPhysics: BouncingScrollPhysics(),
                  style: TextStyle(fontSize: 20),
                )
              )
              :
              Container(
                constraints: BoxConstraints(maxHeight: height),
                child: SizedBox(
                  height: height-10,
                  child : Text("Aun no se ha generado texto")
                  ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        marginRight: 18,
        marginBottom: 20,
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        // this is ignored if animatedIcon is non null
        // child: Icon(Icons.add),
        visible: true,
        // If true user is forced to close dial manually 
        // by tapping main button and overlay is not rendered.
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        onOpen: () => print('OPENING DIAL'),
        onClose: () => print('DIAL CLOSED'),
        tooltip: 'Speed Dial',
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
            child: Icon(Icons.image),
            label: "Selecciona una imagen de la galería",
            onTap: (){
              print("Picture from gallery!");
              Text(selectFromGallery());
            },
            backgroundColor: Colors.blueAccent
          ),
          SpeedDialChild(
            child: Icon(Icons.add_a_photo),
            label: "Toma una foto",
            onTap: (){
              print("Photo!");
              Text( selectFromCamera() );
            },
            backgroundColor: Colors.blueAccent
          ),
        ],
      ),
    );
  }

}