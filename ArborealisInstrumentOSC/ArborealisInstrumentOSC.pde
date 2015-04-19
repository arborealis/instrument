import ddf.minim.*;
import ddf.minim.ugens.*;
import java.util.Arrays;


// constants
int PORT = 8000;
float MAX_DURATION = 1000;   // how long to hold a key for to get 100% of the sample to play 
int NUM_XSECTIONS = XVal.values().length;      // how many x sections in the instrument 

Minim minim;
AudioOutput out;

// array with one instrument for every X position since each gets a different sample to play
GrainSynthInstrument[] instruments = new GrainSynthInstrument[NUM_XSECTIONS];

// array storing the state of each instrument: which players are where on the board
InstrumentState[] instrumentStates = new InstrumentState[InstrumentType.values().length];

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
  
  for (int i = 0; i < instrumentStates.length; i++)
    instrumentStates[i] = new InstrumentState();
    
  // trigger the open file dialog or load the file directly
  //selectInput("Select an audio file:", "fileSelected");
  loadGrainSynthFile("../samples/GRAIN.WAV");
}

// load a file from disk, split it and create instruments from the samples
void loadGrainSynthFile(String filename) {  
  // load sample
  MultiChannelBuffer buf = new MultiChannelBuffer(1,2); // argument here are overriden on the next line
  minim.loadFileIntoBuffer(filename, buf);
  
  // split sample into sub-samples of equal size
  int nfTot = buf.getBufferSize();
  int nfSub = nfTot/NUM_XSECTIONS;  
  int nc = buf.getChannelCount();
  println("# Sample frames: " + nfTot);
  println("# Sub-sample frames: " + nfSub);

  // Split the main sample buffer into sub-samples
  // Create the GrainSynthInstruments for each sub-sample
  for (int s = 0; s < NUM_XSECTIONS; s++) {
    MultiChannelBuffer subBuf = new MultiChannelBuffer(nfSub, nc);
    for (int c = 0; c < nc; c++) {
      float[] frames = buf.getChannel(c);
      float[] subFrames = Arrays.copyOfRange(frames, s*nfSub, (s+1)*nfSub);
      subBuf.setChannel(c, subFrames);
    }

    // Create the GrainSynthInsturment; and start it by calling playNote
    // it will not start emitting sound until it has been enabled with start()
    instruments[s] = new GrainSynthInstrument(out, subBuf);
  }
}

// This code is called by the selectInput() method when a file has been selected
void fileSelected(File selection) {  
  loadGrainSynthFile(selection.getAbsolutePath());
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

  // parse args; currently we expect all floats
  float[] args = new float[msg.arguments().length];
  for (int i = 0; i < msg.arguments().length; i++)
    args[i] = msg.get(i).floatValue();
    
  // check for incoming OSC messages and update the instruments' states
  boolean valid = oscListener.updateState(msg.netAddress(), msg.addrPattern(), args, instrumentStates);
      
  if (!valid) {
    println("Invalid osc message: " + msg.toString());
  } else {
    InstrumentState instState = instrumentStates[InstrumentType.grainsynth.ordinal()];
    
    // For each player we are aware of, either start or stop their instrument based on the current state
    for (Object obj : instState.getAllPlayers()) {
      Player player = (Player) obj;
      float duration = float(player.y) / (YVal.values().length - 1);
      
      // start and stop the instruments
      if (!player.active)
        instruments[player.x].stop();
      else
        instruments[player.x].start(duration);
    }
  }
}


  
  

  
