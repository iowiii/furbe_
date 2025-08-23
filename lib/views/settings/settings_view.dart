import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/data_controller.dart';
import '../../core/app_routes.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ListTile(
            leading: const Icon(Icons.bookmark_outline),
            title: const Text('Registered Dogs'),
            onTap: () => Get.toNamed(AppRoutes.registerDogs),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Data Privacy Protocol'),
            onTap: () {
              Get.dialog(
                AlertDialog(
                  title: const Text("Data Privacy Protocol"),
                  content: const SingleChildScrollView(
                    child: Text(
                      "This study strictly complies with Republic Act No. 10173, "
                      "otherwise known as the Data Privacy Act of 2012 — "
                      "“An Act Protecting Individual Personal Information in Information "
                      "and Communications Systems in the Government and the Private Sector, "
                      "Creating for this Purpose a National Privacy Commission, and for Other Purposes.”\n\n"
                      "All personal information, including survey responses and contact details, "
                      "will be anonymized and securely stored in encrypted databases. Only "
                      "authorized researchers will have access, and participants may withdraw "
                      "at any time.\n\n"
                      "Any collected images that may capture human faces will be anonymized "
                      "(blurred, cropped, or excluded) before analysis to protect identities.\n\n"
                      "Regarding animal welfare, the study adheres to Republic Act No. 8485, "
                      "otherwise known as the Animal Welfare Act of the Philippines. No invasive "
                      "or harmful procedures will be used. Dogs will only be observed in their "
                      "natural environment with owner consent and supervision.",
                    ),
                  ),
                  actions: [
                    Center(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFE15C31), // background color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12), // rounded corners
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 80, vertical: 12),
                        ),
                        onPressed: () => Get.back(),
                        child: const Text(
                          "Close",
                          style: TextStyle(
                            color: Colors.white, // text color
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text('Account Information'),
            onTap: () => Get.to(() => AccountInfoPage()),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Get.dialog(
                AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: const Text(
                    "Logout",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  content: const Text(
                    "Are you sure you want to logout?",
                    style: TextStyle(fontSize: 16),
                  ),
                  actionsAlignment: MainAxisAlignment.spaceEvenly,
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE15C31),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text(
                        "No",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE15C31),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final auth = Get.find<DataController>();
                        await auth.logout();
                        Get.back();
                        Get.offAllNamed('/login');
                      },
                      child: const Text(
                        "Yes",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AccountInfoPage extends StatelessWidget {
  AccountInfoPage({super.key});
  final auth = Get.find<DataController>();

  @override
  Widget build(BuildContext context) {
    final user = auth.appUser.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Information"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Username card
            _infoCard(
              label: "Username",
              value: user?.name ?? '',
              onEdit: () => _showEditDialog(context, isUsername: true),
            ),
            const SizedBox(height: 16),

            // Password card
            _infoCard(
              label: "Password",
              value: user?.password != null ? '*' * user!.password.length : '',
              onEdit: () => _showEditDialog(context, isUsername: false),
            ),

            const Spacer(),

            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text(
                  "Delete Account",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () => _showDeleteAccountDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Reusable info card widget
  Widget _infoCard({
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE15C31), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label + Value
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  )),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          // Edit button
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black87),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }

  // existing dialogs remain unchanged...
  void _showEditDialog(BuildContext context, {required bool isUsername}) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    // local state for password visibility
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isUsername ? 'Edit Username' : 'Edit Password',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isUsername
                        ? "Please enter your current username to edit."
                        : "Please enter your current password to edit.",
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 16),

                  // Current field
                  TextField(
                    controller: currentController,
                    obscureText: !isUsername && obscureCurrent,
                    cursorColor: Colors.grey.shade600, // blinking cursor color
                    decoration: InputDecoration(
                      hintText: isUsername
                          ? "Enter Current Username"
                          : "Enter Current Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.shade600, // color when not focused
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: const Color(0xFFE15C31), // color when focused
                          width: 2,
                        ),
                      ),
                      suffixIcon: isUsername
                          ? null
                          : IconButton(
                        icon: Icon(
                          obscureCurrent
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        color: obscureCurrent
                            ? Colors.grey[600] // hidden → gray
                            : const Color(0xFFE15C31), // visible → orange
                        onPressed: () => setState(
                                () => obscureCurrent = !obscureCurrent),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // New Password
                  TextField(
                    controller: newController,
                    obscureText: !isUsername && obscureNew,
                    cursorColor: Colors.grey.shade600, // blinking cursor color
                    decoration: InputDecoration(
                      hintText: isUsername
                          ? "Enter New Username"
                          : "Enter New Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.shade600, // normal border
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: const Color(0xFFE15C31), // focused border
                          width: 2,
                        ),
                      ),
                      suffixIcon: isUsername
                          ? null
                          : IconButton(
                        icon: Icon(obscureNew
                            ? Icons.visibility_off
                            : Icons.visibility),
                        color: obscureNew
                            ? Colors.grey[600] // hidden → gray
                            : const Color(0xFFE15C31), // visible → orange
                        onPressed: () =>
                            setState(() => obscureNew = !obscureNew),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

// Confirm Password
                  TextField(
                    controller: confirmController,
                    obscureText: !isUsername && obscureConfirm,
                    cursorColor: Colors.grey.shade600, // blinking cursor color
                    decoration: InputDecoration(
                      hintText: isUsername
                          ? "Confirm New Username"
                          : "Confirm New Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.shade600, // normal border
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: const Color(0xFFE15C31), // focused border
                          width: 2,
                        ),
                      ),
                      // No suffix icon for confirm password
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE15C31),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () {
                        final current = currentController.text.trim();
                        final newValue = newController.text.trim();
                        final confirm = confirmController.text.trim();

                        if (current.isEmpty ||
                            newValue.isEmpty ||
                            confirm.isEmpty) {
                          Get.snackbar("Error", "All fields are required");
                          return;
                        }
                        if (newValue != confirm) {
                          Get.snackbar(
                              "Error", "Confirmation does not match new value");
                          return;
                        }
                        if (isUsername) {
                          auth.updateUsername(newValue);
                        } else {
                          auth.updatePassword(newValue);
                        }
                        Get.back();
                        Get.snackbar("Success",
                            "${isUsername ? "Username" : "Password"} updated");
                      },
                      child: const Text("Save",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final auth = Get.find<DataController>();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    final confirmDelete = false.obs;

    bool obscurePassword = true;
    bool obscureConfirm = true;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            child: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Delete Account",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Deleting your account removes all your data and information. To continue, enter your username and password.",
                      ),
                      const SizedBox(height: 16),

                      // Username
                      TextField(
                        controller: usernameController,
                        cursorColor: const Color(0xFFE15C31),
                        decoration: InputDecoration(
                          hintText: "Username",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade600,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE15C31),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Password
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        cursorColor: const Color(0xFFE15C31),
                        decoration: InputDecoration(
                          hintText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade600,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE15C31),
                              width: 2,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: obscurePassword
                                  ? Colors.grey[600]
                                  : const Color(0xFFE15C31),
                            ),
                            onPressed: () => setState(
                                    () => obscurePassword = !obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Confirm Password
                      TextField(
                        controller: confirmController,
                        obscureText: obscureConfirm,
                        cursorColor: const Color(0xFFE15C31),
                        decoration: InputDecoration(
                          hintText: "Confirm Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade600,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE15C31),
                              width: 2,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: obscureConfirm
                                  ? Colors.grey[600]
                                  : const Color(0xFFE15C31),
                            ),
                            onPressed: () => setState(
                                    () => obscureConfirm = !obscureConfirm),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Confirm Delete Checkbox
                      Obx(
                            () => CheckboxListTile(
                          value: confirmDelete.value,
                          onChanged: (v) => confirmDelete.value = v ?? false,
                          title: const Text("I confirm to delete the account"),
                          activeColor: const Color(0xFFE15C31),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Delete Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE15C31),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: () async {
                            final username = usernameController.text.trim();
                            final password = passwordController.text.trim();
                            final confirm = confirmController.text.trim();

                            final user = auth.appUser.value;
                            final phone = "+${user?.phone}";

                            if (username.isEmpty ||
                                password.isEmpty ||
                                confirm.isEmpty) {
                              Get.snackbar("Error", "All fields are required");
                              return;
                            }
                            if (password != confirm) {
                              Get.snackbar("Error", "Passwords do not match");
                              return;
                            }
                            if (!confirmDelete.value) {
                              Get.snackbar(
                                  "Error", "Please confirm account deletion");
                              return;
                            }

                            if (phone != null) {
                              await auth.firebaseService.db
                                  .child('accounts')
                                  .child(phone)
                                  .remove();
                              await auth.logout();
                              Get.back();
                              Get.snackbar(
                                  "Success", "Account deleted successfully");
                            }
                          },
                          child: const Text("Delete",
                              style:
                              TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
