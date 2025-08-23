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
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        "Close",
                        style: TextStyle(color: Color(0xFFE15C31)),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  content: const Text(
                    "Are you sure you want to logout?",
                    style: TextStyle(fontSize: 16),
                  ),
                  actionsAlignment: MainAxisAlignment.spaceEvenly,
                  actions: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFFE15C31),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text(
                        "No",
                        style: TextStyle(color: Color(0xFFE15C31)),
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
                      child: const Text("Yes", style: TextStyle(color: Colors.white)),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Username", style: TextStyle(fontSize: 16)),
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: Colors.black87),
                  onPressed: () => _showEditDialog(context, isUsername: true),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  Text(user?.name ?? '', style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Password", style: TextStyle(fontSize: 16)),
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: Colors.black87),
                  onPressed: () => _showEditDialog(context, isUsername: false),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                  user?.password != null ? '*' * user!.password.length : '',
                  style: const TextStyle(fontSize: 16)),
            ),
            const Spacer(),
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text("Delete Account",
                    style: TextStyle(color: Colors.red)),
                onPressed: () => _showDeleteAccountDialog(context),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, {required bool isUsername}) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                style: TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: currentController,
                decoration: InputDecoration(
                  hintText: isUsername
                      ? "Enter Current Username"
                      : "Enter Current Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(
                          0xFFE15C31),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newController,
                decoration: InputDecoration(
                  hintText:
                      isUsername ? "Enter New Username" : "Enter New Password",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(
                          0xFFE15C31),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                decoration: InputDecoration(
                  hintText: isUsername
                      ? "Confirm New Username"
                      : "Confirm New Password",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(
                          0xFFE15C31),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final auth = Get.find<DataController>();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    final confirmDelete = false.obs;
    final downloadData = false.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Obx(() {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75, // 75% of screen height
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        hintText: "Username",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: confirmDelete.value,
                      onChanged: (v) => confirmDelete.value = v ?? false,
                      title: const Text("I confirm to delete the account"),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      value: downloadData.value,
                      onChanged: (v) => downloadData.value = v ?? false,
                      title: const Text(
                          "I want to download all the data before deleting."),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 16),
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
                            style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
