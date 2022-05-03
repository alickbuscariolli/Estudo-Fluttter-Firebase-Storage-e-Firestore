//importando as bibiliotecas
import 'dart:io';

import 'package:exemplo54/pages/firebase.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({Key? key}) : super(key: key);

  @override
  _StoragePageState createState() => _StoragePageState();
}

//classe para fazer o upload e visualizacao da imagem para o o Storage
class _StoragePageState extends State<StoragePage> {
//declarando a instancia do nosso Storage... q iremos chamar apenas por STORAGE
  final FirebaseStorage storage = FirebaseStorage.instance;

//declarando a Collection Reference USERS para se conectar ao FB FIRESTORE
  final Stream<QuerySnapshot> cadastro =
      FirebaseFirestore.instance.collection('cadastro').snapshots();

  //declarando LISTAS e VARIAVEIS
  //
  //lista de referencias ou seja do NOME da imagem q ficou salvo no STORAGE
  List<Reference> refs = [];
  //lista das URLS de download/acesso as imgs
  List<String> arquivos = [];
//o bool a baixo serve para SE tive TRUE mostrar um LOADING... carregar a PAG de LOADING
  bool loading = true;
  //variavel booleana upload começa com false... pq assim q abre o app nos nao estamos upando
  bool uploading = false;
//variavel TOTAL vai nos ajudar a dizer quantos % da foto ja foi enviado
  double total = 0;
  //atribuindo um valor "aleartorio, no caso RJ" a variavel NOME (aparentemente e obrigatorio)
  //iniciar com um valor... na var NOME sera colocado o LINK da IMG para enviarmos para o
  //FIRESTORE
  String link = '';

  TextEditingController nome = TextEditingController();

//
//metodo para recuperar as imagens da galeria... de forma assincrona
//dai ele vai retonar um future q e XFile... Tem uma interrogacao pq o usuario PD NAO
//selecionar uma imagem na geleria do celular
  Future<XFile?> getImage() async {
    //criando uma instancia do ImagePicker
    final ImagePicker _picker = ImagePicker();
//IMAGE recebe a imagem q o usuario selecionou na GALERIA
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//retornando a imagem q o usuario selecionou
    return image;
  }

//funcao/metodo q sera chamado quando apertamos no BOTAO de UPLOAD q fica na TOPBAR do APP
//esse metodo serve para verificar SE ja temos uma IMG selecionada para UPAR, caso SIM enviar
//ela para o FB STORAGE... Caso nao abrir a galeria do celular para escolher a IMG
  pickAndUploadImage() async {
    //a variavel FILE vai receber um XFILE... Esse XFILE vai ser o RETURN da funcao GETIMAGE
    //ou seja a IMAGEM q o usuario selecionou da galeria na funcao getImage...
    XFile? file = await getImage();
    //verificando se esse FILE e diferente de NULL (ou seja estamos verificando se nos ja
    //escolhemos alguma imagem na galeria do celular...)
    if (file != null) {
      //conforme pedido acima... Nos estamos chamando o METODO UploadTask e para ele
      //e para o atributo/variavel UPLOAD nos vamos passar a IMAGEM q ta na variavel FILE
      //e o caminho onde ela vai ficar no STORAGE com o .path
      UploadTask task = await Fb.upload(file.path);

//agora vamos monitorar a TASK q foi criada acima... Para sabermos se ela esta em
//RUNNING ou seja esta em execução... Portando fazendo UP de IMG
      task.snapshotEvents.listen((TaskSnapshot snapshot) async {
        //vamos verificar se o ESTADO da TASK e running ou seja... em andamento
        if (snapshot.state == TaskState.running) {
          //vamos alterar o ESTADO/VALOR
          setState(() {
            // da variavel UPLOADING para true
            uploading = true;
            //a variavel TOTAL, vai receber (a PORCENTAGEM % de quantos (KB) da foto q ja foi
            //enviada )
            total = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          });
        }
        //se nao se, o snapshot state for TaskState Success entao
        else if (snapshot.state == TaskState.success) {
          //a LISTA arquivos vai receber o LINK para acessar a IMG dessa REFERENCIA/IMG
          arquivos.add(await snapshot.ref.getDownloadURL());
          //a LISTA REFS vai receber a REFERENCIA/LINK  dessa IMG
          refs.add(snapshot.ref);
          //EXTREMAMENTE IMPORTANTE
          //estamos acessando a LISTA ARQUIVOS (onde tem as URL) das IMG upadas para o STORAGE
          //e com o .LAST, estamos pegando a ULTIMA URL add a essa LISTA...
          //e estamos passando essa URL para a variavel NOME
          link = arquivos.last.toString();
          //passando o valor q ta na VAR NOME para a CLASSE FB
          //ou seja a classe FB vai pegar a URL da IMG q ta armazenada na var NOME... e vai
          //criar um DOC no FIRESTORE e armazenar esse valor
          Fb(link, nome.text).addCadastro(link, nome.text);
          //vamos alterar o valor da variavel uploading para false
          //pois se chegamos ate aqui significa q ja fizemos o UP
          setState(() => uploading = false);
        }
      });
    }
  }

//criando um INITSTATE
  @override
  void initState() {
    super.initState();
    //q irar chamar o METODO/FUNCAO
    //LOADIMAGES
    loadImages();
  }

//criando o METODO LOAD IMAGES
  loadImages() async {
    //passando para a LISTA REFS/REFERENCIAS(nome das IMG)
    //tudo(listAll) q ta dentro da pasta IMAGES do
    //storage
    refs = (await storage.ref('images').listAll()).items;
    //pegando REF(referencia) por REF(referencia)
    //dentro da lista REFS (referenciaSSSSSS)... Ou seja pegando NOME por NOME das IMG
    //dentro da pasta IMAGES
    for (var ref in refs) {
      //a LISTA ARQUIVOS vai receber o URL de cada REFERENCIA(REF)/Cada NOME de IMG
      arquivos.add(await ref.getDownloadURL());
    }
//alterando o ESTADO da variavel LOADING para FALSE
    setState(() => loading = false);
  }

//
//metodo de deletar Imagens...
//esse metodo vai receber um ID/index, para identificar
//qual a IMG q queremos deletar...
  deleteImage(int index) async {
    //acessando o STORAGE e usando o comando REF passamos a REFS(referencia/NOME)
    //da IMG q queremos deletar, e passamos o INDEX/ID dessa IMG
    //e usamos o comando delete para remover do storage
    await storage.ref(refs[index].fullPath).delete();
    arquivos.removeAt(index);
    refs.removeAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //o titulo do app vai modificar conforme ESTAR OU NAO fazendo o UP de uma imagem

        title:
            //verificando se a variavel UPLOADING ela esta TRUE ou FALSE
            uploading
                //se a variavel UPLOADING for TRUE, entao estamos enviando uma FOTO
                //e entao vamos chamar a variavel TOTAL e mostrar quantos % da
                //foto ja foi enviado
                ? Text('${total.round()}% enviado')
                //caso a variavel UPLOADING for FALSE
                //entao vamos exibir a mensagem a baixo
                : const Text('Firebase Storage'),

        actions: [
          //caso a VARIAVEL UPLOADING for TRUE
          uploading
              //de forma resumida... Vamos colocar no centro da tela um
              //CIRCULO DE INDICADOR DE PROGRESSO... Aquele circulo q fica girando
              ? const Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: Center(
                    child: SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              //CASO a variavel UPLOADING for FALSE, vamos exibir um ICONE com simbolo
              //de UPLOAD
              : IconButton(
                  icon: const Icon(Icons.upload),
                  //ao ser apertado o botao, vai ser chamada a funcao/metodo
                  //pickAndUploadImage
                  onPressed: pickAndUploadImage,
                )
        ],
        elevation: 0,
      ),
      //SE a variavel LOADING for TRUE
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              //ajustes de onde vai ficar o circulo de progresso
              //e tamanho
              padding: const EdgeInsets.all(24.0),
              //se a LISTA ARQUIVOS (lista com as URL das IMG) estiver VAZIA/isEmpety
              child: arquivos.isEmpty
                  ? //criamos uma COLUMN e um local para podermos cadastrar a IMAGEM
                  //e um NOME
                  Column(
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.text,
                          decoration:
                              InputDecoration(labelText: 'digite o seu nome'),
                          textAlign: TextAlign.center,
                          controller: nome,
                        ),
                        GestureDetector(
                          onTap: () {
                            //chamando o metodo pickAndUploadImage
                            pickAndUploadImage();
                            //passando o valor das variaveis para o Firestore
                            Fb(link, nome.text).addCadastro(link, nome.text);
                          },
                          child: Container(
                              height: 200,
                              width: 200,
                              color: Colors.orange,
                              child: Text('cadastrar')),
                        )
                      ],
                    )
                  :
                  //EXTREMAMENTE IMPORTANTE... com o StreamBuilder a baixo... Nos estamos
                  //iniciando a CONEXAO COM o FIRESTORE agora.... (NAO o STORAGE)...
                  //e vamos pegar os LINK para IMG q estao salvos nos DOC do FIRESTORE...
                  //e carregar essas IMG

                  //nos vamos retornar um StreamBuilder(metodo q fica escutando algo ex: link
                  // ou banco de dados, etc... e quando ele o link se mexe o Builder constroi algo)
                  // é como se sempre q houver algo alterado no FB ele vai construi um novo
                  //ListTittle ou container etc...
                  StreamBuilder<QuerySnapshot>(
                      //dizendo q o STREAM q sera o q sera monitorado sera o nosso CADASTROSTREAM
                      //q é a conexao q temos com a COLLECTION CADASTRO NO FIREBASE
                      stream: cadastro,
                      //e aqui vamos dizer o q iremos construir
                      // de forma ASSINCRONA/ASYNC (nao sequencial), estamos dizendo q vamos
                      //q vamos passar um SnapShot<querySnapshot> e entao nos chamamos o
                      //.snapshot la de cima EU ACHO
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        //se houver algum erro... tipo sem internet etc... exibe a mensagem
                        if (snapshot.hasError) {
                          return Text("ops, erro");
                        }
                        //se a conexao estiver ok... exibe a mensagem
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text("Loading");
                        }
                        //apos ocorre ok a conexao acima... iremos retornar um ListView
                        return ListView(
                          //ACHO Q se houver DADOS no SNAPSHOT nos vamos fazer um MAP (chave:valor)
                          //dos dados q estao dentro dos document
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            //fazendo um MAP com CHAVE:VALOR... de um lado temos a
                            //CHAVE do documento tipo 'NOME e LINK_IMAGEM' e do outro lado temos o
                            //VALOR do tipo DYNAMIC pois o 'NOME e LINK_IMAGEM' pode ser um NOME, NUMERO, etc...
                            //
                            //data a baixo vai receber os valores dos documents no formato de MAP
                            //{chave}: valor
                            Map<String, dynamic> data =
                                //passando os valores do document no formato String, Dynamic para o MAP
                                //de cada DOC do firebase
                                document.data()! as Map<String, dynamic>;
                            //entao iremos retornar um material
                            return Material(
                              //aqui colocamos um COLUMN e com ele vamos
                              //pode cadastrar o NOME e add uma FOTO...
                              //tambem ira exibir o NOME q cadastremos e a FOTO
                              //q nos adicionemos
                              child: Column(
                                children: [
                                  TextFormField(
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                        labelText: 'digite o seu nome'),
                                    textAlign: TextAlign.center,
                                    controller: nome,
                                  ),
                                  Container(
                                      height: 200,
                                      width: 200,
                                      color: Colors.blue,
                                      child:
                                          Image.network(data['link_imagem'])),
                                  Container(
                                    height: 200,
                                    width: 200,
                                    color: Colors.green,
                                    child: Text(data['nome_pessoa']),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      pickAndUploadImage();
                                      Fb(link, nome.text)
                                          .addCadastro(link, nome.text);
                                    },
                                    child: Container(
                                        height: 200,
                                        width: 200,
                                        color: Colors.orange,
                                        child: Text('cadastrar')),
                                  )
                                ],
                              ),
                              //),
                            );
                          }).toList(),
                        );
                      },
                    ),
            ),
    );
  }
}
