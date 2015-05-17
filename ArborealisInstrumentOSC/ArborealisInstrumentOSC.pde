// Main file for the ArborealisInstrumentOSC sketch

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
AudioRecorder recorder = null;
int lastBeatTime = millis();

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

  // trigger the open file dialog or load the files directly
  for (InstrumentType instrumentType : InstrumentType.values()) {
    InstrumentSettings settings = instrumentSettings[instrumentType.ordinal()];
    if (settings.useFile.equals(""))
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
 

void triggerBeat() {
  for (ArborealisInstrument instrument : instruments)
    if (instrument != null) // if it's been initialized
      instrument.trigger();
}

// draw the music visualizer to the screen
void draw()
{
  if (millis() - lastBeatTime >= 60000 / BPM) {
    triggerBeat();
    lastBeatTime = millis();
  }

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
    if (recorder == null)
      recorder = minim.createRecorder(out, "arborealis-recorded.wav");      
    else {
      recorder.endRecord();
      recorder.save();
      println("RECORD: file saved");
    }

    recorder.beginRecord();
    println("RECORD: started");
  }
}  