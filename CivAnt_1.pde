final float HEX_SIDE_SIZE = 50; //<>// //<>//
Field field;

ArrayList<Entity> entities;

Movable insect;
Hex targetHex;

void setup() {
  fullScreen();
  //shapeMode(CENTER);
  rectMode(CORNERS);
  textAlign( LEFT, TOP );
  field = new Field ( 10, 10 );

  entities = new ArrayList<Entity>();
  insect = new Movable ( "Insect", 0, 5, 3, 2, 0 );
  entities.add(insect);
  //entities.add ( new Movable ( "Long name of an ant", 4, 3, 4, 0 ) );
  entities.add ( new Nest ( "Nest", 4, 5 ) );

  targetHex = new Hex ( new PVector ( 0, 0 ), 0 );
}

void keyPressed () {
  // next turn
  if ( key == ' ' ) {
    for ( int i = 0; i < entities.size(); i++ ) {
      entities.get(i).nextTurn();
    }
  }
}

void mousePressed() {
  if ( mouseButton == LEFT ) {
    boolean isIconPressed = false;
    for ( Entity en : entities ) {
      en.isSelected = false;
      en.updateMenu();
      if ( en.icon == null ) continue;
      //pushMatrix();
      //translate ( field.hexes[en.x][en.y].center.x, field.hexes[en.x][en.y].center.y );
      if ( en.icon.isPressed() ) {
        en.isSelected = en.canBeSetlected;
      }
      //println ( mouseX, mouseY );
      //popMatrix();
    }

    //if ( targetHex != null && !targetHex.entities.isEmpty()) {
    //  // select an entity by LMB
    //  targetHex.entities.get(0).isSelected = targetHex.entities.get(0).canBeSelected;
    //}
  }
}

void draw() {
  targetHex = field.hexes[(int)field.coorsToHex( mouseX, mouseY ).x][(int)field.coorsToHex( mouseX, mouseY ).y];
  //println ( field.coorsToHex( mouseX, mouseY ) );  

  background(0);
  field.draw();
  for ( Entity en : entities ) {
    en.update();
    if ( targetHex != null ) {
      //println ( targetHex.center );
      if ( targetHex.entities.contains(en) ) {
        en.displayInfo();
      }
    }
  }
  for ( Entity mov : entities ) {
    mov.draw();
  }
}