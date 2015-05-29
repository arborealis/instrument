class KeyboardInstrument extends ArborealisInstrument {
	boolean[][] active = new boolean[NUM_X][NUM_Y];
	ArrayList<ArborealisNote> notesToStop = new ArrayList<ArborealisNote>();

	KeyboardInstrument(AudioOutput out, MultiChannelBuffer[] bufs) {
		super(out, InstrumentType.keyboard, bufs);
	}

  // this is called to add a note, but we don't start playing it immediately
  void activate(int x, int y, float z, ArborealisNote note) {
  	if (notes[x][y] == null && !active[x][y]) {
  		println("Activating keyboard note at (" + x + "," + y + ")");
	    notes[x][y] = note;
	    activeCount++;
      updateAll();
	  }
	}

  // this is called to remove a note; for this instrument the note 
  // removes itself after it starts playing
  void deactivate(int x, int y) {
  	// nothing happens for the keyboard when the note disappears
  	// except we update the status so it can get triggered again
  	if (active[x][y]) {
	  	println("Deactivating keyboard note at (" + x + "," + y + ")");
		  active[x][y] = false;
		}
  }

  // this gets called every beat
  void trigger() {
  	// stop active notes that were already played
  	for (int i = 0; i < notesToStop.size(); i++)
  		notesToStop.get(i).stop();
  	notesToStop.clear();

		// start active notes that haven't been played and mark them as played
    for (int x = 0; x < NUM_X; x++)
      for (int y = 0; y < NUM_Y; y++)
        if (notes[x][y] != null && !active[x][y]) {
			    // the note plays once then disappears        	
		  		println("Starting keyboard note at (" + x + "," + y + ")");
        	notes[x][y].start();
        	active[x][y] = true;
        	
        	notesToStop.add(notes[x][y]);
        	notes[x][y] = null;
        }
  }
};

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