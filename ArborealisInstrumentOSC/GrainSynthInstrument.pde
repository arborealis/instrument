// An instrument for createing a grain synth effect from an audio sample.
// Since each GrainSynthInstrument plays only one sample, we will need
// a number of these to play each of the different samples.
class GrainSynthInstrument implements Instrument
{ 
  Sampler samp;            // the currently running sampler
  MultiChannelBuffer buf;  // the input buffer containing the whole sample
  float duration;
  boolean on;
  AudioOutput out;
  
  // Create an instrument from an audio buffer
  GrainSynthInstrument(AudioOutput out, MultiChannelBuffer buf)
  { 
    this.out = out;
    this.buf = buf;
    this.samp = null;
  }
  
  int sampleFrames() {
    return (int)(this.duration * this.buf.getBufferSize());
  }
  
  // called under the hood by minim after audioOutput.playNote is called
  void noteOn(float durationSecs) {      
    // select the part of the sample we want to play
    MultiChannelBuffer buf2 = getBufferRange(this.buf, 0, sampleFrames());
    
    // create a Sampler Ugen and turn on looping
    this.samp = new Sampler(buf2, 44100, 1); 
    this.samp.looping = false;
          
    // send output of the Sampler into the output
    this.samp.patch( this.out );
    
    // start playing the Sampler Ugen
    this.samp.trigger();
  }

  // called under the hood by minim when the note is over
  void noteOff() {
    if (this.on)
      this.out.playNote( 0.0, sampleFrames()/44100.0, this );
    else {
      if (this.samp != null) {
        println("Stopping grain synth");
        
        //this.samp.stop(); // stop the Sampler Ugen
        this.samp.unpatch( out ); // stop sending the sample to the output
        
        this.samp = null;
      }
    }   
  }

  // Stop the instrument when the current sample is done playing
  void stop() {
    this.on = false;
  }
  
  // Start the instrument.
  // duration is number [0-1]: the fraction of the sample to play 
  void start(float duration) {   
    this.duration = duration;
    
    // if duration is 0, then stop the instrument
    if (this.duration == 0) {
      stop();
    }    
    // if we're not already on, then start playing 
    else if (!this.on) {
      println("Starting grain synth with duration: " + duration);
      this.on = true;
      this.out.playNote( 0.0, sampleFrames()/44100.0, this );
    }
  }
}
