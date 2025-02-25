# import tensorflow as tf
# import tensorflow_hub as hub

# # Load the Universal Sentence Encoder Lite model from TensorFlow Hub
# model = hub.load("https://tfhub.dev/google/universal-sentence-encoder-lite/2")

# # Save the model to a directory
# tf.saved_model.save(model, "use_lite_saved_model")

import tensorflow as tf

# Convert the SavedModel to TFLite format
converter = tf.lite.TFLiteConverter.from_saved_model("use_lite_saved_model")
tflite_model = converter.convert()

# Save the TFLite model
with open("use_lite_model.tflite", "wb") as f:
    f.write(tflite_model)
