import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/data_controller.dart';
import '../../core/app_routes.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();
  final authController = Get.find<DataController>();

  bool isLoading = false;

  // Password visibility toggles
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),

                      // Logo
                      Center(
                        child: Image.asset(
                          'assets/images/logo_main_zoomed.png',
                          height: 80,
                        ),
                      ),
                      const SizedBox(height: 40),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Create an Account",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildTextField(nameController, 'Username'),
                      const SizedBox(height: 16),
                      _buildTextField(phoneController,
                          'Phone Number (+63xxxxxxxxxx)',
                          keyboardType: TextInputType.phone),
                      const SizedBox(height: 16),
                      _buildTextField(passController, 'Password',
                          obscure: true, isPasswordField: true),
                      const SizedBox(height: 16),
                      _buildTextField(confirmPassController, 'Confirm Password',
                          obscure: true, isConfirm: true),
                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE15C31),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: isLoading ? null : _registerUser,
                          child: isLoading
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : const Text(
                            "Sign up",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account? "),
                            GestureDetector(
                              onTap: () => Get.toNamed(AppRoutes.login),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hintText, {
        bool obscure = false,
        TextInputType keyboardType = TextInputType.text,
        bool isPasswordField = false,
        bool isConfirm = false,
      }) {
    return TextField(
      controller: controller,
      obscureText: obscure &&
          (isPasswordField ? _obscurePassword : isConfirm ? _obscureConfirmPassword : false),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        suffixIcon: isPasswordField
            ? IconButton(
          icon: Icon(
            (isPasswordField ? _obscurePassword : _obscureConfirmPassword)
                ? Icons.visibility_off
                : Icons.visibility,
            color: (isPasswordField ? _obscurePassword : _obscureConfirmPassword)
                ? Colors.grey[600]
                : const Color(0xFFE15C31),
          ),
          onPressed: () {
            setState(() {
              if (isPasswordField) {
                _obscurePassword = !_obscurePassword;
              } else {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              }
            });
          },
        )
            : null,
      ),
    );
  }

  Future<void> _registerUser() async {
    final name = nameController.text.trim();
    final rawPhone = phoneController.text.trim();
    final password = passController.text.trim();
    final confirmPassword = confirmPassController.text.trim();

    if (name.isEmpty ||
        rawPhone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields');
      return;
    }
    if (password != confirmPassword) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }


    // Show full-screen loading
    Get.dialog(
      Center(
        child: CircularProgressIndicator(
          color: Colors.grey.shade100, // match your theme
        ),
      ),
      barrierDismissible: false,
    );


    try {
      await authController.registerUser(
        name,
        rawPhone,
        password,
        onCodeSent: (message) {
          if (!mounted) return;
          Get.back(); // close loading
          Get.toNamed(
            AppRoutes.otp,
            arguments: {
              'phone': rawPhone,
              'name': name,
            },
          );
        },

        onError: (errorMessage) {
          if (!mounted) return;
          Get.back(); // close loading
          Get.snackbar('Error', errorMessage);
        },
      );
    } catch (e) {
      if (!mounted) return;
      Get.back(); // close loading
      Get.snackbar('Error', 'Registration failed: $e');
    }
  }
}

