import 'package:motifey/models/auth_model.dart';
import '../services/api_service.dart';

class AuthController {
  static final AuthController instance = AuthController._internal();
  factory AuthController() => instance;
  AuthController._internal();

  bool _isLoggedIn = false;
  AuthModel? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  AuthModel? get currentUser => _currentUser;

  /// 🔐 CHECK LOGIN
  Future<void> checkLogin() async {
    final token = await ApiService.getToken();
    final localData = await ApiService.getLocalUserData();

    if (token != null && localData != null) {
      _isLoggedIn = true;
      _currentUser = AuthModel.fromJson(localData);
    } else {
      _isLoggedIn = false;
      _currentUser = null;
    }
  }

  /// 🔑 LOGIN
  Future<bool> login(String username, String password) async {
    final success = await ApiService.login(username, password);

    if (success) {
      // ✅ Ambil data lokal HANYA SETELAH login dipastikan sukses
      final localData = await ApiService.getLocalUserData();
      
      if (localData != null) {
        _isLoggedIn = true;
        _currentUser = AuthModel.fromJson(localData);
        return true;
      }
    }
    
    // Jika gagal atau data lokal kosong
    _isLoggedIn = false;
    _currentUser = null;
    return false;
  }

  /// 🔐 SIGNUP
  Future<bool> signup(String username, String password) async {
    final result = await ApiService.signup(username, password);
    return result != null;
  }

  /// 🚪 LOGOUT
  Future<void> logout() async {
    await ApiService.logout(); 
    _isLoggedIn = false;
    _currentUser = null;
  }

  /// 🔄 REFRESH USER DATA
  Future<void> refreshProfile() async {
    final data = await ApiService.getProfile();
    if (data != null) {
      _currentUser = AuthModel.fromJson(data);
      // Opsional: Simpan ulang data terbaru ke SharedPreferences lewat ApiService
    }
  }
}