import 'package:flutter/material.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Privacy Protocol'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            '''
FurBe Data Privacy Protocol

1. Purpose
This Data Privacy Protocol defines the principles and procedures by which the FurBe application collects, stores, and protects personal data. It ensures that information is handled responsibly, retained only as required for application functionality, and safeguarded in compliance with the Philippine Data Privacy Act of 2012 and the data-protection standards followed by Firebase.

2. Scope
This protocol applies to the FurBe mobile application on all supported platforms, to the Firebase services used as the cloud database for storing user-provided data, and to all personnel or contractors involved in the design, development, testing, and maintenance of FurBe.

3. Data Categories and Processing
3.1 Captured and Stored Data – FurBe collects and stores only the data that users provide when creating dog profiles, including dog profile photographs, names, breeds, and other optional details. These data are stored in a secure Firebase cloud database to enable user account management and profile functionality.
3.2 Real-Time Mood Detection Data – Images captured by the device camera during mood detection are processed solely in volatile memory on the user’s device. These frames are used only to generate instantaneous mood-classification results and are never saved to persistent storage or transmitted to any server.
3.3 Retention – Profile data and images remain in the Firebase cloud database until the user deletes the profile or account, after which the data are permanently removed from production systems and backups in accordance with FurBe’s data-retention policy.

4. User Consent and Transparency
Users provide explicit consent when creating a profile, uploading images, and granting camera permissions for mood detection. A Privacy Notice, presented during onboarding and accessible within the application, describes the categories of data collected, storage methods, and user rights.

5. Security Measures
All data stored in Firebase are encrypted in transit using Transport Layer Security (TLS) and encrypted at rest through Firebase’s built-in security mechanisms. Access to stored data is restricted to authorized application services through strong authentication and role-based access controls. Diagnostic and analytics logs exclude raw images and any personally identifiable information beyond aggregated statistics.

6. User Rights
Users may view, update, or delete their dog’s profile information and photographs at any time through the application interface. Upon deletion, FurBe ensures that all corresponding records are purged from Firebase and associated backups in line with the established data-retention policy. Users may also request confirmation of deletion or details of their stored data through the designated contact channel.

7. Governance and Maintenance
All changes to code that affect data capture, upload, or storage undergo mandatory privacy and security review. Regular technical audits verify the effectiveness of encryption, retention, and deletion controls. Any privacy or security incident involving stored data is investigated promptly, with remediation and user notification carried out as required by the Philippine Data Privacy Act of 2012.

8. Compliance
This protocol is designed to comply with the Philippine Data Privacy Act of 2012 and aligns with the data-protection policies and security standards provided by Firebase, including its encryption, access control, and audit capabilities. Updates to this protocol are documented and version-controlled to maintain continuous compliance.
            ''',
            style: TextStyle(fontSize: 16, height: 1.4),
          ),
        ),
      ),
    );
  }
}
