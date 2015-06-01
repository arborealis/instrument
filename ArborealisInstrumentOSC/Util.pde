/*
 * MIT License. Copyright (c) 2015 Greg Friedland.
 */

// Utilities for parsing and processing sample sound files

import java.util.Collections;

// load a file from disk; split it evenly or use return to zeros
MultiChannelBuffer[] parseSampleFile(String filename, boolean useReturnToZero, 
  int silenceMinFramesClipSeparation, float silenceValueCutoff, float maxAmplitude) {  
  ArrayList<MultiChannelBuffer> bufs = new ArrayList<MultiChannelBuffer>();    

  // load sample
  MultiChannelBuffer mainBuf = new MultiChannelBuffer(1,2); // argument here are overriden on the next line
  minim.loadFileIntoBuffer(filename, mainBuf);
  
  if (!useReturnToZero) {
    // split sample into sub-samples of equal size
    int nfTot = mainBuf.getBufferSize();
    int nfSub = nfTot/NUM_X;  
    int nc = mainBuf.getChannelCount();
    println("# Sample frames: " + nfTot);
    println("# Sub-sample frames: " + nfSub);

    // Split the main sample buffer into sub-samples
    for (int s = 0; s < NUM_X; s++) {
      MultiChannelBuffer buf = new MultiChannelBuffer(nfSub, nc);
      for (int c = 0; c < nc; c++) {
        float[] frames = mainBuf.getChannel(c);
        float[] subFrames = Arrays.copyOfRange(frames, s*nfSub, (s+1)*nfSub);

        // scale all clips to have the same max amplitude
        float maxPrevAmp = max(subFrames);
        println("FILE: before scaling max of buffer=" + s + " channel=" + c + ": " +  maxPrevAmp);
        for (int i = 0; i < subFrames.length; i++)
          subFrames[i] *= maxAmplitude / maxPrevAmp;

        buf.setChannel(c, subFrames);
      }
      bufs.add(buf);
    }
  } else {
    if (mainBuf.getChannelCount() > 1)
      println("FILE: using only first channel of multi channel file");
    float[] frames = mainBuf.getChannel(0);

    //println("FILE: Looking for clips in sample with length=" + frames.length);

    int bufInd = 0;
    while (bufInd < frames.length) {
      int startInd = findNextNonSilence(frames, bufInd, silenceValueCutoff);
      if (startInd == -1)
        break;
      //println("FILE: Found next nonzero=" + startInd);

      int endInd = findNextSilence(frames, startInd, silenceMinFramesClipSeparation, silenceValueCutoff);
      //println("FILE: Found next multiple zeros=" + endInd);
      if (endInd == -1)
        endInd = frames.length;

      MultiChannelBuffer buf = new MultiChannelBuffer(endInd - startInd, 1);
      float[] subFrames = Arrays.copyOfRange(frames, startInd, endInd);

      // scale all clips to have the same max amplitude
      float maxPrevAmp = max(subFrames);
      println("FILE: before scaling max of buffer=" + bufs.size() + ": " +  maxPrevAmp);
      for (int i = 0; i < subFrames.length; i++)
        subFrames[i] *= maxAmplitude / maxPrevAmp;

      buf.setChannel(0, subFrames);
      bufs.add(buf);

      bufInd = endInd;
    }
  }

  if (bufs.size() != NUM_X)
    println("FILE: found " + bufs.size() + " clips in sample but expected " + NUM_X);

  // fill the buffer array with exactly NUM_X buffers
  MultiChannelBuffer[] bufArray = new MultiChannelBuffer[NUM_X];
  for (int i = 0; i < NUM_X; i++)
    bufArray[i] = bufs.get(i % bufs.size());
  
  return bufArray;
}


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
  // println("Couldn't find zero crossing.");
  // assert(false);
  return -1;
}

int findNextSilence(float[] array, int offset, int numZeros, float cutoff) {
  int numZerosRemaining = numZeros;
  int startZeroInd = -1;

  for (int i = offset; i < array.length; i++) {
    if (Math.abs(array[i]) <= cutoff) {
      //println("Found zero: " + i);
      if (numZerosRemaining == numZeros)
        startZeroInd = i;
      else if (numZerosRemaining == 0)
        return startZeroInd;
      numZerosRemaining--;
    } else {
      numZerosRemaining = numZeros;
    }
  }  
  return -1;
}

int findNextNonSilence(float[] array, int offset, float cutoff) {
  for (int i = offset; i < array.length; i++) {
    if (Math.abs(array[i]) > cutoff)
      return i;
  }
  // println("Couldn't find nonzero value.");
  // assert(false);
  return -1;
}


// trim an array to have a zero crossing in front and back
float[] trimToZeroCrossings(float[] array) {
  int start = findZeroCrossing(array, true, 0);
  int end = findZeroCrossing(array, false, 0);
  assert(start != -1 && end != -1);
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
    
  frames = removeDCoffset(frames);
    
  frames = trimToZeroCrossings(frames);

  frames = applyWindow(frames);

  frames = appendMirroredReverse(frames, false);

  bufOut.setBufferSize(frames.length);
  for (int c = 0; c < nc; c++) {      
    bufOut.setChannel(c, frames);
  }
  return bufOut;
}

