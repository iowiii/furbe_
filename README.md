# FurBe — Dog Mood Detector 🐶📱

FurBe is a Flutter mobile app that detects a dog’s emotion in real time using an on-device TensorFlow Lite model. It classifies frames into **Happy**, **Sad**, **Angry**, and **Scared**, aggregates decisions across multiple frames for stability, and logs results for later analysis.

> Built with **Flutter** (GetX, Camera) and an image classifier trained in **TensorFlow/Keras**, exported to **TFLite** and integrated via **tflite_flutter 0.11.0**.

---

## Table of Contents

- [Features](#features)
- [App Screens](#app-screens)
- [Architecture](#architecture)
- [Model & Data Pipeline](#model--data-pipeline)
- [Getting Started](#getting-started)
  - [1) Mobile App](#1-mobile-app)
  - [2) Model Training (Colab)](#2-model-training-colab)
- [Configuration](#configuration)
- [Project Structure](#project-structure)
- [Tech Stack](#tech-stack)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgements](#acknowledgements)
- [Maintainers Notes](#maintainers-notes)

---

## Features

- 🎥 **Real-time inference** from the device camera
- 🧠 **TFLite model** (EfficientNet/MobileNet backbone) — runs fully offline
- 🧮 **Bagged decisions**: averages softmax across **10 frames** before finalizing a mood
- ✅ **Confidence gating**: only save results with **≥ 60%** confidence (configurable)
- 📊 **Analysis view** with daily logs, calendar overview, and notes
- 📚 **Articles screen** linking to curated learning resources
- 👤 **Profiles** for dogs (name, gender, breed, birthdate, photo)

---

## App Screens

- **Home** – quick navigation and status  
- **Start Scan** – continuous detection; finalizes a mood every few seconds using 10-frame averaging  
- **Quick Scan** – single detection flow  
- **Analysis** – calendar overview + list of logged moods; add notes  
- **Articles** – links/resources for dog behavior  
- **Profile** – dog profile and settings  

> If you have screen images, add them under `docs/screens/` and reference them here.

---

## Architecture

