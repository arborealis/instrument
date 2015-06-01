/*
 * MIT License (MIT). Copyright (c) 2015 Greg Friedland
 */

// Main file for the ArborealisInstrumentOSC sketch
// Settings to customize can be found in Settings.pde

// features to add
// * global instrument volume control based on number of notes playing
// * only one high pass filter

import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.UGen;
import java.util.Arrays;
import oscP5.*;
import controlP5.*;

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
  frameRate(FPS);
  
  // create the graphics window
  size( 700, 400, P2D );
  
  // create the audio synthesis instance and the AudioOutput instance
  minim = new Minim( this );
  out = minim.getLineOut( Minim.MONO, 2048 );  

  // trigger the open file dialog or load the files directly
  for (InstrumentType instrumentType : InstrumentType.values()) {
    InstrumentSettings settings = instrumentSettings[instrumentType.ordinal()];
    if (settings.useFile.equals(""))
      selectInput("Select an audio file to use for the '" + instrumentType + "'", "create_" + instrumentType);
    else
      create_instrument(out, instrumentType, new File(sketchPath(settings.useFile)));
  }

  // start the osc server
  if (ENABLE_OSC) {
    oscP5 = new OscP5(this, OSC_RECEIVE_PORT);
    OSCListener list = new OSCListener(oscP5, instruments);
    oscP5.addListener(list);  
  }
  
  // create the settings controls
  createControls();
  
  // debugging: play a note on startup
  instruments[0].activate(1, 9, 0, noteFactory(instruments[0], 1, 9, 0));
}


// Create an instrument of the given type from a file
void create_instrument(AudioOutput out, InstrumentType instrumentType, File file) {
  if (file.exists()) {
    println("Creating instrument " + instrumentType + " from file: " + file.getPath());
    instruments[instrumentType.ordinal()] = instrumentFactory(out, instrumentType, file.getPath());
  } else {
    println("ERROR: unable to open sound file: " + file.getPath());;
  }
}


// This code is called by the selectInput() method when a file has been selected
void create_grainsynth(File file) {
  create_instrument(out, InstrumentType.grainsynth, file);
}
void create_keyboard(File file) {
  create_instrument(out, InstrumentType.keyboard, file);
}
void create_arpeggio(File file) {
  create_instrument(out, InstrumentType.arpeggio, file);
}
 

void triggerBeat() {
  for (ArborealisInstrument instrument : instruments)
    if (instrument != null) // if it's been initialized
      instrument.trigger();
}


void draw()
{
  // trigger beats on the BPM schedule
  if (millis() - lastBeatTime >= 60000 / BPM) {
    triggerBeat();
    lastBeatTime = millis();
  }

  background( 0 );
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

