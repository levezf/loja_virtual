import 'package:flutter/material.dart';
import 'package:loja_virtual/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Criar Conta"),
          centerTitle: true,
        ),
        body:
            ScopedModelDescendant<UserModel>(builder: (context, child, model) {
          if (model.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: <Widget>[
                  TextFormField(
                    controller: _nomeController,
                    validator: (text) {
                      if (text.isEmpty) {
                        return "Nome inválido";
                      }
                    },
                    decoration: InputDecoration(
                        labelText: "Nome Completo",
                        border: OutlineInputBorder()),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  TextFormField(
                    controller: _emailController,
                    validator: (text) {
                      if (text.isEmpty || !text.contains("@")) {
                        return "E-mail inválido";
                      }
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        labelText: "E-mail", border: OutlineInputBorder()),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  TextFormField(
                    controller: _senhaController,
                    obscureText: true,
                    validator: (text) {
                      if (text.isEmpty || text.length < 6) {
                        return "Senha inválida";
                      }
                    },
                    decoration: InputDecoration(
                        labelText: "Senha", border: OutlineInputBorder()),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  TextFormField(
                    controller: _enderecoController,
                    validator: (text) {
                      if (text.isEmpty) {
                        return "Endereço inválido";
                      }
                    },
                    decoration: InputDecoration(
                        labelText: "Endereço", border: OutlineInputBorder()),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  SizedBox(
                    height: 44.0,
                    child: RaisedButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          Map<String, dynamic> userData = {
                            "name": _nomeController.text,
                            "email": _emailController.text,
                            "endereco": _enderecoController.text,
                          };

                          model.signUp(
                              userData: userData,
                              pass: _senhaController.text,
                              onSucess: _onSucess,
                              onFail: _onFail);
                        }
                      },
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      child: Text(
                        "Criar Conta",
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  )
                ],
              ));
        }));
  }

  void _onFail() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Falha ao criar usuário!"),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 2),
    ));
  }

  void _onSucess() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Usuário criado com sucesso!"),
      backgroundColor: Theme.of(context).primaryColor,
      duration: Duration(seconds: 2),
    ));
    Future.delayed(Duration(seconds: 2)).then((_){
      Navigator.of(context).pop();
    });
  }
}
