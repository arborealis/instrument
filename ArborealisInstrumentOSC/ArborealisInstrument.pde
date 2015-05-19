ArborealisInstrument instrumentFactory(InstrumentType instrumentType, String filename) {
  InstrumentSettings settings = instrumentSettings[instrumentType.ordinal()];

  if (instrumentType == InstrumentType.grainsynth)
    return new ArborealisInstrument(instrumentType, parseSampleFile(filename, false));
  else if (instrumentType == InstrumentType.keyboard)
    return new KeyboardInstrument(parseSampleFile(filename, true));
  else if (instrumentType == InstrumentType.arpeggio)
    return new KeyboardInstrument(parseSampleFile(filename, true));
  else
    assert(false);
  return null;
}

// keep track of all notes being played by an instrument: where each xy space maps to one possible note
class ArborealisInstrument {
  protected ArborealisNote[][] notes;
  protected MultiChannelBuffer[] bufs;
  protected int activeCount = 0;
  protected InstrumentType type;

  ArborealisInstrument(InstrumentType type, MultiChannelBuffer[] bufs) {
    this.bufs = bufs;
    this.type = type;
    notes = new ArborealisNote[NUM_X][NUM_Y];
  }
  
  // stop all instruments
  void stopAll() {
    for (int x = 0; x < NUM_X; x++)
      for (int y = 0; y < NUM_Y; y++)
        if (notes[x][y] != null) {
          activeCount--;
          notes[x][y].stop();
          notes[x][y] = null;
        }
    updateAll();
  }
 
  void updateAll() {
    //println("INSTRUMENT: updating notes");
    for (int x = 0; x < NUM_X; x++)
      for (int y = 0; y < NUM_Y; y++)
        if (notes[x][y] != null)
          notes[x][y].update(activeCount);
  }

  MultiChannelBuffer getSample(int x) {
    return bufs[x];
  }
  
  void activate(int x, int y, float z, ArborealisNote note) {
    if (notes[x][y] != null)
    {
      if (VERBOSE) println("INSTRUMENT: ignoring note (" + x + "," + y + ") because already playing");
      return;
    }

    // don't activate this note if there is already a note with the same x and higher y
    for (int y2 = y+1; y2 < NUM_Y; y2++)
      if (notes[x][y2] != null)
      {
        if (VERBOSE) println("INSTRUMENT: ignoring note (" + x + "," + y + ") because higher y note is playing at same x");        
        return;
      }

    // stop notes with the same x but lower y
    for (int y2 = 0; y2 < NUM_Y; y2++)
      if (notes[x][y2] != null) {
        if (VERBOSE) println("INSTRUMENT: deactivating note (" + x + "," + y2 + ") because about to play higher y note with same x");
        deactivate(x, y);
      }

    activeCount++;
    updateAll();

    if (VERBOSE) println("INSTRUMENT: activating note (" + x + "," + y + ")");
    note.start();
    notes[x][y] = note;
  }
  
  void deactivate(int x, int y) {
    if (notes[x][y] == null) 
      return;

    activeCount--;
    notes[x][y].stop();
    notes[x][y] = null;
    updateAll();
  }

  int numNotes() { return activeCount; }

  void trigger() {}

  InstrumentType type() { return type; }
}
