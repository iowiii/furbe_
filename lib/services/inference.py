from PIL import Image
import numpy as np
import tensorflow as tf
import os

# Model paths
BREED_MODEL_PATH = "assets/models/dog_classification.tflite"
MOOD_MODEL_PATH = "assets/models/dog_mood_classifier_finetuned.tflite"

# Class names
BREED_CLASSES = ["Pomeranian", "Pug", "Shih Tzu"]
MOOD_CLASSES = ["Happy", "Sad", "Angry", "Scared"]

class DogInference:
    def __init__(self):
        self.breed_interpreter = None
        self.mood_interpreter = None
        self._load_models()
    
    def _load_models(self):
        try:
            # Load breed classification model
            if os.path.exists(BREED_MODEL_PATH):
                self.breed_interpreter = tf.lite.Interpreter(model_path=BREED_MODEL_PATH)
                self.breed_interpreter.allocate_tensors()
            
            # Load mood classification model
            if os.path.exists(MOOD_MODEL_PATH):
                self.mood_interpreter = tf.lite.Interpreter(model_path=MOOD_MODEL_PATH)
                self.mood_interpreter.allocate_tensors()
        except Exception as e:
            print(f"Error loading models: {e}")
    
    def preprocess_image(self, image, target_size=(224, 224)):
        image = image.resize(target_size)
        img_array = np.array(image, dtype=np.float32) / 255.0
        img_array = np.expand_dims(img_array, axis=0)
        return img_array
    
    def predict_breed(self, image):
        if self.breed_interpreter is None:
            return {"label": "Unknown", "confidence": 0.0}
        
        try:
            input_details = self.breed_interpreter.get_input_details()
            output_details = self.breed_interpreter.get_output_details()
            
            img_array = self.preprocess_image(image)
            self.breed_interpreter.set_tensor(input_details[0]['index'], img_array)
            self.breed_interpreter.invoke()
            
            predictions = self.breed_interpreter.get_tensor(output_details[0]['index'])[0]
            top_index = np.argmax(predictions)
            
            return {
                "label": BREED_CLASSES[top_index],
                "confidence": float(predictions[top_index])
            }
        except Exception as e:
            print(f"Error predicting breed: {e}")
            return {"label": "Unknown", "confidence": 0.0}
    
    def predict_mood(self, image):
        if self.mood_interpreter is None:
            return {"label": "Unknown", "confidence": 0.0}
        
        try:
            input_details = self.mood_interpreter.get_input_details()
            output_details = self.mood_interpreter.get_output_details()
            
            img_array = self.preprocess_image(image)
            self.mood_interpreter.set_tensor(input_details[0]['index'], img_array)
            self.mood_interpreter.invoke()
            
            predictions = self.mood_interpreter.get_tensor(output_details[0]['index'])[0]
            top_index = np.argmax(predictions)
            
            return {
                "label": MOOD_CLASSES[top_index],
                "confidence": float(predictions[top_index])
            }
        except Exception as e:
            print(f"Error predicting mood: {e}")
            return {"label": "Unknown", "confidence": 0.0}

# Global inference instance
inference = DogInference()

# Convenience functions
def predict_breed(image):
    return inference.predict_breed(image)

def predict_mood(image):
    return inference.predict_mood(image)
