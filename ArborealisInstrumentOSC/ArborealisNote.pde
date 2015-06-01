/*
 * MIT License. Copyright (c) 2015 Greg Friedland
 */


// Definition of ArborealisNote interface from which instrument specific Note classes
// are implemented

interface ArborealisNote {
  void start();
  void stop();
  void update(float amplitude);
}


// Factory function to create a note of the correct type for the given instrument
ArborealisNote noteFactory(ArborealisInstrument instrument, int x, int y, float z) {
  ArborealisNote note = null;
  if (instrument.type() == InstrumentType.grainsynth)
  	note = new GrainSynthNote(instrument.getOutUgen(), x, y, z, instrument.numNotes(), instrument.getSample(x));
  else if (instrument.type() == InstrumentType.keyboard)
	  note = new KeyboardNote(instrument.getOutUgen(), x, y, z, instrument.numNotes(), instrument.getSample(x));
  else if (instrument.type() == InstrumentType.arpeggio)
	  note = new KeyboardNote(instrument.getOutUgen(), x, y, z, instrument.numNotes(), instrument.getSample(x));
  else
  	assert(false);

  return note;
}