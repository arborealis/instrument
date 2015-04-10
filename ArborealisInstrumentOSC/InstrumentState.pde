import java.util.*;

// store the state of a single player
class Player {
  int x, y;
  float z;
  boolean active;
  
  Player(int x, int y, float z, boolean active) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.active = active;
  }
  
  void reset() {
    this.y = 0; 
    this.z = 0;
    this.active = false;
  }
}

// store the entire state of an instrument: where are each of the players
// some of the methods such as setY and setActive are meant only for use with the simulator
// which only supports one player in an X-bin at a time.
class InstrumentState {
  private ArrayList players;
  
  InstrumentState() {
    this.players = new ArrayList();
  }
  
  // remove all players
  void clear() {
    players.clear();
  }
 
  // reset all players to be inactive
  void reset() {
    for (Object obj : players) {
      ((Player) obj).reset();
    }
  }
  
  List getAllPlayers() {
    return Collections.unmodifiableList(players);
  }
  
  // Get the first player with the given x
  // mostly useful when using the Simulator because for that we assume only one player per x-bin
  Player getFirstPlayer(int x) {
    for (int i = 0; i < this.players.size(); i++) {
      Player player = (Player) this.players.get(i);
      if (player.x == x)
        return player;
    }
    Player player = new Player(x,0,0,false);
    this.players.add(player);
    return player;
  }

  // stub for future method that will update the state (including removing untracked players)
  void updateState(float[][] xyz) {
  }
}
