// Settings to customize can be found in Settings.pde

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

InstrumentSettings[] instrumentSettings = new InstrumentSettings[] 
  { new InstrumentSettings(GrainSynthSettings.USE_FILE), 
    new InstrumentSettings(KeyboardSettings.USE_FILE), 
    new InstrumentSettings(ArpeggioSettings.USE_FILE) };

OscP5 oscP5;

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

  // trigger the open file dialog or load the files directly
  for (InstrumentType instrumentType : InstrumentType.values()) {
    InstrumentSettings settings = instrumentSettings[instrumentType.ordinal()];
    if (settings.useFile == null)
      selectInput("Select an audio file to use for the '" + instrumentType + "'", "create_" + instrumentType);
    else
      create_instrument(instrumentType, new File(sketchPath(settings.useFile)));
  }

  // start the osc server
  oscP5 = new OscP5(this, OSC_RECEIVE_PORT);
  OSCListener list = new OSCListener(oscP5, instruments);
  oscP5.addListener(list);  

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

// Create an instrument of the given type from a file
void create_instrument(InstrumentType instrumentType, File file) {
  if (file.exists()) {
    println("Creating instrument " + instrumentType + " from file: " + file.getPath());
    instruments[instrumentType.ordinal()] = instrumentFactory(instrumentType, file.getPath());
  } else {
    println("ERROR: unable to open sound file: " + file.getPath());;
  }
}

// This code is called by the selectInput() method when a file has been selected
void create_grainsynth(File file) {
  create_instrument(InstrumentType.grainsynth, file);
}
void create_keyboard(File file) {
  create_instrument(InstrumentType.keyboard, file);
}
void create_arpeggio(File file) {
  create_instrument(InstrumentType.arpeggio, file);
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

void keyPressed() {
  if (key == ' ') {
    recorder.endRecord();
    recorder.save();
    recorder.beginRecord();
  }
}  