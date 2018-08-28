class Entity {
  String name;
  int x, y; // current position on the field
  boolean isSelected = false;
  Entity ( String name, int x_, int y_ ) {
    this.name = name;
    x = x_;
    y = y_;
    field.hexes[x][y].entities.add(this);
  }
  void displayInfo() {
  }
  void displayMenu() {
  }

  void draw() {
  }
}

class Movable extends Entity {
  int speed, MP, size; //MP (move points) - current state

  Movable ( String name, int x, int y, int speed, int size ) {
    super ( name, x, y );
    this.speed = speed;
    MP = speed;
    this.size = size;
  }

  void displayInfo() {
    fill ( 255, 255, 0 );
    rect ( 0, height, width/4, 3*height/4 );
    fill ( 0 );
    textSize( 60 );
    text ( name, 10, 3*height/4 + 10 );
    float first_vert_sz = textAscent()+textDescent();
    textSize ( 40 );
    text ( "Speed: " + speed, 10, 3*height/4 + first_vert_sz );
    float sec_vert_sz = textAscent()+textDescent();
    text ( "Size: " + size, 10, 3*height/4 + first_vert_sz + sec_vert_sz );
  }

  void displayMenu() {
    fill ( 255, 100, 0 );
    rect ( 3*width/4, 0, width, height );
    fill ( 0 );
    textSize( 60 );
    text ( name, 3*width/4+10, 10 );
    float first_vert_sz = textAscent()+textDescent();
    textSize( 40 );
    text ( "MP: " + MP + " / " + speed, 3*width/4+10, 10+first_vert_sz );
  }

  void move( int tx, int ty ) {
    ArrayList<PVector> path = field.path( x, y, tx, ty, size );
  }

  void update() {
    if ( isSelected ) {
      displayMenu();
    }
  }

  void draw() {
    fill( 255 );
    ellipse( field.hexes[x][y].center.x + HEX_SIDE_SIZE, field.hexes[x][y].center.y, HEX_SIDE_SIZE, HEX_SIDE_SIZE );
  }
}