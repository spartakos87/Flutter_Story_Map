import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AboutPage extends StatefulWidget {
  final String title;
  final String story;
  final String url;

  const AboutPage({Key key, this.title, this.story, this.url}) : super(key: key);

  @override
  _AboutPageState createState() => new _AboutPageState(this.title, this.story, this.url);
}

void _navHome(BuildContext context) {
  Navigator.pop(context);
}

class _AboutPageState extends State<AboutPage> {
final String title;
final String story;
final String url;




  _AboutPageState(this.title, this.story, this.url);
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
//        title: new Text('About'),
        title: new Text(title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new TextField(
        decoration: InputDecoration(
//            border: InputBorder.none,
            hintText: story
        ),
      ),
        new RaisedButton(
              onPressed: () => _navHome(context) ,
              child: new Text('Back'),

              ),

            new RaisedButton(
              onPressed: () =>   Navigator.push(
//        Go to the screen which we view the image
                  context,
                  new MaterialPageRoute(builder: (context) => new ImageView(image_url: url,))),
              child: new Text('Image View'),

            ),
            new RaisedButton(
              onPressed: () =>  Delete(title),
              child: new Text('Delete'),

            )
          ],
        ),
      ),

    );
  }
}


class ImageView extends StatelessWidget {
//  In this screen we view the image of the story
  final String image_url;

  const ImageView({Key key, this.image_url}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Image"),
      ),
      body: Center(
        child: Image.network(image_url)
      ),
    );
  }
}

void Delete(String titlos){
//  Take some time to delete it
      Firestore.instance
          .collection('Stories')
          .where("title", isEqualTo: titlos)
          .snapshots()
          .listen((data) => data.documents.forEach((doc) =>

          Firestore.instance.collection("Stories").document(doc.documentID).delete()
      ));



}
