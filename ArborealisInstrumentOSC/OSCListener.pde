import netP5.*;


// Manage parsing of OSC messages
class OSCListener implements OscEventListener {
  OscP5 oscP5;
  NetAddress remoteAddress;
  ArborealisInstrument[] instruments;
  
  OSCListener(OscP5 oscP5, ArborealisInstrument[] instruments) {
    this.oscP5 = oscP5;
    this.instruments = instruments;
  }

  // called behind the scenes by oscP5
  void oscEvent(OscMessage msg) {
    try {
      OscArgument[] args = new OscArgument[msg.arguments().length];
      for (int i = 0; i < msg.arguments().length; i++)
        args[i] = msg.get(i);

      // store the remote address for sending unsolicited messages to
      remoteAddress = msg.netAddress();

      // check for incoming OSC messages and update the instruments' states
      boolean valid = updateState(msg.addrPattern(), args);
          
      if (!valid) {
        println("OSC: Invalid message=" + msg.toString());
      }
    } catch (Exception e) {
      println("OSC: exception=" + e);
      for (StackTraceElement elem : e.getStackTrace())
        println("    " + elem);
    }
  }

  void oscStatus(OscStatus theStatus) {
    println("OSC: status=" + theStatus.id());
  }  

  // update the state by parsing an OSC command
  boolean updateState(String path, OscArgument[] args) {
    //println("OSC message path: " + path);
    String[] tokens = path.split("/");
    //println("token1: " + tokens[1]);
    assert(tokens[0].equals(""));
    tokens = Arrays.copyOfRange(tokens, 1, tokens.length);

    if (parseTouchOSCEvent(tokens, args, instruments))
      return true;

    if (parseCameraInput(tokens, args, instruments))
      return true;

    return false;
  }
  

  boolean parseCameraInput(String[] tokens, OscArgument[] args, ArborealisInstrument[] instruments) {
    if (tokens.length == 2 && args.length == 1) {
      try {
        InstrumentType instrumentType = InstrumentType.grainsynth;
        ArborealisInstrument instrument = instruments[instrumentType.ordinal()];

        // parse input as string
        String str = args[0].stringValue();
        String[] strVals = str.split(",");
        assert(strVals.length == NUM_X * NUM_Y);
        //println("Received camera input: " + vals.length + " values");

        for (int i = 0; i < strVals.length; i++) {
          int x = i % NUM_X;
          int y = i / NUM_X;
          float val = float(strVals[i]);

          if (instrumentType == InstrumentType.grainsynth) { // This is all we know how to handle so far
            if (val > 0)
              instrument.activate(x, y, val, new GrainSynthNote(out, instrument.getSample(x)));
            else
              instrument.deactivate(x,y);
          }
        }
  
        // // parse input as blob
        // byte[] data = args[0].blobValue();
        // assert(data.length == NUM_X * NUM_Y);
        // //println("Received camera input: " + vals.length + " values");

        // for (int i = 0; i < data.length; i++) {
        //   int x = i % NUM_X;
        //   int y = i / NUM_X;
        //   float val = float(data[i]) / 255;

        //   if (instrumentType == InstrumentType.grainsynth) { // This is all we know how to handle so far
        //     if (val > 0)
        //       instrument.activate(x, y, val, new GrainSynthNote(out, instrument.getSample(x)));
        //     else
        //       instrument.deactivate(x,y);
        //   }
        // }

        return true;
      } catch (IllegalArgumentException e) {
       return false;
      }
    }

    return false;
  }


  boolean parseTouchOSCEvent(String[] tokens, OscArgument[] args, ArborealisInstrument[] instruments) {
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
        //println("instrument: " + instrumentType);
        ArborealisInstrument instrument = instruments[instrumentType.ordinal()];
        String cmd = tokens[1]; 
        //println("cmd: " + cmd);
        int y = int(tokens[2]) - 1;     
        int x = int(tokens[3]) - 1;
   
        y *= 2; // The TouchOSC keyboard only has 5 y values to extend its range
        //println("x: " + x + " y: " + y + " val: " + args[0].floatValue());
        
        assert(x >=0 && x <= NUM_X);
        assert(y >=0 && y <= NUM_Y);
        boolean on = args[0].floatValue() != 0;
        
        if (!cmd.equals("setone"))
          return false;

        println("OSC: TouchOSC event instrument=" + instrumentType.ordinal() + ", x=" + x + ", y=" + y + ", state=" + on);
        
        if (instrumentType == InstrumentType.grainsynth) { // This is all we know how to handle so far
          if (on)
            instrument.activate(x, y, 0, new GrainSynthNote(out, instrument.getSample(x)));
          else
            instrument.deactivate(x,y);
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
            oscP5.send(msg, address2);
          }
        }
  }  
}
