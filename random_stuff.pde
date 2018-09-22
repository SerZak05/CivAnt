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

// just a button
class Button {
  PVector coor;
  float sizeX;
  String name;
  Button ( String name, float x, float y, float sx ) {
    coor = new PVector ( x, y );
    sizeX = sx;
    this.name = name;
  }

  boolean isPressed () {
    return false;
  }

  void draw() {
  }
}

class RectButton extends Button {
  float sizeY;
  RectButton ( String name, float x, float y, float sx, float sy ) {
    super ( name, x, y, sx );
    sizeY = sy;
  }

  boolean isPressed() {
    return mousePressed && mouseX-camPos.x > coor.x && mouseX-camPos.x < coor.x + sizeX && 
      mouseY-camPos.y > coor.y && mouseY-camPos.y < coor.y + sizeY;
  }
  boolean isPressed( int notMoved ) {
    return mousePressed && mouseX > coor.x && mouseX < coor.x + sizeX && 
      mouseY > coor.y && mouseY < coor.y + sizeY;
  }

  void draw() {
    pushStyle();
    rectMode ( CORNER );
    rect ( coor.x, coor.y, sizeX, sizeY );
    fill(255);
    text ( name, coor.x, coor.y );
    popStyle();
  }
}

class CircButton extends Button {
  CircButton ( String name, float x, float y, float size ) {
    super ( name, x, y, size );
  }

  CircButton ( String name, PVector coor, float size ) {
    super ( name, coor.x, coor.y, size );
  }
  boolean isPressed() {
    return mousePressed && dist ( coor.x, coor.y, mouseX-camPos.x, mouseY-camPos.y ) < sizeX/2;
  }
  boolean isPressed( int notMoved ) {
    return mousePressed && dist ( coor.x, coor.y, mouseX, mouseY ) < sizeX/2;
  }

  void draw() {
    ellipse ( coor.x, coor.y, sizeX, sizeX );
    fill ( 255 );
    text ( name, coor.x - textWidth(name), coor.y );
  }
}


class CustomButton extends Button {
  ArrayList<Button> parts;
  CustomButton ( String name, float x, float y, ArrayList p ) {
    super ( name, x, y, 0 );
    parts = p;
  }
  CustomButton ( String name, PVector coor, ArrayList p ) {
    super ( name, coor.x, coor.y, 0 );
    parts = p;
  }

  boolean isPressed() {
    for ( Button button : parts ) {
      if ( button.isPressed() ) return true;
    }
    return false;
  }

  void draw() {
    for ( Button button : parts ) {
      pushStyle();
      button.draw();
      popStyle();
    }
    fill ( 255 );
    text ( name, coor.x, coor.y );
  }
}