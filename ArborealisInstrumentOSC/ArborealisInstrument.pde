import java.util.*;

// keep track of all notes being played by an instrument: where each xy space maps to one possible note
class ArborealisInstrument {
  private ArborealisNote[][] notes = new ArborealisNote[NUM_X][NUM_Y];
  private MultiChannelBuffer[] bufs;
  int activeCount = 0;
  
  ArborealisInstrument(MultiChannelBuffer[] bufs) {
    this.bufs = bufs;
  }
  
  // stop all instruments
  void stopAll() {
    for (int x = 0; x < NUM_X; x++)
      for (int y = 0; y < NUM_Y; y++)
        stop(x,y);
  }
 
  MultiChannelBuffer getSample(int x) {
    return bufs[x];
  }
  
  void start(int x, int y, float z, ArborealisNote note) {
    assert(notes[x][y] == null);
    activeCount++;
    note.start(x, y, z, activeCount);
    notes[x][y] = note;
  }
  
  void stop(int x, int y) {
    if (notes[x][y] != null) {
      activeCount--;
      notes[x][y].stop();
      notes[x][y] = null;
    }
  }
}