import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

const urlRequest = "https://api.hgbrasil.com/finance/quotations?key=a2913607";

void main() async {
  runApp(MaterialApp(
    home: Home(),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(urlRequest);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();

  double dollarValue;
  double euroValue;

  void _dollarChanged(String text) {
    if (text.isEmpty) {
      _clearAllFields();
      return;
    } else {
      double dollar = double.parse(text);
      realController.text = (dollar * dollarValue).toStringAsFixed(2);
      euroController.text =
          (dollar * dollarValue / euroValue).toStringAsFixed(2);
    }
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAllFields();
      return;
    } else {
      double real = double.parse(text);
      dollarController.text = (real / dollarValue).toStringAsFixed(2);
      euroController.text = (real / euroValue).toStringAsFixed(2);
    }
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAllFields();
      return;
    } else {
      double euro = double.parse(text);
      realController.text = (euro * euroValue).toStringAsFixed(2);
      dollarController.text =
          (euro * euroValue / dollarValue).toStringAsPrecision(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text("\$ Currency Now"),
          backgroundColor: Colors.amber,
          centerTitle: true,
          textTheme:
              TextTheme(title: TextStyle(color: Colors.black, fontSize: 24)),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: FutureBuilder<Map>(
              future: getData(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: Text(
                        "Loading data...",
                        style: TextStyle(color: Colors.amber, fontSize: 22),
                        textAlign: TextAlign.center,
                      ),
                    );
                  default:
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error getting data",
                          style: TextStyle(color: Colors.amber, fontSize: 22),
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else {
                      dollarValue =
                          snapshot.data["results"]["currencies"]["USD"]["buy"];
                      euroValue =
                          snapshot.data["results"]["currencies"]["EUR"]["buy"];
                      return SingleChildScrollView(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Icon(
                              Icons.monetization_on,
                              size: 120,
                              color: Colors.amber,
                            ),
                            buildTextField(
                                "\$ Dollar", dollarController, _dollarChanged),
                            Divider(),
                            buildTextField(
                                "R\$ Real", realController, _realChanged),
                            Divider(),
                            buildTextField(
                                "€ Euro", euroController, _euroChanged),
                          ],
                        ),
                      );
                    }
                }
              }),
        ));
  }

  void _clearAllFields() {
    realController.text = "";
    dollarController.text = "";
    euroController.text = "";
  }
}

Widget buildTextField(
    String currency, TextEditingController controller, Function onChanged) {
  return TextField(
    controller: controller,
    onChanged: onChanged,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    style: TextStyle(color: Colors.amber, fontSize: 24),
    decoration: InputDecoration(
        enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        labelText: currency,
        labelStyle: TextStyle(color: Colors.amber)),
  );
}
