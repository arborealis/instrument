/*
 * MIT License. Copyright (c) 2015 Greg Friedland
 */

// The KeyboardNote implementation and related functions

static class KeyboardFuncs {
  public static float adsrMaxAmp(int y, float z) {
    return KeyboardSettings.ADSR_MAX_AMPLITUDE;
    // numNotes = constrain(numNotes, 1, NUM_X);
    // return map(numNotes, 1, NUM_X, KeyboardSettings.ADSR_MAX_AMPLITUDE, KeyboardSettings.ADSR_MAX_AMPLITUDE/log(NUM_X));
  }
  
  static float adsrAttackTime(int y, float z) {
    return map(1.0 / y,  1.0/NUM_Y, 1.0, KeyboardSettings.ADSR_MIN_ATTACK_TIME, KeyboardSettings.ADSR_MAX_ATTACK_TIME);
  }

  static float adsrDecayTime(int y, float z) {
    return KeyboardSettings.ADSR_DECAY_TIME;
  }
  
  static float adsrSustainLevel(int y, float z) {
    //return log((1.0/numNotes) * ((y * 0.75) + 0.25));
    return y * (1 - KeyboardSettings.ADSR_MIN_SUSTAIN_LEVEL) + KeyboardSettings.ADSR_MIN_SUSTAIN_LEVEL;
  }
  
  static float adsrReleaseTime(int y, float z) {
    return map(y, 1.0, NUM_Y, KeyboardSettings.ADSR_MIN_RELEASE_TIME, KeyboardSettings.ADSR_MAX_RELEASE_TIME);
  }    

  static float highPassFreq(int numNotes) {
    numNotes = constrain(numNotes, 1, NUM_X);
    return map(numNotes, 1, NUM_X, 
      KeyboardSettings.HIGH_PASS_MIN_FREQUENCY, KeyboardSettings.HIGH_PASS_MAX_FREQUENCY);
  }

  static float clipDuration(int y) {
    return map(y, 1.0, NUM_Y, KeyboardSettings.CLIP_MIN_FRACTIONAL_LENGTH, KeyboardSettings.CLIP_MAX_FRACTIONAL_LENGTH);
  }
}  


// A "note" for creating a keyboard effect from an audio sample.
// Since each GrainSynthNote plays only one sample, we will need
// a number of these to play each of the different samples.
class KeyboardNote implements ArborealisNote
{ 
  UGen outUgen;
  Sampler samp;
  ADSR adsr;
  Oscil lfo;
  MoogFilter highPass;
  MultiChannelBuffer buf;  // the input buffer containing the whole sample
  float duration;
  int x, y, numNotes;
  float z;

  
  // Create an instrument from an audio buffer
  KeyboardNote(UGen outUgen, int x, int y, float z, int numNotes, MultiChannelBuffer buf)
  { 
    this.outUgen = outUgen;
    this.buf = buf;
    this.x = x;
    this.y = y;
    this.z = z;
    this.numNotes = numNotes;
    samp = null;
  }

  void stop() {
    if (samp != null) {
      println("NOTE: Stopping keyboard at (" + x + "," + y + ")");
      
      adsr.unpatchAfterRelease(outUgen);
      adsr.noteOff();

      samp = null;
    }
  }
  
  // Start the Note.
  void start() {    
    if (samp != null) {
      println("NOTE: Ignoring attempt to start keyboard at (" + x + "," + y + ") while already playing");
      return;
    }
      
    // select the part of the sample we want to play
    float duration = KeyboardFuncs.clipDuration(y);
    MultiChannelBuffer buf2 = getSubBuffer(this.buf, 0, (int)(duration * this.buf.getBufferSize()));

    println("NOTE: Starting keyboard at (" + x + "," + y + ") with duration: " + duration);
        
    // create a Sampler Ugen
    samp = new Sampler(buf2, 44100, 1);
          
    // create the ASDR
    adsr = new ADSR(KeyboardFuncs.adsrMaxAmp(y, z), 
                    KeyboardFuncs.adsrAttackTime(y, z),
                    KeyboardFuncs.adsrDecayTime(y, z), 
                    KeyboardFuncs.adsrSustainLevel(y, z),
                    KeyboardFuncs.adsrReleaseTime(y, z)); 

    // create the LFO high pass filter
    // lfo = new Oscil(GrainSynthSettings.LFO_FREQUENCY, 
    //   KeyboardFuncs.highPassFreq(y, z, numNotes) * KeyboardSettings.LFO_AMPLITUDE, Waves.SINE);
    // lfo.offset.setLastValue(KeyboardFuncs.highPassFreq(y, z, numNotes));
    // highPass = new MoogFilter(1, 0, MoogFilter.Type.HP);
    // lfo.patch(highPass.frequency);
      
    // send output of the Sampler through the high pass filter and adsr into the output
    //samp.patch(highPass).patch(adsr).patch(out);
    samp.patch(adsr).patch(outUgen);

    // start playing the Sampler Ugen and the ADSR envelope
    samp.trigger();
    adsr.noteOn();
  }
  
  // void update(int numNotes) {
    //println("NOTE: Updating note");
    // float hpFreq = KeyboardFuncs.highPassFreq(y, z, numNotes);
    // lfo.amplitude.setLastValue(KeyboardSettings.LFO_AMPLITUDE * hpFreq);
    // lfo.offset.setLastValue(hpFreq);

    // debug
    // adsr.setParameters(KeyboardFuncs.adsrMaxAmp(y,z,numNotes),
    //                    KeyboardFuncs.adsrAttackTime(y,z,numNotes),
    //                    KeyboardFuncs.adsrDecayTime(y,z,numNotes),
    //                    KeyboardFuncs.adsrSustainLevel(y,z,numNotes),
    //                    KeyboardFuncs.adsrReleaseTime(y,z,numNotes), 0, 0);
  // }
  
}
