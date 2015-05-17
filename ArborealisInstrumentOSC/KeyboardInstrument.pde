class KeyboardInstrument extends ArborealisInstrument {
	KeyboardInstrument(MultiChannelBuffer[] bufs) {
		super(InstrumentType.keyboard, bufs);
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