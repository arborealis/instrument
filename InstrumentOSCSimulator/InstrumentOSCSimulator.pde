import oscP5.*;
import netP5.*;

static final int OSC_RECEIVE_PORT = 8000;
static final int OSC_SEND_PORT = 7000;
static final int NUM_X = 20;
static final int NUM_Y = 10;


OscP5 oscP5;
NetAddress sendAddress;


void setup()
{
  // call the draw() method at 30fps
  frameRate(30);
  
  // create the graphics window
  size( 1200, 600, P2D );

  oscP5 = new OscP5(this,OSC_RECEIVE_PORT);
  sendAddress = new NetAddress("127.0.0.1",OSC_SEND_PORT);  
}

void draw() {
  background(0); 

  stroke(255,255,255);
  for (int x = 1; x < NUM_X; x++)
    line(float(x)/NUM_X*width, 0, float(x)/NUM_X*width, height);
  for (int y = 1; y < NUM_Y; y++)
    line(0, float(y)/NUM_Y*height, width, float(y)/NUM_Y*height);

  // generate one data point from the cell containing current mouse position
  int mx = int(float(mouseX) / width * NUM_X);
  int my = int(float(mouseY) / height * NUM_Y);
  //println("Mouse position: " + mx + " " + my);

  // populate active cell as OSC string argument
  String arg = new String();
  for (int i = 0; i < NUM_X * NUM_Y; i++) {
    if (i > 0)
      arg += ",";

    int x = i % NUM_X;
    int y = i / NUM_X;
    if (x == mx && y == my)
      arg += "1";
    else
      arg += "0";
  }

  // populate active cell as OSC blob argument
  // byte[] arg = new byte[NUM_X * NUM_Y]; // initialized to zero
  // arg[mx + my * NUM_X] = byte(0xFF);

  // generate random data
  // for (int i = 0; i < NUM_X * NUM_Y; i++) {
  //   if (i > 0)
  //     dataStr += ",";
  //   dataStr += nf(random(1), 1, 2);
  // }

  //println("Sending: " + dataStr);
  OscMessage msg = new OscMessage("/A/C1");
  msg.add(arg);
  oscP5.send(msg, sendAddress); 
}


// Receive any incoming osc message
void oscEvent(OscMessage theOscMessage) {
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
}
