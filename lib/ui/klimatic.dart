import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../util/utils.dart' as util;

class Klimatic extends StatefulWidget {
  @override
  _KlimaticState createState() => _KlimaticState();
}

class _KlimaticState extends State<Klimatic> {
  String _cityEntered;

  Future _goToNextScreen(BuildContext context) async {
    Map results = await Navigator
        .of(context)
        .push(MaterialPageRoute<Map>(builder: (BuildContext context) {
      return new ChangeCity();
    }));
    if (results != null && results.containsKey('enter')) {
      _cityEntered = results['enter'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Klimatic'),
        backgroundColor: Colors.red,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.menu), onPressed: () => _goToNextScreen(context))
        ],
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.asset(
              'images/umbrella.jpg',
              width: 490.0,
              height: 1200.0,
              fit: BoxFit.fill,
            ),
          ),
          ListView(

            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10.0),
                alignment: Alignment.topRight,
                child: Text(
                    '${_cityEntered == null ? util.defaultCity : _cityEntered}',
                    style: cityStyle()),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0.0, 150.0, 0.0, 0.0),
                alignment: Alignment.center,
                child: Image.asset('images/light_rain.png'),
              ),
              updateTempWidget(_cityEntered),
            ],
          )
        ],
      ),
    );
  }

  Future<Map> getWeather(String apiId, String city) async {
    String apiUrl =
        "http://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiId&units=metric";
    http.Response response = await http.get(apiUrl);
    return json.decode(response.body);
  }

  Widget updateTempWidget(String city) {
    return FutureBuilder(
        future: getWeather(util.apiId, city == null ? util.defaultCity : city),
        builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
          if (snapshot.hasData) {
            Map content = snapshot.data;
            return Container(
              padding: const EdgeInsets.fromLTRB(30.0, 0.0, 0.0, 0.0),
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      '${content['main']['temp'].toString()} C',
                      style: tempStyle(),
                    ),
                    subtitle: ListTile(
                      title: Text(
                        'Humidity: ${content['main']['humidity'].toString()}\n'
                            'Min: ${content['main']['temp_min'].toString()} C\n'
                            'Max: ${content['main']['temp_max']
                            .toString()} C\n',
                        style: extraStyle(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }
}

class ChangeCity extends StatelessWidget {
  var _cityFieldController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("Change city"),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.asset('images/white_snow.png',
                width: 490.0, height: 1200.0, fit: BoxFit.fill),
          ),
          ListView(
            children: <Widget>[
              ListTile(
                title: TextField(
                  controller: _cityFieldController,
                  decoration: InputDecoration(hintText: "Enter a city"),
                  keyboardType: TextInputType.text,
                ),
              ),
              ListTile(
                title: FlatButton(
                    onPressed: () {
                      Navigator
                          .pop(context, {'enter': _cityFieldController.text});
                    },
                    color: Colors.orangeAccent,
                    textColor: Colors.white,
                    child: Text("Get Weather")),
              )
            ],
          )
        ],
      ),
    );
  }
}

TextStyle cityStyle() {
  return TextStyle(
      color: Colors.white, fontSize: 22.9, fontStyle: FontStyle.italic);
}

TextStyle tempStyle() {
  return TextStyle(
      color: Colors.white,
      fontSize: 49.9,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal);
}

TextStyle extraStyle() {
  return TextStyle(
      color: Colors.white70, fontSize: 17.9, fontStyle: FontStyle.normal);
}
