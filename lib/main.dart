import 'dart:convert';
import 'dart:io' show Directory, File, FileMode, Process;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config/appConfig.dart';
import 'config/configuracoes_screen.dart';
import 'package:intl/intl.dart';

String caminhoProjetoFlutter = Directory.current.path;
String executavelGo = 'go.exe';
Process? apiProcess;
void main() async {
  Directory.current = Directory('$caminhoProjetoFlutter');
  await AppConfig.initialize();
  runApp(MyApp());
}

@override
void dispose() {
  // Encerre o processo da API ao fechar o aplicativo
  apiProcess?.kill();
  //super.dispose();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController dataInicialController = TextEditingController();
  final TextEditingController dataFinalController = TextEditingController();

  bool terceiroSelecionado = false;
  bool propriaSelecionado = false;
  bool nfeSelecionado = false;
  bool nfceSelecionado = false;
  bool carregando = false;
  Future<void> _selecionarDataInicial(BuildContext context) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (dataSelecionada != null && dataSelecionada != DateTime.now()) {
      setState(() {
        dataInicialController.text =
            DateFormat('yyyy-MM-dd').format(dataSelecionada);
      });
    }
  }

  Future<void> _selecionarDataFinal(BuildContext context) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (dataSelecionada != null && dataSelecionada != DateTime.now()) {
      setState(() {
        dataFinalController.text =
            DateFormat('yyyy-MM-dd').format(dataSelecionada);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Baixar XMLs',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConfiguracoesScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Período',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selecionarDataInicial(context),
                    child: IgnorePointer(
                      child: TextField(
                        controller: dataInicialController,
                        decoration:
                            const InputDecoration(labelText: 'Data Inicial'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: InkWell(
                    onTap: () => _selecionarDataFinal(context),
                    child: IgnorePointer(
                      child: TextField(
                        controller: dataFinalController,
                        decoration:
                            const InputDecoration(labelText: 'Data Final'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Tipo de emissão',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCheckBox('Terceiro', terceiroSelecionado, (value) {
                  setState(() {
                    terceiroSelecionado = value ?? false;
                  });
                }),
                _buildCheckBox('Própria', propriaSelecionado, (value) {
                  setState(() {
                    propriaSelecionado = value ?? false;
                  });
                }),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Modelo Nota',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCheckBox('NFe', nfeSelecionado, (value) {
                  setState(() {
                    nfeSelecionado = value ?? false;
                  });
                }),
                _buildCheckBox('NFCe', nfceSelecionado, (value) {
                  setState(() {
                    nfceSelecionado = value ?? false;
                  });
                }),
              ],
            ),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                carregando = true;
              });
              var emissaoP = '';
              var emissaoT = '';
              var _nfe = '';
              var _nfce = '';
              if (nfeSelecionado) {
                _nfe = '55';
              }
              if (nfceSelecionado) {
                _nfce = '65';
              }
              if (propriaSelecionado) {
                emissaoP = 'P';
              }
              if (terceiroSelecionado) {
                emissaoT = 'T';
              }
              await _iniciarAPI(dataInicialController.text,
                  dataFinalController.text, emissaoP, emissaoT, context);
              // ignore: use_build_context_synchronously
              await _baixarXmlsHandler(context, dataInicialController.text,
                  dataFinalController.text, emissaoP, emissaoT, _nfe, _nfce);

              setState(() {
                carregando = false;
              });
            },
            child: const Text('Baixar XMLs'),
          ),
          SizedBox(height: 35.0),
          if (carregando) CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildCheckBox(
      String title, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}

Future<void> _baixarXmlsHandler(
    BuildContext context,
    String dataInicial,
    String dataFinal,
    String emissorP,
    String emissorT,
    String _nfe,
    String _nfce) async {
  await AppConfig.initialize(); // Adicione esta linha
  final response = await http.get(Uri.parse(
      'http://localhost:8080/api/baixar-xmls?dataInicial=$dataInicial&dataFinal=$dataFinal&emissorP=$emissorP&emissorT=$emissorT&_nfe=$_nfe&_nfce=$_nfce'));

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('XMLs baixados com sucesso'),
      ),
    );
  } else {
    await encerrarProcesso();

    // Imprima detalhes adicionais da resposta em caso de falha
    print('Falha ao baixar XMLs. Código de status: ${response.statusCode}');
    if (response.body.isNotEmpty) {
      print('Corpo da resposta: ${response.body}');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Falha ao baixar XMLs. Código de status: ${response.statusCode}'),
      ),
    );
  }

  await encerrarProcesso();
}

Future<String> _baixarCodigoGoDoGitHub() async {
  final response = await http.get(Uri.parse(
      'https://raw.githubusercontent.com/EliezerSouz/conexao_mysql/main/cmd/main.go'));

  final responseMod = await http.get(Uri.parse(
      'https://raw.githubusercontent.com/EliezerSouz/conexao_mysql/main/go.mod'));

  final responseSum = await http.get(Uri.parse(
      'https://raw.githubusercontent.com/EliezerSouz/conexao_mysql/main/go.sum'));

  if (responseMod.statusCode == 200) {
    final caminhoLocal = 'go.mod';
    await File(caminhoLocal).writeAsString(responseMod.body);
    //return caminhoLocal;
  }
  if (responseSum.statusCode == 200) {
    final caminhoLocal = 'go.sum';
    await File(caminhoLocal).writeAsString(responseSum.body);
    //return caminhoLocal;
  }

  if (response.statusCode == 200) {
    final caminhoLocal = 'main.go';
    await File(caminhoLocal).writeAsString(response.body);
    return caminhoLocal;
  } else {
    print(
        'Falha ao baixar o código Go do GitHub. Código de status: ${response.statusCode}');
    return ''; // Ou outra lógica de tratamento de erro
  }
}

Future<void> _iniciarAPI(String dataInicial, String dataFinal, String emissaoP,
    String emissaoT, BuildContext context) async {
  String caminhoArquivoGo = await _baixarCodigoGoDoGitHub();

  try {
    // Execute o comando
    apiProcess = await Process.start(
      executavelGo,
      [
        'run',
        '-mod=readonly',
        caminhoArquivoGo,
        dataInicial,
        dataFinal,
        emissaoP,
        emissaoT
      ],
    );

    // Adicione um pequeno atraso para dar tempo à API para começar a ouvir
    await Future.delayed(Duration(seconds: 1));

    // Adicione um listener para imprimir a saída da API
    apiProcess!.stdout.transform(utf8.decoder).listen((data) {
      print('API Output: $data');
      // Exibir mensagem na tela usando SnackBar
      if (data.contains("Inciando")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$data'),
          ),
        );
      }
    });

    apiProcess!.stderr.transform(utf8.decoder).listen((data) {
      print('API Error: $data');
      // Exibir mensagem na tela usando SnackBar
      if(data.contains("Conectando") || data.contains("Iniciando"))
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$data'),
          backgroundColor: Colors.blueGrey, // Opcional: definir a cor de fundo
        ),
      );
    });
  } catch (e) {
    print('Erro ao iniciar a API: $e');
    // Exibir mensagem na tela usando SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao iniciar a API: $e'),
        backgroundColor: Colors.blueGrey, // Opcional: definir a cor de fundo
      ),
    );
  }
}

// Adicione esta classe ou função no arquivo config.dart
class EnvConfig {
  static void setEnvConfig(
      String host, String port, String user, String pass, String name) {
    String caminhoProjetoFlutter = Directory.current.path;
    // Caminho completo para o arquivo .env
    String envFilePath = '$caminhoProjetoFlutter/.env';

    // Crie ou abra o arquivo .env
    File envFile = File(envFilePath);
    if (!envFile.existsSync()) {
      envFile.createSync();
    }

    // Escreva os dados no arquivo .env
    envFile.writeAsStringSync('DB_HOST=$host\n');
    envFile.writeAsStringSync('DB_PORT=$port\n', mode: FileMode.append);
    envFile.writeAsStringSync('DB_USER=$user\n', mode: FileMode.append);
    envFile.writeAsStringSync('DB_PASS=$pass\n', mode: FileMode.append);
    envFile.writeAsStringSync('DB_NAME=$name\n', mode: FileMode.append);
  }
}

Future<void> encerrarProcesso() async {
  try {
    // Obtém o processo com o nome especificado
    final result = await Process.run(
      'powershell',
      [
        '-Command',
        "Get-Process | Where-Object {\$_.ProcessName -eq 'main'} | Select-Object -Property ProcessName, Id"
      ],
    );

    // Imprime a saída completa do PowerShell
    print('Saída do PowerShell: ${result.stdout}');

    // Verifica se houve erro na execução do comando
    if (result.exitCode != 0) {
      print('Erro ao obter informações do processo: ${result.stderr}');
      return;
    }

    // Obtém a saída do comando
    final output = result.stdout.trim();

    // Verifica se o processo foi encontrado
    if (output.isNotEmpty) {
      // Divide a saída em linhas
      final lines = LineSplitter.split(output);

      // Obtém a última linha (deve conter o ID do processo)
      final lastLine = lines.last;

      // Extrai o ID do processo da última linha
      var arquivos = lastLine.split(' ');
      final processId = int.tryParse(lastLine.split(' ')[arquivos.length - 1]);

      // Verifica se o ID do processo é válido
      if (processId != null) {
        // Encerra o processo usando Stop-Process
        await Process.run(
            'powershell', ['-Command', "Stop-Process -Id $processId -Force"]);

        print('Processo "main" (ID: $processId) encerrado com sucesso.');
      } else {
        print('Erro ao extrair o ID do processo.');
      }
    } else {
      print('Processo "main" não encontrado.');
    }
  } catch (e) {
    print('Erro ao executar o comando PowerShell: $e');
  }
}
