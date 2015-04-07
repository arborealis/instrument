import ddf.minim.*;
import ddf.minim.ugens.*;
import java.util.Arrays;

float MAX_DURATION = 1000;

Minim minim;
AudioOutput out;
GrainInstrument[] instruments;
float[] durations = new float[20];

class GrainInstrument implements Instrument
{ 
  Sampler samp;
  MultiChannelBuffer buf;
  boolean onState;
  
  GrainInstrument(MultiChannelBuffer buf)
  { 
    this.onState = false;
    this.buf = buf;
  }
  
  void toggle(float duration) {
    this.onState = !this.onState; 
    
    if (this.onState) {
      println("Turning on with buf size " + this.buf.getBufferSize() + " and duration " + duration);
      MultiChannelBuffer buf2 = getBufferRange(this.buf, 0, (int)(duration * this.buf.getBufferSize()));       
      this.samp = new Sampler(buf2, 44100, 2); 
      this.samp.looping = true;
            
      this.samp.patch( out );
      this.samp.trigger();
    } else {
      this.samp.stop();
      this.samp.unpatch( out );
    }
  }
  
  void noteOn( float dur )
  {
    if (this.onState)
      this.samp.trigger();
  }
  
  void noteOff()
  {
    this.samp.unpatch( out );
  }
}

// setup is run once at the beginning
void setup()
{
  frameRate(30);
  size( 512, 200, P2D );
  minim = new Minim( this );
  out = minim.getLineOut( Minim.MONO, 2048 );  
  selectInput("Select an audio file:", "fileSelected");
}

float hammingWindow(int length, int index) {
  return 0.54f - 0.46f * (float) Math.cos(TWO_PI * index / (length - 1));
}

float hannWindow(int length, int index) {
  return 0.5f * (1f - (float) Math.cos(TWO_PI * index / (length - 1f)));
}

float cosineWindow(int length, int index) {
  return (float)Math.cos(Math.PI * index / (length - 1) - Math.PI / 2);
}

float rampWindow(int length, int index, int rampUp, int rampDown) {
  if (index < rampUp) return index / rampUp;
  else if (index >= length - rampDown) return (length - index) / rampDown;
  else return 1.0;
}

// This code is called by the selectInput() method on dialog close
void fileSelected(File selection) {  
  // pause time when adding a bunch of notes at once
  // This guarantees accurate timing between all notes added at once.
  out.pauseNotes();
  
  // load sample
  MultiChannelBuffer buf = new MultiChannelBuffer(1,2);
  minim.loadFileIntoBuffer(selection.getAbsolutePath(), buf);
  
  // split sample into subbuffers
  int nfTot = buf.getBufferSize();
  int nfSub = nfTot/20;  
  int nc = buf.getChannelCount();
  println("samp length: " + nfTot);
  println("subsamp length: " + nfSub);

  instruments = new GrainInstrument[20];
  
  for (int s = 0; s < 10; s++) {
    MultiChannelBuffer subBuf = new MultiChannelBuffer(nfSub, nc);
    for (int c = 0; c < nc; c++) {
      float[] frames = buf.getChannel(c);
      float[] subFrames = Arrays.copyOfRange(frames, s*nfSub, (s+1)*nfSub);
      subBuf.setChannel(c, subFrames);
    }
    instruments[s] = new GrainInstrument(subBuf);
    out.playNote( 0.000, 1000, instruments[s] );
  }

  out.resumeNotes();
}

// Use Hanning window to smooth transitions
float[] applyWindow(float[] buf) {
  float[] buf2 = new float[buf.length];
  for (int i = 0; i < buf.length; i++) {
    buf2[i] = buf[i] * hannWindow(buf.length, i);
    //buf2[i] = buf[i] * cosineWindow(buf.length, i);
  }
  return buf2;
}

MultiChannelBuffer getBufferRange(MultiChannelBuffer buf, int start, int length) {
  int nc = buf.getChannelCount();  
  MultiChannelBuffer buf2 = new MultiChannelBuffer(length, nc);
  for (int c = 0; c < nc; c++) {
    float[] frames = buf.getChannel(c);
    float[] subFrames = Arrays.copyOfRange(frames, start, start+length);
    
    // // reverse
    // for (int i = 0; i < subFrames.length/2; i++) {
    //   float tmp = subFrames[i];
    //   subFrames[i] = subFrames[subFrames.length - 1 - i];
    //   subFrames[subFrames.length - 1 - i] = tmp;
    // }
    
    subFrames = applyWindow(subFrames);
    buf2.setChannel(c, subFrames);
  }
  return buf2;
}
 
  
void keyPressed() {
  if (key >= '1' && key <= '9') {
    int num = key - '1';
    durations[num] = millis();
  }
}

void keyReleased() {
  if (key >= '1' && key <= '9') {
    int num = key - '1';
    
    durations[num] = (millis() - durations[num]) / MAX_DURATION;
    durations[num] = constrain(durations[num], 0, 1);
    instruments[num].toggle(durations[num]);
  }
}

void draw()
{
  // erase the window to grey
  background( 192 );
  // draw using a black stroke
  stroke( 0 );
  // draw the waveforms
  for( int i = 0; i < out.bufferSize() - 1; i++ )
  {
    // find the x position of each buffer value
    float x1  =  map( i, 0, out.bufferSize(), 0, width );
    float x2  =  map( i+1, 0, out.bufferSize(), 0, width );
    // draw a line from one buffer position to the next for both channels
    line( x1, 50 + out.left.get(i)*50, x2, 50 + out.left.get(i+1)*50);
    line( x1, 150 + out.right.get(i)*50, x2, 150 + out.right.get(i+1)*50);
  }  
}
