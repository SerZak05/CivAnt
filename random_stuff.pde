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