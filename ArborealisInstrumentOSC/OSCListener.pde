import oscP5.*;
import netP5.*;


// Manage parsing of OSC messages
class OSCListener {
  OscP5 oscP5;
  NetAddress remoteAddress;
  
  OSCListener(Object theParent, int port) {
    // start the osc server listening for incoming messages
    oscP5 = new OscP5(theParent, port);
  }
  

  // update the state by parsing an OSC command
  boolean updateState(NetAddress remoteAddress, String path, float[] args, ArborealisInstrument[] instruments) {
    this.remoteAddress = remoteAddress;
    println("path: " + path);
    String[] tokens = path.split("/");
    println("token1: " + tokens[1]);
    assert(tokens[0].equals(""));
    tokens = Arrays.copyOfRange(tokens, 1, tokens.length);

    if (parseTouchOSCEvent(tokens, args))
      return true;

    if (parseCameraInput(tokens, args))
      return true;

    return false;
  }
  

  boolean parseCameraInput(String[] tokens, float[] args) {
    return false;
  }


  boolean parseTouchOSCEvent(String[] tokens, float[] args) {
    // ignore some commands
    if (tokens.length == 1 && (tokens[0].equals("1") || tokens[0].equals("2") || tokens[0].equals("3") || tokens[0].equals("4")))
      return true;
    
    // '/reset' will clear the instrument state and revert the TouchOSC ui to its initial state
    if (tokens.length == 1 && tokens[0].equals("reset")) {
      sendReset(remoteAddress);

      for (int i = 0; i < instruments.length; i++)
        instruments[i].stopAll();
      return true;
    }    

    // format: /grainsynth/setone/x/y state
    if (tokens.length == 4 && args.length == 1) {
      try {                      
        InstrumentType instrumentType = InstrumentType.valueOf(tokens[0]);
        println("instrument: " + instrumentType);
        ArborealisInstrument instrument = instruments[instrumentType.ordinal()];
        String cmd = tokens[1]; 
        println("cmd: " + cmd);
        int y = int(tokens[2]) - 1;     
        int x = int(tokens[3]) - 1;
        println("x: " + x + " y: " + y + " val: " + args[0]);
   
        y *= 2; // The TouchOSC keyboard only has 5 y values to extend its range
        
        assert(x >=0 && x <= NUM_X);
        assert(y >=0 && y <= NUM_Y);
        boolean on = args[0] != 0;
        
        if (!cmd.equals("setone"))
          return false;

        println("setone: instrument=" + instrumentType.ordinal() + ", x=" + x + ", y=" + y + ", state=" + on);
        
        if (instrumentType == InstrumentType.grainsynth) { // This is all we know how to handle so far
          if (on)
            instrument.start(x, y, 0, new GrainSynthNote(out, instrument.getSample(x)));
          else
            instrument.stop(x,y);
        }

        return true;
      } catch (IllegalArgumentException e) {
        return false;
      }
    }    
    return false;
  }

  // send the paths to each TouchOSC ui element followed by a 0 to return them to their initial states
  void sendReset(NetAddress address) {
    NetAddress address2 = new NetAddress(address.address(), OSC_SEND_PORT);
    
    println("Sending reset to " + address2.toString());
    for (InstrumentType it : InstrumentType.values())
      for (Command cmd : Command.values())
        for (int x = 0; x < NUM_X; x++) {
          for (int y = 0; y < NUM_Y; y++) {
            String path = "/" + it + "/" + cmd;
            OscMessage msg = new OscMessage(path);
            msg.add(x);
            msg.add(y);
            msg.add(0);
            println("Sending: " + msg.toString()); 
            this.oscP5.send(msg, address2);
          }
        }
  }  
}
