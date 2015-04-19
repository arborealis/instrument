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
  void start(int x, int y, int z) {    
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
    float maxAmp = 0.5;
    float attackTime = map(1.0 / y2,  1.0/NUM_Y, 1.0, 0.25, 2.0);
    float decayTime = 0.25;
    float sustainLevel = float(y2)/NUM_Y * 0.75 + 0.25; //10xlog[(1/number of current tones playing at trigger time) x ((Y x .75) + .25)]
    float releaseTime = map(y2, 1.0, NUM_Y, 0.5, 4);
    this.adsr = new ADSR(maxAmp, attackTime, decayTime, sustainLevel, releaseTime); 
          
    // send output of the Sampler into the output
    this.samp.patch(this.adsr).patch( this.out );
    
    // start playing the Sampler Ugen and the ADSR envelope
    this.samp.trigger();
    adsr.noteOn();
  }
}
