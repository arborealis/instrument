static class GrainSynthFuncs {
  public static float adsrMaxAmp(int y, float z, int numNotes) {
    numNotes = constrain(numNotes, 1, NUM_X);
    return map(numNotes, 1, NUM_X, GrainSynthSettings.ADSR_MAX_AMPLITUDE, GrainSynthSettings.ADSR_MAX_AMPLITUDE/log(NUM_X));
  }
  
  static float adsrAttackTime(int y, float z, int numNotes) {
    return map(1.0 / y,  1.0/NUM_Y, 1.0, GrainSynthSettings.ADSR_MIN_ATTACK_TIME, GrainSynthSettings.ADSR_MAX_ATTACK_TIME);
  }

  static float adsrDecayTime(int y, float z, int numNotes) {
    return GrainSynthSettings.ADSR_DECAY_TIME;
  }
  
  static float adsrSustainLevel(int y, float z, int numNotes) {
    //return log((1.0/numNotes) * ((y * 0.75) + 0.25));
    return y * (1 - GrainSynthSettings.ADSR_MIN_SUSTAIN_LEVEL) + GrainSynthSettings.ADSR_MIN_SUSTAIN_LEVEL;
  }
  
  static float adsrReleaseTime(int y, float z, int numNotes) {
    return map(y, 1.0, NUM_Y, GrainSynthSettings.ADSR_MIN_RELEASE_TIME, GrainSynthSettings.ADSR_MAX_RELEASE_TIME);
  }    

  static float highPassFreq(int y, float z, int numNotes) {
    numNotes = constrain(numNotes, 1, NUM_X);
    return map(numNotes, 1, NUM_X, 
      GrainSynthSettings.HIGH_PASS_MIN_FREQUENCY, GrainSynthSettings.HIGH_PASS_MAX_FREQUENCY);
  }

  static float clipDuration(int y) {
    return map(y, 1.0, NUM_Y, GrainSynthSettings.CLIP_MIN_FRACTIONAL_LENGTH, GrainSynthSettings.CLIP_MAX_FRACTIONAL_LENGTH);
  }
}  


// A "note" for creating a grain synth effect from an audio sample.
// Since each GrainSynthNote plays only one sample, we will need
// a number of these to play each of the different samples.
class GrainSynthNote implements ArborealisNote
{ 
  AudioOutput out;
  Sampler samp;
  ADSR adsr;
  Oscil lfo;
  MoogFilter highPass;
  MultiChannelBuffer buf;  // the input buffer containing the whole sample
  float duration;
  int x, y, numNotes;
  float z;

  
  // Create an instrument from an audio buffer
  GrainSynthNote(AudioOutput out, int x, int y, float z, int numNotes, MultiChannelBuffer buf)
  { 
    this.out = out;
    this.buf = buf;
    this.x = x;
    this.y = y;
    this.z = z;
    this.numNotes = numNotes;
    samp = null;
  }

  void stop() {
    if (samp != null) {
      if (VERBOSE) println("NOTE: Stopping grain synth at (" + x + "," + y + ")");
      
      adsr.unpatchAfterRelease(out);
      adsr.noteOff();

      samp = null;
    }
  }
  
  // Start the Note.
  void start() {    
    if (samp != null) {
      if (VERBOSE) println("Ignoring attempt to start grain synth while already playing");
      return;
    }
      
    // select the part of the sample we want to play
    float duration = GrainSynthFuncs.clipDuration(y);
    MultiChannelBuffer buf2 = getSubBuffer(this.buf, 0, (int)(duration * this.buf.getBufferSize()));

    if (VERBOSE) println("NOTE: Starting grain synth at (" + x + "," + y + ") with duration: " + duration);
        
    // create a Sampler Ugen and turn on looping
    samp = new Sampler(buf2, 44100, 1);
    samp.looping = true;
          
    // create the ASDR
    adsr = new ADSR(GrainSynthFuncs.adsrMaxAmp(y, z, numNotes), 
                    GrainSynthFuncs.adsrAttackTime(y, z, numNotes),
                    GrainSynthFuncs.adsrDecayTime(y, z, numNotes), 
                    GrainSynthFuncs.adsrSustainLevel(y, z, numNotes),
                    GrainSynthFuncs.adsrReleaseTime(y, z, numNotes)); 

    // create the LFO high pass filter
    lfo = new Oscil(GrainSynthSettings.LFO_FREQUENCY, 
      GrainSynthFuncs.highPassFreq(y, z, numNotes) * GrainSynthSettings.LFO_AMPLITUDE, Waves.SINE);
    lfo.offset.setLastValue(GrainSynthFuncs.highPassFreq(y, z, numNotes));
    highPass = new MoogFilter(1, 0, MoogFilter.Type.HP);
    lfo.patch(highPass.frequency);
      
    // send output of the Sampler through the high pass filter and adsr into the output
    samp.patch(highPass).patch(adsr).patch(out);

    // start playing the Sampler Ugen and the ADSR envelope
    samp.trigger();
    adsr.noteOn();
  }
  
  void update(int numNotes) {
    //println("NOTE: Updating note");
    float hpFreq = GrainSynthFuncs.highPassFreq(y, z, numNotes);
    lfo.amplitude.setLastValue(GrainSynthSettings.LFO_AMPLITUDE * hpFreq);
    lfo.offset.setLastValue(hpFreq);

    adsr.setParameters(GrainSynthFuncs.adsrMaxAmp(y,z,numNotes),
                       GrainSynthFuncs.adsrAttackTime(y,z,numNotes),
                       GrainSynthFuncs.adsrDecayTime(y,z,numNotes),
                       GrainSynthFuncs.adsrSustainLevel(y,z,numNotes),
                       GrainSynthFuncs.adsrReleaseTime(y,z,numNotes), 0, 0);
  }
  
}
