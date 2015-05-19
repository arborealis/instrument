class KeyboardInstrument extends ArborealisInstrument {
	boolean[][] status = new boolean[NUM_X][NUM_Y];

	KeyboardInstrument(MultiChannelBuffer[] bufs) {
		super(InstrumentType.keyboard, bufs);
	}

  void activate(int x, int y, float z, ArborealisNote note) {
  	if (!status[x][y]) {
	  	super.activate(x, y, z, note);
	  	status[x][y] = true;
	  }
	}

  void deactivate(int x, int y) {
  	if (status[x][y]) {
	  	super.deactivate(x, y);
	  	status[x][y] = false;
	  }
	}

	void trigger() {
    for (int x = 0; x < NUM_X; x++)
      for (int y = 0; y < NUM_Y; y++)
        if (notes[x][y] != null) {
        	notes[x][y].start();
        	notes[x][y] = null; // the note plays once then disappears
        }
	}
}

// class ArpeggioInstrument extends ArborealisInstrument {
// 	KeyboardInstrument(MultiChannelBuffer[] bufs) {
// 		super(InstrumentType.arpeggio, bufs);
// 	}

// 	void trigger() {
//     for (int x = 0; x < NUM_X; x++)
//       for (int y = 0; y < NUM_Y; y++)
//         if (notes[x][y] != null) {
//         	notes[x][y].start();
//         	notes[x][y] = null; // the note plays once then disappears
//         }
// 	}
// }