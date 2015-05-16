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

float rampWindow(int length, int index, int rampFrames) {
  if (index < rampFrames)
    return float(index) / rampFrames;
  else if (length - index < rampFrames)
    return float(length - index) / rampFrames;
  else
    return 1;
}

// Apply Hanning window over an array
float[] applyWindow(float[] buf) {
  float[] buf2 = new float[buf.length];
  for (int i = 0; i < buf.length; i++) {
    //buf2[i] = buf[i] * hannWindow(buf.length, i);
    buf2[i] = buf[i] * rampWindow(buf.length, i, 500);
  }
  return buf2;
}

float mean(float[] array) {
  float sum = 0;
  for (int i = 0; i < array.length; i++)
    sum += array[i];
  return sum / array.length;
}

float[] removeDCoffset(float[] array) {
  float mean = mean(array);
  float[] normArray = new float[array.length];
  for (int i = 0; i < array.length; i++)
    normArray[i] = array[i] - mean;
  
  return normArray;
}

// find the first zero crossing from the front or the back
int findZeroCrossing(float[] array, boolean front, int offset) {
  if (front) {
    for (int i = offset + 1; i < array.length; i++) {
      if (array[i-1] > 0 != array[i] > 0)
        return i;
    }
  } else {
    for (int i = array.length - 1 - offset - 1; i >= 0; i--) {
      if (array[i+1] > 0 != array[i] > 0)
        return i;
    }
  }
  println("Couldn't find zero crossing.");
  assert(false);
  return -1;
}


// trim an array to have a zero crossing in front and back
float[] trimToZeroCrossings(float[] array) {
  int start = findZeroCrossing(array, true, 0);
  int end = findZeroCrossing(array, false, 0);
  //println("trimtoZC start=" + start + " end=" + end + " length=" + array.length);
  
  return Arrays.copyOfRange(array, start, end);
}


float[] appendMirroredReverse(float[] array, boolean reverse) {
  float[] array2 = new float[array.length*2];
  for (int i = 0; i < array.length; i++) {
    array2[i] = array[i];
    if (reverse)
      array2[2*array.length - 1 - i] = -array[i];
    else
      array2[2*array.length - 1 - i] = array[i];
  }
  return array2;
} 


float[] ramp(float[] array, int numFrames) {
  float[] array2 = new float[array.length];
  for (int i = 0; i < array.length; i++) {
    int ii = min(i, array.length - 1 - numFrames);
    if (ii < numFrames)
      array2[i] = array[i] * ii / numFrames;
    else 
      array2[i] = array[i];
  }
  return array2;
} 


float[] addBlanksBefore(float[] array, int numBlanks) {
  float[] array2 = new float[array.length + numBlanks];
  for (int i = 0; i < array2.length; i++) {
    if (i < numBlanks)
      array2[i] = 0;
    else
      array2[i] = array[i - numBlanks];
  }
  return array2;
}


float[] rotate(float[] array, int offset) {
  float[] array2 = new float[array.length];
  for (int i = 0; i < array2.length; i++) {
    array2[i] = array[(i+offset+array.length)%array.length];
  }
  return array2;
}



void printArray(String text, float[] array, int nElems) {
  println(text);
  for (int i = 0; i < nElems; i ++)
    println((int)(100000*array[i]));
  println("...");
  for (int i = array.length-nElems; i < array.length ; i++)
    println((int)(100000*array[i]));
  println("\n");
}  


// Extract all sub-section of a buffer into another buffer
MultiChannelBuffer getSubBuffer(MultiChannelBuffer buf, int start, int length) {
  int nc = buf.getChannelCount();  
  MultiChannelBuffer bufOut = new MultiChannelBuffer(length, nc);
  
  float[] frames = buf.getChannel(0);
    
  frames = Arrays.copyOfRange(frames, start, start+length);
//    if (c == 0) printArray("orig", frames, 5);
    
  frames = removeDCoffset(frames);
//    if (c == 0) printArray("DCoffset", frames, 5);
    
  frames = trimToZeroCrossings(frames);
//    if (c == 0) printArray("postTrim", frames, 5);
    
//    if (c == 0) printArray("apendReverse", frames, 5);

    //frames = ramp(frames, rampFrames);

     frames = applyWindow(frames);

  frames = appendMirroredReverse(frames, false);
    //frames = addBlanksBefore(frames, frames.length - 2*rampFrames);

    //if (firstClip)
//      frames = rotate(frames, -frames.length/2+rampFrames);
//    else
//      frames = rotate(frames, rampFrames);

  bufOut.setBufferSize(frames.length);
  for (int c = 0; c < nc; c++) {      
    bufOut.setChannel(c, frames);
  }
  return bufOut;
}
