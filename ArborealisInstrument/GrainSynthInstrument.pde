// An instrument for createing a grain synth effect from an audio sample.
// Since each GrainSynthInstrument plays only one sample, we will need
// a number of these to play each of the different samples.
class GrainSynthInstrument implements Instrument
{ 
  Sampler samp;            // the currently running sampler
  MultiChannelBuffer buf;  // the input buffer containing the whole sample
  boolean onState;         // whether the intrument should emit sound or not
  float duration;
  
  // Create an instrument from an audio buffer
  GrainSynthInstrument(MultiChannelBuffer buf)
  { 
    this.onState = false;
    this.buf = buf;
  }
  
  // Toggle the instrument on/off
  // duration is number [0-1]: the fraction of the sample to play 
  void toggle(float duration) {
    this.onState = !this.onState; 
    
    if (this.onState) {
      println("Turning on with duration " + duration);
      
      // select the part of the sample we want to play
      MultiChannelBuffer buf2 = getBufferRange(this.buf, 0, (int)(duration * this.buf.getBufferSize()));
      
      // create a Sampler Ugen and turn on looping
      this.samp = new Sampler(buf2, 44100, 1); 
      this.samp.looping = true;
            
      // send output of the Sampler into the output
      this.samp.patch( out );
      
      // start playing the Sampler Ugen
      this.samp.trigger();
    } else {
      // stop the Sampler Ugen
      this.samp.stop();
      
      // stop sending the sample to the output 
      this.samp.unpatch( out );
    }
  }
  
  // this is called under the hood when playNote() is called
  void noteOn( float dur )
  {
    if (this.onState)
      this.samp.trigger();
  }
  
  // this is called under the hood when the time specified by playNote() has expired
  void noteOff()
  {
    this.samp.unpatch( out );
  }
}
