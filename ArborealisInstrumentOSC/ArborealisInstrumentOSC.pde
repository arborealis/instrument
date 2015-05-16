//////////// Start of parameters to edit ////////////
static final int OSC_RECEIVE_PORT = 7000;
static final int OSC_SEND_PORT = 9000;
static final int NUM_X = 20;      // how many x sections in the instrument 
static final int NUM_Y = 10;      // how many y sections in the instrument 
static final boolean RECORD = true; // whether to record the audio and write to file on spacebar keypress

public class GrainSynthSettings {
  static public final float ADSR_MAX_AMPLITUDE = 0.25;       // constant
  static public final float ADSR_MIN_ATTACK_TIME = 0.25;     // function of 1/y
  static public final float ADSR_MAX_ATTACK_TIME = 2.0;      // function of 1/y
  static public final float ADSR_DECAY_TIME = 0.25;          // constant
  static public final float ADSR_MIN_SUSTAIN_LEVEL = 0.25;   // constant
  static public final float ADSR_MIN_RELEASE_TIME = 0.5;     // function of y
  static public final float ADSR_MAX_RELEASE_TIME = 4;       // function of y

  static public final int HIGH_PASS_MIN_FREQUENCY = 200;
  static public final int HIGH_PASS_MAX_FREQUENCY = 4000;
  static public final float LFO_AMPLITUDE = 0.2;             // the lfo range: percentage of the high pass frequency
  static public final float LFO_FREQUENCY = 0.2;             // how fast does the LFO change

  static public final float CLIP_MIN_FRACTIONAL_LENGTH = 0.5;// how long to make the shortest clip to repeat
  static public final float CLIP_MAX_FRACTIONAL_LENGTH = 1;  // how long to make the shortest clip to repeat

  static public final boolean USE_FILE_DIALOG = false;
}
//////////// End of parameters to edit ////////////







// features to add
// * volume control on new node playing
// * background ambient lower octave repeat of base track
// * reverb


import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.UGen;
import java.util.Arrays;
import oscP5.*;

Minim minim;
AudioOutput out;
AudioRecorder recorder;

// array storing the instruments
ArborealisInstrument[] instruments = new ArborealisInstrument[InstrumentType.values().length];

OSCListener oscListener = new OSCListener(this, OSC_RECEIVE_PORT);

// setup is run once at the beginning
void setup()
{
  // call the draw() method at 30fps
  frameRate(30);
  
  // create the graphics window
  size( 512, 200, P2D );
  
  // create the audio synthesis instance and the AudioOutput instance
  minim = new Minim( this );
  out = minim.getLineOut( Minim.MONO, 2048 );  
  recorder = minim.createRecorder(out, "arborealis-grain.wav");
  recorder.beginRecord();

  // trigger the open file dialog or load the file directly
  if (GrainSynthSettings.USE_FILE_DIALOG)
    selectInput("Select an audio file:", "fileSelected");
  else
    instruments[0] = new ArborealisInstrument(parseSampleFile("../samples/GRAIN_MONO.wav"));
  instruments[1] = new ArborealisInstrument(parseSampleFile("../samples/GRAIN_MONO.wav"));
  instruments[2] = new ArborealisInstrument(parseSampleFile("../samples/GRAIN_MONO.wav"));

  // debugging: play a note on startup
  //instruments[0].start(1, 9, 0, new GrainSynthNote(out, instruments[0].getSample(1)));
}

// load a file from disk, split it evenly and create instruments from the samples
// TODO: allow splitting based on returns to zero (RTZ)
MultiChannelBuffer[] parseSampleFile(String filename) {  
  MultiChannelBuffer[] bufs = new MultiChannelBuffer[NUM_X];
  
  // load sample
  MultiChannelBuffer mainBuf = new MultiChannelBuffer(1,2); // argument here are overriden on the next line
  minim.loadFileIntoBuffer(filename, mainBuf);
  
  // split sample into sub-samples of equal size
  int nfTot = mainBuf.getBufferSize();
  int nfSub = nfTot/NUM_X;  
  int nc = mainBuf.getChannelCount();
  println("# Sample frames: " + nfTot);
  println("# Sub-sample frames: " + nfSub);

  // Split the main sample buffer into sub-samples
  for (int s = 0; s < NUM_X; s++) {
    bufs[s] = new MultiChannelBuffer(nfSub, nc);
    for (int c = 0; c < nc; c++) {
      float[] frames = mainBuf.getChannel(c);
      float[] subFrames = Arrays.copyOfRange(frames, s*nfSub, (s+1)*nfSub);
      bufs[s].setChannel(c, subFrames);
    }
  }
  
  return bufs;
}

// This code is called by the selectInput() method when a file has been selected
void fileSelected(File selection) {  
  instruments[0] = new ArborealisInstrument(parseSampleFile(selection.getAbsolutePath()));
}
 
// draw the music visualizer to the screen
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

// handler managed by OscP5 that listens to OSC messages
void oscEvent(OscMessage msg) {
  //println("Received osc message: " + msg.toString());

  // get args
  OscArgument[] args = new OscArgument[msg.arguments().length];
  for (int i = 0; i < msg.arguments().length; i++)
    args[i] = msg.get(i);

  // check for incoming OSC messages and update the instruments' states
  boolean valid = oscListener.updateState(msg.netAddress(), msg.addrPattern(), args, instruments);
      
  if (!valid) {
    println("Invalid osc message: " + msg.toString());
  }
}

void keyPressed() {
  if (key == ' ') {
    recorder.endRecord();
    recorder.save();
    recorder.beginRecord();
  }
}  