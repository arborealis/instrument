import ddf.minim.*;
import ddf.minim.ugens.*;
import java.util.Arrays;

int NUM_XSECTIONS = 20;      // how many x sections in the instrument 
float MAX_DURATION = 1000;   // how long to hold a key for to get 100% of the sample to play 

Minim minim;
AudioOutput out;

// create an array to store one instrument for every X position since
// each gets a different sample to play
GrainSynthInstrument[] instruments = new GrainSynthInstrument[NUM_XSECTIONS];

// create an array to store the num ms each of the 0-9 keys has been pressed
float[] keyPressLengths = new float[NUM_XSECTIONS];


// setup is run once at the beginning
void setup()
{
  // run the draw() method at 30fps
  frameRate(30);
  
  // create the graphics window
  size( 512, 200, P2D );
  
  // create the audio synthesis instance and the AudioOutput instance
  minim = new Minim( this );
  out = minim.getLineOut( Minim.MONO, 2048 );  
  
  // trigger the open file dialog
  selectInput("Select an audio file:", "fileSelected");
}


// This code is called by the selectInput() method when a file has been selected
void fileSelected(File selection) {  
  // pause time when adding a bunch of notes at once
  // This guarantees accurate timing between all notes added at once.
  out.pauseNotes();
  
  // load sample
  MultiChannelBuffer buf = new MultiChannelBuffer(1,2); // argument here are overriden on the next line
  minim.loadFileIntoBuffer(selection.getAbsolutePath(), buf);
  
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

    // Crate the GrainSynthInsturment; and start it by calling playNote
    // it will not start emmitting sound until it has been enabled with toggle()
    instruments[s] = new GrainSynthInstrument(subBuf);
    out.playNote( 0.000, 1000, instruments[s] );
  }

  out.resumeNotes();
}
 
// called under the hood when a key on the keyboard has been pressed
void keyPressed() {
  if (key >= '0' && key <= '9') {
    int num = key - '0';
    
    // keep track of when the key was pressed
    keyPressLengths[num] = millis();
  }
}

// called under the hood when a key on the keyboard has been released
void keyReleased() {
  if (key >= '0' && key <= '9') {
    int num = key - '0';
    
    // calculate how long the key has been pressed and turn on the appropriate grain synth instrument
    keyPressLengths[num] = (millis() - keyPressLengths[num]) / MAX_DURATION;
    keyPressLengths[num] = constrain(keyPressLengths[num], 0, 1);
    instruments[num].toggle(keyPressLengths[num]);
  }
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
