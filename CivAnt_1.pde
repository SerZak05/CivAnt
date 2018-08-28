final float HEX_SIDE_SIZE = 50; //<>//
Field field;

ArrayList<Entity> entities; 
Movable insect;

Hex targetHex; // Hex under mouse

void setup() {
  fullScreen();
  //shapeMode(CENTER);
  rectMode(CORNERS);
  textAlign( LEFT, TOP );
  field = new Field ( 10, 10 );

  entities = new ArrayList<Entity>();
  insect = new Movable ( "Insect", 0, 5, 3, 0 );
  entities.add(insect);

  targetHex = new Hex ( new PVector ( 0, 0 ), 0 );
}

void mouseReleased() {
  if ( mouseButton == LEFT ) {
    for ( Entity en : entities ) {
      en.isSelected = false;
    }
    if ( !targetHex.entities.isEmpty() ) {
      targetHex.entities.get(0).isSelected = true;
    }
  }
}

void draw() {
  targetHex = field.coorsToHex( mouseX, mouseY );

  background(0);
  field.draw();
  insect.update();
  insect.draw();
  if ( targetHex != null ) {
    //println ( targetHex.center );
    if ( targetHex.entities.contains(insect) ) {
      insect.displayInfo();
    }
  }
}