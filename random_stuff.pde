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

class Button {
  PVector coor;
  float sizeX, sizeY;
  String name;
  Button ( String name, float x, float y, float sx, float sy ) {
    coor = new PVector ( x, y );
    sizeX = sx;
    sizeY = sy;
    this.name = name;
  }

  boolean isPressed () {
    return mousePressed && mouseX > coor.x && mouseX < coor.x + sizeX && mouseY > coor.y && mouseY < coor.y + sizeY;
  }

  void draw() {
    pushStyle();
    rectMode ( CORNER );
    rect ( coor.x, coor.y, sizeX, sizeY );
    fill(0);
    text ( name, coor.x, coor.y );
    popStyle();
  }
}