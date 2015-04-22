static class GrainSynthADSR {
  public static float maxAmp(int y, float z, int numNotes) {
    return 0.5;
  }
  
  static float attackTime(int y, float z, int numNotes) {
    return map(1.0 / y,  1.0/NUM_Y, 1.0, 0.25, 2.0);
  }

  static float decayTime(int y, float z, int numNotes) {
    return 0.25;
  }
  
  static float sustainLevel(int y, float z, int numNotes) {
    //return log((1.0/numNotes) * ((y * 0.75) + 0.25));
    return (y * 0.75) + 0.25;
  }
  
  static float releaseTime(int y, float z, int numNotes) {
    return map(y, 1.0, NUM_Y, 0.5, 4);
  }    
}  


// A "note" for creating a grain synth effect from an audio sample.
// Since each GrainSynthNote plays only one sample, we will need
// a number of these to play each of the different samples.
class GrainSynthNote implements ArborealisNote
{ 
  AudioOutput out;
  SamplerXFade samp;            // the currently running sampler
  MultiChannelBuffer buf;  // the input buffer containing the whole sample
  float duration;
  ADSR adsr;
  int x, y, numNotes;
  float z;
  
  // Create an instrument from an audio buffer
  GrainSynthNote(AudioOutput _out, MultiChannelBuffer _buf)
  { 
    out = _out;
    buf = _buf;
    samp = null;
  }

  void stop() {
    if (samp != null) {
      println("Stopping grain synth");
      
      adsr.unpatchAfterRelease(out);
      adsr.noteOff();

      // FIX we should stop the sample and unpatch it but if we do it right here, it could cause the 
      // sample to get cutoff, so just stop the looping
      samp.looping = false;
      
      // this.samp.stop(); // stop the Sampler Ugen
      // this.samp.unpatch( out ); // stop sending the sample to the output
      
      samp = null;
    }
  }
  
  // Start the Note.
  void start(int _x, int _y, float _z, int _numNotes) {    
    x = _x;
    y = _y + 1;
    z = _z;
    numNotes = _numNotes;
        
    if (samp != null) {
      println("Ignoring attempt to start grain synth while already playing");
      return;
    }
      
    println("Starting grain synth with duration: " + duration);
    
    // select the part of the sample we want to play
    float duration = float(y) / NUM_Y;
    MultiChannelBuffer buf2 = getSubBuffer(this.buf, 0, (int)(duration * this.buf.getBufferSize()));
    
    // create a Sampler Ugen and turn on looping
    samp = new SamplerXFade(buf2, 44100, 1, XFADE_LENGTH); 
    samp.looping = true;
          
    // create the ASDR
    adsr = new ADSR(GrainSynthADSR.maxAmp(y, z, numNotes), 
                         GrainSynthADSR.attackTime(y, z, numNotes),
                         GrainSynthADSR.decayTime(y, z, numNotes), 
                         GrainSynthADSR.sustainLevel(y, z, numNotes),
                         GrainSynthADSR.releaseTime(y, z, numNotes)); 
          
    // send output of the Sampler into the output
    samp.patch( adsr ).patch( out );
    
    // start playing the Sampler Ugen and the ADSR envelope
    samp.trigger();
    adsr.noteOn();
  }
  
  void update(int _numNotes) {
    numNotes = _numNotes;
    // FIX: update ADSR
  }
  
}
