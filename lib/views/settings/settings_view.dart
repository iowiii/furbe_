import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/data_controller.dart';
import '../../core/app_routes.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<DataController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ListTile(
            title: const Text('Registered Dogs'),
            onTap: () => Get.toNamed(AppRoutes.registerDogs),
          ),

          ListTile(
            title: const Text('Data Privacy'),
            onTap: () {
              Get.dialog(
                AlertDialog(
                  title: const Text("Data Privacy"),
                  content: const Text(
                    "We respect your privacy. All data collected by this app "
                        "is stored securely and only used to improve your experience. "
                        "You can manage, edit, or delete your account data at any time.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              );
            },
          ),

          ListTile(
            title: const Text('Account Information'),
            onTap: () => Get.to(() => AccountInfoPage()),
          ),
          ListTile(
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
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        "No",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        final auth = Get.find<DataController>();
                        await auth.logout();
                        Get.back();
                        Get.offAllNamed('/login');
                      },
                      child: const Text("Yes"),
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
      appBar: AppBar(title: const Text("Account Information")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Username: ${user?.name ?? ''}", style: const TextStyle(fontSize: 16)),
                ElevatedButton(
                  onPressed: () => _showEditDialog(context, isUsername: true),
                  child: const Text("Edit"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Password: ${user?.password != null ? '*' * user!.password.length : ''}",
                  style: const TextStyle(fontSize: 16),
                ),
                ElevatedButton(
                  onPressed: () => _showEditDialog(context, isUsername: false),
                  child: const Text("Edit"),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => _showDeleteAccountDialog(context),
              child: const Text("Delete Account"),
            ),
          ],
        ),
      ),
    );
  }
  void _showEditDialog(BuildContext context, {required bool isUsername}) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    Get.dialog(AlertDialog(
      title: Text(isUsername ? "Edit Username" : "Edit Password"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: currentController,
              decoration: InputDecoration(
                labelText: isUsername ? "Enter Current Username" : "Enter Current Password",
              ),
            ),
            TextField(
              controller: newController,
              decoration: InputDecoration(
                labelText: isUsername ? "Enter New Username" : "Enter New Password",
              ),
            ),
            TextField(
              controller: confirmController,
              decoration: InputDecoration(
                labelText: isUsername ? "Confirm New Username" : "Confirm New Password",
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            final current = currentController.text.trim();
            final newValue = newController.text.trim();
            final confirm = confirmController.text.trim();

            if (current.isEmpty || newValue.isEmpty || confirm.isEmpty) {
              Get.snackbar("Error", "All fields are required");
              return;
            }
            if (newValue != confirm) {
              Get.snackbar("Error", "Confirmation does not match new value");
              return;
            }
            if (isUsername) {
              auth.updateUsername(newValue);
            } else {
              auth.updatePassword(newValue);
            }
            Get.back();
            Get.snackbar("Success", "${isUsername ? "Username" : "Password"} updated");
          },
          child: const Text("Save"),
        ),
      ],
    ));
  }
  void _showDeleteAccountDialog(BuildContext context) {
    final auth = Get.find<DataController>();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    final confirmDelete = false.obs;
    final downloadData = false.obs;

    Get.dialog(AlertDialog(
      title: const Text("Delete Account"),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Deleting your account removes all your data and information."),
            const SizedBox(height: 8),
            TextField(controller: usernameController, decoration: const InputDecoration(labelText: "Username")),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            TextField(controller: confirmController, decoration: const InputDecoration(labelText: "Confirm Password"), obscureText: true),
            const SizedBox(height: 8),
            Obx(() => CheckboxListTile(
              value: confirmDelete.value,
              onChanged: (v) => confirmDelete.value = v ?? false,
              title: const Text("I confirm to delete this account"),
            )),
            Obx(() => CheckboxListTile(
              value: downloadData.value,
              onChanged: (v) => downloadData.value = v ?? false,
              title: const Text("I want to download all my data before deleting"),
            )),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            final username = usernameController.text.trim();
            final password = passwordController.text.trim();
            final confirm = confirmController.text.trim();

            final user = auth.appUser.value;
            final phone = "+${user?.phone}";

            if (username.isEmpty || password.isEmpty || confirm.isEmpty) {
              print(phone);
              Get.snackbar("Error", "All fields are required");
              return;
            }
            if (password != confirm) {
              Get.snackbar("Error", "Passwords do not match");
              return;
            }
            if (!confirmDelete.value) {
              Get.snackbar("Error", "Please confirm account deletion");
              return;
            }

            if (phone != null) {
              await auth.firebaseService.db.child('accounts').child(phone).remove();
              await auth.logout();
              Get.back();
              Get.snackbar("Success", "Account deleted successfully");
            }
          },
          child: const Text("Delete"),
        ),
      ],
    ));
  }
}
