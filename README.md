# furbe

A new Flutter project for research.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

================ FUNCTIONAL REQUIREMENTS ================
Login Screen
- Users must be able to log in using valid credentials.
- Invalid credentials must trigger an error message.
- Successful login redirects to the Home Screen.

Dog Registration
- Users can add dog pictures from camera or gallery
- AI automatically detects dog breed using dog_classification.tflite
- Users can manually override detected breed

Mood Detection
- Real-time mood detection using dog_mood_classifier_finetuned.tflite
- Start Scan button disabled when no dog is registered

================ SETUP INSTRUCTIONS ================
1. Install Python dependencies:
   pip install -r requirements.txt

2. Start the inference server:
   Run start_inference_server.bat or:
   cd lib/services && python inference_server.py

3. Ensure TFLite models are in assets/models/:
   - dog_classification.tflite
   - dog_mood_classifier_finetuned.tflite

4. Run the Flutter app:
   flutter run

