interface ArborealisNote {
  void start();
  void stop();
//  void update(int numNotes);
}

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