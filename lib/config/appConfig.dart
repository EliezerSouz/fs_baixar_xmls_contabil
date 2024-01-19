import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String dbHostKey = 'DB_HOST';
  static const String dbPortKey = 'DB_PORT';
  static const String dbUserKey = 'DB_USER';
  static const String dbPassKey = 'DB_PASS';
  static const String dbNameKey = 'DB_NAME';

  static late SharedPreferences _prefs;

  // Adicione um método para inicializar SharedPreferences
  static Future<void> initialize() async {
    
    _prefs = await SharedPreferences.getInstance();
  }

  // Adicione um método para verificar se _prefs foi inicializado
  // ignore: unnecessary_null_comparison
  static bool get isInitialized => _prefs != null;

  static String getDbHost() {
    return _prefs.getString(dbHostKey) ?? 'localhost';
  }

  static String getDbPort() {
    return _prefs.getString(dbPortKey) ?? '3306';
  }

  static String getDbUser() {
    return _prefs.getString(dbUserKey) ?? 'root';
  }

  static String getDbPass() {
    return _prefs.getString(dbPassKey) ?? 'farsoft01';
  }

  static String getDbName() {
    return _prefs.getString(dbNameKey) ?? 'farsoft_reyautopecas';
  }

  static Future<void> setDbConfig(String host, String port, String user, String pass, String name) async {
    // Verifique se _prefs foi inicializado antes de usar
    if (!isInitialized) {
      await initialize();
    }

    await _prefs.setString(dbHostKey, host);
    await _prefs.setString(dbPortKey, port);
    await _prefs.setString(dbUserKey, user);
    await _prefs.setString(dbPassKey, pass);
    await _prefs.setString(dbNameKey, name);
  }
}
