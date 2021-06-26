class HexCoor {
  int x, y;
  HexCoor ( int x, int y ) {
    this.x = x;
    this.y = y;
  }
  int dist ( HexCoor hex ) {
    int xSteps = x-hex.x;
    int ySteps = y-hex.y;
    //println( "xSteps:", xSteps, "ySteps", ySteps );
    if ( (xSteps >= 0 && ySteps >= 0) || (xSteps <= 0 && ySteps <= 0) ) {
      return xSteps + ySteps;
    } else {
      int diagSteps = min( abs(xSteps), abs(ySteps) );
      //println("DiagSteps:", diagSteps);
      return diagSteps + abs(abs(xSteps)-abs(ySteps));
    }
  }
}

// used in A* alg. //
class Node {
  int x, y, px, py;
  int F, G, H; // costs
  Node ( int x_, int y_, int px_, int py_ ) {
    x = x_;
    y = y_;
    px = px_;
    py = py_;
    F = G = H = 0;
  }
}
