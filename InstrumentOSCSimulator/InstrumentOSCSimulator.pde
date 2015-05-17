import oscP5.*;
import netP5.*;

static final int OSC_RECEIVE_PORT = 8000;
static final int OSC_SEND_PORT = 7000;
static final int NUM_X = 20;
static final int NUM_Y = 10;
static final int NUM_INST = 3;
static final int WIDTH = 1400;
static final int CELL_SIZE = WIDTH / NUM_INST / (NUM_X + 1);
static final int BORDER = CELL_SIZE;
static final int GRID_WIDTH = WIDTH / NUM_INST - BORDER;

OscP5 oscP5;
NetAddress sendAddress;


void setup()
{
  // call the draw() method at 30fps
  frameRate(30);
  
  // create the graphics window
  size( WIDTH, WIDTH/NUM_INST*NUM_Y/NUM_X, P2D );

  oscP5 = new OscP5(this,OSC_RECEIVE_PORT);
  sendAddress = new NetAddress("127.0.0.1",OSC_SEND_PORT);  
}

void draw() {
  background(0); 

  for (int i = 0; i < NUM_INST; i++) {
    stroke(255,255,255);
    for (int x = 0; x <= NUM_X; x++) {
      float xx = float(x)/NUM_X*GRID_WIDTH + GRID_WIDTH*i + BORDER*i;
      line(xx, 0, xx, height);
    }
    for (int y = 0; y <= NUM_Y; y++) {
      line(i*GRID_WIDTH+BORDER*i, float(y)/NUM_Y*height, (i+1)*GRID_WIDTH+BORDER*i, float(y)/NUM_Y*height);
    }
  }

  // generate one data point from the cell containing current mouse position
  int instrument = mouseX / (width / NUM_INST);
  int mx = (mouseX * (NUM_X+1) / (width / NUM_INST)) % (NUM_X+1);
  int my = NUM_Y - 1 - int(float(mouseY) / height * NUM_Y); // flip y axis
  //println("Mouse position: instrument=" + instrument + " mx=" + mx + " my=" + my);

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
  OscMessage msg = new OscMessage("/A/C" + instrument);
  msg.add(arg);
  oscP5.send(msg, sendAddress); 
}


// Receive any incoming osc message
void oscEvent(OscMessage theOscMessage) {
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
}
