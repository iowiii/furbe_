# Dog Breed-Specific Mood Detection System

## Overview
This system implements a two-stage detection process for dog mood analysis:

1. **Breed Classification**: Uses `dog_classification.tflite` to identify the dog breed
2. **Mood Detection**: Uses breed-specific models to detect mood based on the identified breed

## Architecture

### Stage 1: Breed Classification
- **Model**: `assets/models/dog_classification.tflite`
- **Service**: `BreedClassificationService`
- **Supported Breeds**: Pomeranian, Pug, Shih Tzu
- **Minimum Confidence**: 60%

### Stage 2: Breed-Specific Mood Detection
- **Models**:
  - `assets/models/pomeranian_mood.tflite`
  - `assets/models/pug_mood.tflite`
  - `assets/models/shih_tzu_mood.tflite`
- **Service**: `TFLiteService`
- **Supported Moods**: Happy, Sad, Angry, Scared
- **Minimum Confidence**: 70%

## Implementation Details

### Key Components

1. **BreedClassificationService**: Handles breed detection using the main classification model
2. **TFLiteService**: Manages breed-specific mood detection models
3. **BreedMoodDetector**: Unified service that combines both stages
4. **HomeController**: Orchestrates the detection process in scan modes

### Usage Locations
- **Start Scan**: Full detection with database saving
- **Quick Scan**: Detection only, no saving

### Detection Flow
1. Camera captures frame
2. `dog_classification.tflite` identifies breed (≥60% confidence)
3. Corresponding breed-specific model detects mood (≥70% confidence)
4. Results displayed with breed and mood information
5. If in Start Scan mode, results are saved to database

## Model Files
- `dog_classification.tflite`: Main breed classifier
- `pomeranian_mood.tflite`: Pomeranian-specific mood detector
- `pug_mood.tflite`: Pug-specific mood detector  
- `shih_tzu_mood.tflite`: Shih Tzu-specific mood detector

## Benefits
- Higher accuracy through breed-specific training
- Reduced false positives
- Better mood detection for breed-specific characteristics
- Scalable architecture for adding new breeds