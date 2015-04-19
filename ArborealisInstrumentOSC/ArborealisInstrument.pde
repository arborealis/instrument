import java.util.*;

// keep track of all notes being played by an instrument: where each xy space maps to one possible note
class ArborealisInstrument {
  private ArborealisNote[][] notes = new ArborealisNote[NUM_X][NUM_Y];
  private MultiChannelBuffer[] bufs;
  
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
  
  void start(int x, int y, int z, ArborealisNote note) {
    note.start(x, y, z);
    notes[x][y] = note;
  }
  
  void stop(int x, int y) {
    if (notes[x][y] != null) {
      notes[x][y].stop();
      notes[x][y] = null;
    }
  }
}
