import 'package:flutter/material.dart';
import 'package:loja/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _ruaNumeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
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
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: <Widget>[
                TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(hintText: "Nome completo"),
                    validator: (text) {
                      if (text.isEmpty) return "Nome inválido";
                    }),
                SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(hintText: "Email"),
                    keyboardType: TextInputType.emailAddress,
                    validator: (text) {
                      if (text.isEmpty || !text.contains("@"))
                        return "E-mail invalido";
                    }),
                SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                    controller: _passController,
                    decoration: InputDecoration(hintText: "Senha"),
                    obscureText: true,
                    validator: (text) {
                      if (text.isEmpty || text.length < 6)
                        return "Senha inválida";
                    }),
                SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                    controller: _ruaNumeroController,
                    decoration: InputDecoration(hintText: "Rua, numero"),
                    validator: (text) {
                      if (text.isEmpty) return "Rua inválida";
                    }),
                SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                    controller: _bairroController,
                    decoration: InputDecoration(hintText: "Bairro"),
                    validator: (text) {
                      if (text.isEmpty) return "Bairro inválida";
                    }),
                SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                    controller: _cidadeController,
                    decoration: InputDecoration(hintText: "Cidade"),
                    validator: (text) {
                      if (text.isEmpty) return "Cidade inválida";
                    }),
                SizedBox(
                  height: 16.0,
                ),
                SizedBox(
                  height: 44.0,
                  child: RaisedButton(
                    child: Text(
                      "Criar Conta",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    textColor: Colors.white,
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        Map<String, dynamic> userData = {
                          "name": _nameController.text,
                          "email": _emailController.text,
                          "rua": _ruaNumeroController.text,
                          "bairro": _bairroController.text,
                          "cidade": _cidadeController.text
                        };

                        model.signUp(
                            userData: userData,
                            pass: _passController.text,
                            onSuccess: _onSuccess,
                            onFail: _onFail);
                      }
                      ;
                    },
                  ),
                ),
              ],
            ),
          );
        }));
  }

  void _onSuccess() {
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text("Usuário criado com sucesso!"),
          backgroundColor: Theme.of(context).primaryColor,
          duration: Duration(seconds: 2),
        )
    );
    Future.delayed(Duration(seconds: 2)).then((_){
      Navigator.of(context).pop();
    });
  }

  void _onFail() {
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text("Falha ao criar usuário"),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        )
    );
  }
}
