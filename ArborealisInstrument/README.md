## ArborealisInstrument 

### Setup instructions

0. Download the [code](https://github.com/arborealis/instrument/archive/master.zip) in this github repo
1. Install [Processing](https://processing.org/download/)
2. Install [Minim](http://code.compartmental.net/tools/minim/) and [OscP5](http://www.sojamo.de/libraries/oscP5/)

### Run instructions
1. Run the ``ArborealisInstrument/ArborealisInstrument.pde`` sketch
2. In the select file dialog, open an audio file to use for the ``GrainSynth`` (e.g. ``samples/GRAIN.WAV``)
3. Hold down and release any of the ``0`` through ``9`` keys to simulate a player in that ``x``-space. The length of the time the key is held down (up to 1 second) determines its ``y``-value, which in this case varies the length of the section of the sample to loop. Press and release the same key to disable that ``x``-space.
