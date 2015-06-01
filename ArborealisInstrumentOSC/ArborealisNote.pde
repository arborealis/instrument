/*
 * MIT License (MIT). Copyright (c) 2015 Greg Friedland
 */

// Definition of ArborealisNote interface from which instrument specific Note classes
// are implemented

interface ArborealisNote {
  void start();
  void stop();
}


// Factory function to create a note of the correct type for the given instrument
ArborealisNote noteFactory(ArborealisInstrument instrument, int x, int y, float z) {
  if (instrument.type() == InstrumentType.grainsynth)
	return new GrainSynthNote(instrument.getOutUgen(), x, y, z, instrument.numNotes(), instrument.getSample(x));
  else if (instrument.type() == InstrumentType.keyboard)
	return new KeyboardNote(instrument.getOutUgen(), x, y, z, instrument.numNotes(), instrument.getSample(x));
  else if (instrument.type() == InstrumentType.arpeggio)
	return new KeyboardNote(instrument.getOutUgen(), x, y, z, instrument.numNotes(), instrument.getSample(x));
  else
  	assert(false);

  return null;
}