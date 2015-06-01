## ArborealisInstrumentOSC

Play the arborealis instruments in response to OSC messages. 

The OSC messages can come from: 
* the entoptic motion detection OpenCV program
* the InstrumentOSCSimulator sketch
* a mobile app that can send OSC on touch input (e.g. [TouchOSC](http://hexler.net/software/touchosc), or [Lemur](https://liine.net/en/products/lemur/)), and potentially other ways TBD. 

The instructions below describe how to get this working.

### General Setup instructions
0. Download the [code](https://github.com/arborealis/instrument/archive/master.zip) in this github repo
1. Install [Processing](https://processing.org/download/) on your pc
2. Install the Processing libraries [Minim](https://github.com/ddf/Minim/archive/v2.2.0.zip), [OscP5](http://www.sojamo.de/libraries/oscP5/download/oscP5-0.9.8.zip), and [ControlP5](http://www.sojamo.de/libraries/controlP5/download/controlP5-2.0.4.zip) on your pc as described [here](https://github.com/processing/processing/wiki/How-to-Install-a-Contributed-Library)

### Setup instructions for using TouchOSC
This allows 'playing' the instruments with a touch screen to simualate the arborealis experience. 
1. Install TouchOSC editor for [Mac](http://hexler.net/mint/pepper/orderedlist/downloads/download.php?file=http%3A//hexler.net/pub/touchosc/touchosc-editor-1.7.0-osx.zip) or [Windows](http://hexler.net/pub/touchosc/touchosc-editor-1.7.0-win32.zip) on your pc
2. Install [TouchOSC](https://itunes.apple.com/app/touchosc/id288120394) on your mobile device
3. Configure TouchOSC
  1. Run the app and enter the settings screen if you're not already there (dot in the upper right)
  2. Select the first entry under ``Connections`` labelled ``OSC::...``
  3. Drag ``Enabled`` to on; set ``Host`` to your hostname or IP address (which you can find [this way](http://whatismyip.org/) or [this way](https://kb.iu.edu/d/aapa)); make sure ``Port (outgoing)`` is set to ``8000`` and ``Port (incoming)`` is ``9000``
4. Setup the TouchOSC layout
  1. Open ``arborealis-simulator-iphone.touchosc`` from this directory in TouchOSC Editor
  2. Click ``Sync`` on the toolbar
  3. On your mobile device in the TouchOSC app, select the active Layout under ``Layouts``
  4. Select ``Add`` and choose your computer from the list
  5. Scroll down to the bottom of the list of Layouts and select ``arborealis-simulator-iphone.touchosc``
  6. Select ``Done`` to go back to the UI screen; you should now see the ``GrainSynth`` tab in the layout with a bunch of red sliders and checkboxes

### Run instructions for using TouchOSC
1. Open ``ArborealisInstrument/ArborealisInstrumentOSC.pde`` in Processing on your pc
2. Click the play button to start the sketch
3. On your mobile device, open ``TouchOSC`` and go to the main screen with the sliders
4. Select the instrument you'd like to experiment with from the tab bar (currently only ``GrainSynth`` is implemented)
5. The checkboxes activate a player in an ``x``-space; the sliders change the ``y``-value of that player (sliders at the lowest value do not activate the player)
6. Only one player can exist in an ``x``-space in this simulator
7. Play!