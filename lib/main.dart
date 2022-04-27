//importando as bibliotecas
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:exemplo54/pages/error_page.dart';
import 'package:exemplo54/pages/loading_page.dart';
import 'package:exemplo54/pages/storage_page.dart';

void main() {
//inicializando o FlutterBiding
  WidgetsFlutterBinding.ensureInitialized();
  //chamando a classe App a baixo
  runApp(App());
}

//criando a classe App
class App extends StatelessWidget {
//inicializando o Firebase, ao chamarmos o _inicializacao
  final Future<FirebaseApp> _inicializacao = Firebase.initializeApp();

  App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //chamando o MaterialApp
    return MaterialApp(
      //e passando os parametros de Titulo do App, Tema, Cor, Brilho, etc...
      title: 'Firebase Storage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        brightness: Brightness.dark,
      ),
      //para o home nos estamos passando um FutureBuilder (parametro q constroi algo no futuro)
      home: FutureBuilder(
        //no future nos chamamos o _INICIALIZACAO q criamos ali em cima (q conecta ao FB)
        future: _inicializacao,
        //no metodo builder nos fazemos algumas verificacoes...
        builder: (context, app) {
          //verificamos SE o FB/INICIALIZACAO carregou corretamente
          if (app.connectionState == ConnectionState.done) {
            //se sim, nos vamos chamar a pagina/classe STOREPAGE
            return const StoragePage();
          }
          //se nao conectou, vamos exibir a ela de erro
          if (app.hasError) return const ErrorPage();
          //enquanto carrega exibimos a tela de carregando
          return const LoadingPage();
        },
      ),
    );
  }
}
