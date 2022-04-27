//codigo rafa

import 'package:cloud_firestore/cloud_firestore.dart';

//criando a classe BANCO
class Fb {
//dentro dessa classe vamos criar uma variavel do tipo STRING q se chama NOME
  final String link;
  final String nome;

  //ao ser CHAMADA a classe BANCO espera q seja atribuido algum VALOR a variavel NOME
  Fb(this.link, this.nome);
  //assim q a classe BANCO é iniciada, nos criamos um COLLECTIONREFERENCE
  //desta forma ao digitarmos USERS nos vamos automaticamente fazer uma
  //conexao ao FIREBASE diretamente na COLECAO USERS... Obs o nome da COLECAO poderia
  //ser outro...
  CollectionReference cadastro =
      FirebaseFirestore.instance.collection('cadastro');

  //como vamos ADD dados a um servidor q esta na internet FIREBASE, e esse processo
  //pode demorar um pouquinho, entao para isso nos iniciamos a classe addUser
  //sendo do uma classe do tipo FUTURE... Apos isso criamos a classe addUser
  //e nela passamos,
  //o mesmo VALOR/VARIAVEL q foi passada para a classe BANCO acima...
  //sendo o valor da variavel NOME... Valor esse q foi preenchido na classe PAGINA1()
  //q é o valor q o usuario digitou no aplicativo em "INSIRA O NOME"
  //de forma ASYNC/Assincrona... significa q o APP pode carregar/enviar/fazer outras coisas
  //enquanto aguarda os dados serem ADD no servidor do FIREBASE
  Future<void> addCadastro(String link, String nome) async {
    //chamando a classe COLECTION REFERENCE USERS... Mas usando o comando
    //AWAIT, pois desta forma o APP sabe q irá DEMORAR um POUQUINHO até realizar a conexao
    //demora um pouquinho pq tem q se conectar ao servidor o FireBase

    var abc = link;
    return await cadastro
        //usando o comando .ADD para adicionar uma CHAVE/VALOR a um DOC de nome aleartorio
        //sendo assim criamos um DOC com um nome aleartorio e a ele adicionamos a CHAVE
        //de nome FULL_NAME e atribuimos a essa chave o VALOR q esta na VARIAVEL NOME
        .add({
          'link_imagem': link, //John Doe
          'nome_pessoa': nome,
        })
        //caso seja ADD vai exibir a mensagem "user added" no CONSOLE no VisualStudio
        .then((value) => print("cadastro ok"))
        //caso de erro, vai exibir a mensagem "failed to add user" no CONSOLE do VISUALSTUDIO
        .catchError((error) => print("falha ao add cadastro $error"));
  }
}
