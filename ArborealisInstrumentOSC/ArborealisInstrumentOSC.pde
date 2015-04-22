import ddf.minim.*;
import ddf.minim.ugens.*;
import java.util.Arrays;

// constants
static int PORT = 8000;
static float MAX_DURATION = 1000;   // how long to hold a key for to get 100% of the sample to play 
static int NUM_X = 10;      // how many x sections in the instrument 
static int NUM_Y = 10;      // how many y sections in the instrument 
static int XFADE_LENGTH = 100;

Minim minim;
AudioOutput out;
boolean pause = false;

// array storing the instruments
ArborealisInstrument[] instruments = new ArborealisInstrument[InstrumentType.values().length];

OSCListener oscListener = new OSCListener(this, PORT);

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
  
  // trigger the open file dialog or load the file directly
  //selectInput("Select an audio file:", "fileSelected");
  instruments[0] = new ArborealisInstrument(parseSampleFile("../samples/GRAIN.WAV"));

  instruments[0].start(0, 5, 0, new GrainSynthNote(out, instruments[0].getSample(0)));
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
  if (pause)
    return;
    
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

  // parse args; currently we expect all floats
  float[] args = new float[msg.arguments().length];
  for (int i = 0; i < msg.arguments().length; i++)
    args[i] = msg.get(i).floatValue();
    
  // check for incoming OSC messages and update the instruments' states
  boolean valid = oscListener.updateState(msg.netAddress(), msg.addrPattern(), args, instruments);
      
  if (!valid) {
    println("Invalid osc message: " + msg.toString());
  }
}

void keyPressed() {
  if (key == ' ')
    pause = true;
}

void keyReleased() {
  pause = false;
} 
  
  

  
