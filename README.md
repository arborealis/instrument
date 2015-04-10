## Instrument: Instrument code for the arborealis project


### Getting up to speed with Processing and Minim
0. [Processing examples](https://processing.org/examples/)
1. [Minim](http://code.compartmental.net/minim/)
2. [Minim ugens](http://code.compartmental.net/minim/index_ugens.html)
3. [Minim pydoc](http://code.compartmental.net/minim/javadoc/)
4. Minim examples: In ``Processing``, goto ``File``->``Examples...`` -> ``Minim`` -> ``Synthesis``

### Included sketch directories
* ArborealisInstrument: simulate the arborealis sound experience from the keyboard
* ArborealisInstrumentOSC: simulate the arborealis sound experience from a touch screen

*** 

### Components

####Simulator: allow simulation of the play-space using a touch screen
* Create a grid interface in TouchOSC, one for each instrument. 
* Touches will send updates to a Processing sketch in the form of /grainsynth/event touchnum xval yval

####Orchestra: coordinate the different instruments
* Integrate the different instrument code

####GrainSynthInstrument
* Split input sample into 20 equal spaced subsamples
* When a player is in x=i play ith subsample with looping indefinitely
* y=0->1 defines the fractional length of the subsample to play 
* There's no concept of beats per minute in this instrument, the tempo is defined fully by y
* e.g. if players exist at x=i,j; we play iiiii... at the same time as jjjjj...
* V2: What does z map to?

####ArpeggioInstrument
* Split input sample into subsamples separated by returns to zero
* Play subsamples corresponding to existence of player in x-space
* Subsample play order is defined by time of entrance into current x-bins
* Master tempo defines time interval between subsample beats, but the subsample does continue
  playing into the next time interval if it's longer than the beat (polyphony)
* e.g. if player1 in x=i then play iiiiii... 
       if player2 then enters x=j, play ijijij...
       if player3 then enters x=k, play ijkijkijk...
       if player2 moves to k=h, play ikhikh... 
* y=0->1 defines the fractional length of the subsample to play
* V2: z=0->1 defines the volume of that subsample

####PianoInstrument
* Split input sample into subsamples separated by returns to zero
* When player enters x=i, play ith subsample at the next beat; 
  nothing happens if player doesn't move
* Subsample doesn't start exactly on entering an x-space but waits for end of current beat
  defined by the master tempo
* Subsamples continue playing into the next time interval if they are longer than the beat (polyphony)
* If multiple notes are triggered by a player on the same beat, only the last one will play in the next beat. e.g. player runs from x=2->7 in same beat, just play 2 then 7
* Two players moving to new x-spaces at the same time will cause two subsamples to be played
  with their onsets synchronized
* y=0->1 defines the fractional length of the subsample to play (or low-pass filter)
* Problem?: we are unlikely to track players so what if player1 x=2->3 and player 2 x=3->2;
  no change will be identified and no note will be played
