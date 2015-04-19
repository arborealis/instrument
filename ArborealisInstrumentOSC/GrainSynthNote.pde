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
  Sampler samp;            // the currently running sampler
  MultiChannelBuffer buf;  // the input buffer containing the whole sample
  float duration;
  ADSR adsr;
  int x, y;
  float z;
  
  // Create an instrument from an audio buffer
  GrainSynthNote(AudioOutput out, MultiChannelBuffer buf)
  { 
    this.out = out;
    this.buf = buf;
    this.samp = null;
  }

  void stop() {
    if (this.samp != null) {
      println("Stopping grain synth");
      
      this.adsr.unpatchAfterRelease(this.out);
      this.adsr.noteOff();

      // FIX we should stop the sample and unpatch it but if we do it right here, it could cause the 
      // sample to get cutoff, so just stop the looping
      //this.samp.looping = false;
      
      // this.samp.stop(); // stop the Sampler Ugen
      // this.samp.unpatch( out ); // stop sending the sample to the output
      
      this.samp = null;
    }
  }
  
  // Start the Note.
  void start(int x, int y, float z, int numNotes) {    
    this.x = x;
    this.y = y;
    this.z = z;
    
    int y2 = y + 1;
    
    if (this.samp != null) {
      println("Ignoring attempt to start grain synth while already playing");
      return;
    }
      
    println("Starting grain synth with duration: " + duration);
    
    // select the part of the sample we want to play
    float duration = float(y2) / NUM_Y;
    MultiChannelBuffer buf2 = getBufferRange(this.buf, 0, (int)(duration * this.buf.getBufferSize()));
    
    // create a Sampler Ugen and turn on looping
    this.samp = new Sampler(buf2, 44100, 1); 
    this.samp.looping = true;
          
    // create the ASDR
    this.adsr = new ADSR(GrainSynthADSR.maxAmp(y2, z, numNotes), 
                         GrainSynthADSR.attackTime(y2, z, numNotes),
                         GrainSynthADSR.decayTime(y2, z, numNotes), 
                         GrainSynthADSR.sustainLevel(y2, z, numNotes),
                         GrainSynthADSR.releaseTime(y2, z, numNotes)); 
          
    // send output of the Sampler into the output
    this.samp.patch(this.adsr).patch( this.out );
    
    // start playing the Sampler Ugen and the ADSR envelope
    this.samp.trigger();
    adsr.noteOn();
  }
  
  void update(int activNoteCount) {
  }
  
}
