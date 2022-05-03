//codigo rafa

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

  //criando a FUNCAO/METODO de upload... Ela e do tipo FUTURE e vai receber um
  //path/caminho de onde ta (no celular) a imagem q o usuario selecionou acima
  //e q queremos enviar
  static Future<UploadTask> upload(String path) async {
    //aqui nos vamos recuperar o arquivo q foi passado (ou o caminho dele)... Passando
    //o valor para a variavel File
    File file = File(path);
    //agora vamos criar uma referencia/nome da pasta no "storage" onde vamos salvar essas imagens
    try {
      //vamos salvar na pasta IMAGES (pasta q vai ficar no FB STORAGE), e as imagens vao
      //se chamar IMG-_E_A_DATA_E_HORA_ATUAL e o formato .JPG
      String ref = 'images/img-${DateTime.now().toString()}.jpg';
      //chamando a nossa REFENCIA chamada de STORAGE (para fazer a conexao com o FB STORAGE)
      //e assim armazenar... Passando o valor q ta na variavel REF... ou seja o
      //img{data e hora}(nome da img)... E no putFile estamos passando o valor/foto q a armazenado na
      //variavel FILE... Portanto assim conseguimos upar um arquivo para o FB STORAGE
      return FirebaseStorage.instance.ref(ref).putFile(file);
    }
    //caso nao de certo os comandos acima... vai exibir uma EXCEPETION
    //ou seja vai exibir uma mensagem de erro
    on FirebaseException catch (e) {
      throw Exception('Erro no upload: ${e.code}');
    }
  }
}
