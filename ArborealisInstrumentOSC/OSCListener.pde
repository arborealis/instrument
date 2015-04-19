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
  boolean updateState(NetAddress remoteAddress, String path, float[] args, InstrumentState[] instrumentStates) {
    // ignore some commands
    if (path.equals("/1") || path.equals("/2") || path.equals("/3") || path.equals("/4"))
      return true;
    
    // '/reset' will clear the instrument state and revert the TouchOSC ui to its initial state
    if (path.equals("/reset") && args.length == 1 && args[0] == 0) {
      sendReset(remoteAddress);
      for (int i = 0; i < instrumentStates.length; i++)
        instrumentStates[i].reset();
      return true;
    }
    
    // currently we understand two types of messages, e.g:
    //      /grainsynth/x1/sety 1.0     :     set the y value for x=1
    //      /grainsynth/x1/active  1.0  :     activate the player at x=1  
    String[] tokens = path.split("/");
    boolean valid = false;
    if (tokens.length == 4 && args.length == 1) {
      try {              
        InstrumentType instrumentType = InstrumentType.valueOf(tokens[1]);
        InstrumentState instState = instrumentStates[instrumentType.ordinal()];
        XVal xval = XVal.valueOf(tokens[2]);
        Command cmd = Command.valueOf(tokens[3]);      
     
        int arg = (int) args[0];        
        valid = true;
          
        switch(cmd) {
          case sety: 
            println("sety: instrument=" + instrumentType.ordinal() + ", x=" + xval.ordinal() + ", arg=" + arg);
            instState.getFirstPlayer(xval.ordinal()).y = arg;
            break;
          case active:
            println("active: instrument=" + instrumentType.ordinal() + ", x=" + xval.ordinal() + ", arg=" + arg);
            instState.getFirstPlayer(xval.ordinal()).active = (arg != 0);
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
      for (XVal xval : XVal.values())
        for (Command cmd : Command.values()) {
          String path = "/" + it + "/" + xval + "/" + cmd;
          OscMessage msg = new OscMessage(path, new Object[] {new Float(0)});
          //println("Sending: " + msg.toString()); 
          this.oscP5.send(msg, address2);
        }
  }  
}
