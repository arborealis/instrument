/////// Some Window functions for smoothing the transition between starting/stopping the sample 
/////// http://en.wikipedia.org/wiki/Window_function#Generalized_Hamming_windows

float hammingWindow(int length, int index) {
  return 0.54f - 0.46f * (float) Math.cos(TWO_PI * index / (length - 1));
}

float hannWindow(int length, int index) {
  return 0.5f * (1f - (float) Math.cos(TWO_PI * index / (length - 1f)));
}

float cosineWindow(int length, int index) {
  return (float)Math.cos(Math.PI * index / (length - 1) - Math.PI / 2);
}

// Apply Hanning window over an array
float[] applyWindow(float[] buf) {
  float[] buf2 = new float[buf.length];
  for (int i = 0; i < buf.length; i++) {
    buf2[i] = buf[i] * hannWindow(buf.length, i);
  }
  return buf2;
}
