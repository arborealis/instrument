// An instrument for createing a grain synth effect from an audio sample.
// Since each GrainSynthInstrument plays only one sample, we will need
// a number of these to play each of the different samples.
class GrainSynthInstrument
{ 
  Sampler samp;            // the currently running sampler
  MultiChannelBuffer buf;  // the input buffer containing the whole sample
  float duration;
  
  // Create an instrument from an audio buffer
  GrainSynthInstrument(MultiChannelBuffer buf)
  { 
    this.buf = buf;
    this.samp = null;
  }
  
  void stop() {
    if (this.samp != null) {
      println("Stopping grain synth");
      
      // FIX we should stop the sample and unpatch it but if we do it right here, it could cause the 
      // sample to get cutoff, so just stop the looping
      this.samp.looping = false;
      
      // this.samp.stop(); // stop the Sampler Ugen
      // this.samp.unpatch( out ); // stop sending the sample to the output
      
      this.samp = null;
    }
  }
  
  // Start the instrument.
  // duration is number [0-1]: the fraction of the sample to play 
  void start(float duration) {    
    // if we are already playing and the duration doesn't change, don't stop and restart the sample
    if (duration == this.duration && this.samp != null)
      return;
      
    stop();
    
    if (duration != 0) {
      println("Starting grain synth with duration: " + duration);
      this.duration = duration;
      
      // select the part of the sample we want to play
      MultiChannelBuffer buf2 = getBufferRange(this.buf, 0, (int)(duration * this.buf.getBufferSize()));
      
      // create a Sampler Ugen and turn on looping
      this.samp = new Sampler(buf2, 44100, 1); 
      this.samp.looping = true;
            
      // send output of the Sampler into the output
      this.samp.patch( out );
      
      // start playing the Sampler Ugen
      this.samp.trigger();
    }
  }
}
