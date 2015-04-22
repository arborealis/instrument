import oscP5.*;
import netP5.*;


// Manage parsing of OSC messages
class OSCListener {
  OscP5 oscP5;
  
  OSCListener(Object theParent, int port) {
    // start the osc server listening for incoming messages
    oscP5 = new OscP5(theParent, port);
  }
  
  // update the state by parsing an OSC command
  boolean updateState(NetAddress remoteAddress, String path, float[] args, ArborealisInstrument[] instruments) {
    // ignore some commands
    if (path.equals("/1") || path.equals("/2") || path.equals("/3") || path.equals("/4"))
      return true;
    
    // '/reset' will clear the instrument state and revert the TouchOSC ui to its initial state
    if (path.equals("/reset") && args.length == 1 && args[0] == 0) {
      sendReset(remoteAddress);
      for (int i = 0; i < instruments.length; i++)
        instruments[i].stopAll();
      return true;
    }
    
    // currently we understand two types of messages, e.g:
    //      /grainsynth/x1/sety 1.0     :     set the y value for x=1
    //      /grainsynth/x1/active  1.0  :     activate the player at x=1  
    String[] tokens = path.split("/");
    boolean valid = false;
    if (tokens.length == 5 && args.length == 1) {
      try {                      
        InstrumentType instrumentType = InstrumentType.valueOf(tokens[1]);
        ArborealisInstrument instrument = instruments[instrumentType.ordinal()];
        Command cmd = Command.valueOf(tokens[2]); 
        int y = int(tokens[3]) - 1;     
        int x = int(tokens[4]) - 1;
   
        y *= 2;
        
        assert(x >=0 && x <= NUM_X);
        assert(y >=0 && y <= NUM_Y);
        boolean on = args[0] != 0;
        
        valid = true;          
        
        switch(cmd) {
          case setone: 
            println("setone: instrument=" + instrumentType.ordinal() + ", x=" + x + ", y=" + y + ", state=" + on);
            
            if (instrumentType == InstrumentType.grainsynth) { // This is all we know how to handle so far
              if (on)
                instrument.start(x, y, 0, new GrainSynthNote(out, instrument.getSample(x)));
              else
                instrument.stop(x,y);
            } else {
              assert(false);
            }
            break;
        }
      } catch (IllegalArgumentException e) {
        valid = false;
      }
    }
    return valid;
  }
  
  // send the paths to each TouchOSC ui element followed by a 0 to return them to their initial states
  void sendReset(NetAddress address) {
    NetAddress address2 = new NetAddress(address.address(), 9000);
    
    println("Sending reset to " + address2.toString());
    for (InstrumentType it : InstrumentType.values())
      for (int x = 0; x < NUM_X; x++) {
        for (int y = 0; y < NUM_Y; y++) {
          String path = "/" + it;
          OscMessage msg = new OscMessage(path, new Object[] {new Integer(x), new Integer(y), new Integer(0)});
          println("Sending: " + msg.toString()); 
          this.oscP5.send(msg, address2);
        }
      }
  }  
}
