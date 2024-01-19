
// configuracoes_screen.dart

import 'package:flutter/material.dart';

import '../main.dart';
import 'appConfig.dart';

class ConfiguracoesScreen extends StatefulWidget {
  @override
  _ConfiguracoesScreenState createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Carregar valores atuais das configurações
    _hostController.text = AppConfig.getDbHost();
    _portController.text = AppConfig.getDbPort();
    _userController.text = AppConfig.getDbUser();
    _passController.text = AppConfig.getDbPass();
    _nameController.text = AppConfig.getDbName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações do Banco de Dados'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(_hostController, 'Host', 'localhost'),
            _buildTextField(_portController, 'Porta', '3306'),
            _buildTextField(_userController, 'Usuário', 'root'),
            _buildTextField(_passController, 'Senha', 'passwor', isPassword: true),
            _buildTextField(_nameController, 'Nome do Banco de Dados', 'db_name'),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                _salvarConfiguracoes();
                await encerrarProcesso();
                Navigator.of(context).pop(); // Fechar a tela de configurações
              },
              child: const Text('Salvar Configurações'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String defaultValue,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          hintText: defaultValue,
        ),
      ),
    );
  }

  void _salvarConfiguracoes() {
    // Salvar as configurações usando AppConfig.setDbConfig
    AppConfig.setDbConfig(
      _hostController.text,
      _portController.text,
      _userController.text,
      _passController.text,
      _nameController.text,
    );

    // Agora, escreva as configurações no arquivo .env
    EnvConfig.setEnvConfig(
    _hostController.text,
    _portController.text,
    _userController.text,
    _passController.text,
    _nameController.text,
  );
  }
}
