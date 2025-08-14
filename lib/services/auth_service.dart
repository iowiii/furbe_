class AuthService {
  bool isLoggedIn = false;

  Future<bool> login(String email, String otp) async {
    // Mock OTP check
    await Future.delayed(const Duration(seconds: 1));
    if (otp == '123456') {
      isLoggedIn = true;
      return true;
    }
    return false;
  }

  void logout() {
    isLoggedIn = false;
  }
}
