PVector camPos; //<>//
float scale = 1;

final float HEX_SIDE_SIZE = 50; //<>//
Field field;

ArrayList<Entity> entities;

NestBuilder insect;
Hex targetHex;

float food = 50; // overall food supply
GathererBuilder gatherer;

void setup() {
  fullScreen();
  camPos = new PVector ( 0, 0 );
  //shapeMode(CENTER);
  rectMode(CORNERS);
  textAlign( LEFT, TOP );
  field = new Field ( 10, 10 );

  entities = new ArrayList<Entity>();
  insect = new NestBuilder ( "Nest builder", 0, 5, 3, 2, true, 0, 50 );

  //entities.add ( new Movable ( "Long name of an ant", 4, 3, 4, 0 ) );
  entities.add ( new Nest ( "Nest", 4, 5, true ) );
  entities.add(insect);

  gatherer = new GathererBuilder ( "GathererBuilder", 2, 3, 3, 2, true, 0, 30 );
  entities.add(gatherer);

  targetHex = new Hex ( new PVector ( 0, 0 ), 0 );
}

void nextTurn() {
  for ( int i = 0; i < entities.size(); i++ ) {
    entities.get(i).nextTurn();
  }
  //gatherer.updateNest();
  gatherer.nextTurn();
}

void keyPressed () {
  // next turn
  switch ( key ) {
  case ' ':
    nextTurn();
    break;
  case 'w' :
    camPos.y+=5;
    break;
  case 'a' :
    camPos.x+=5;
    break;
  case 's' :
    camPos.y-=5;
    break;
  case 'd' :
    camPos.x-=5;
    break;
  case 'z' : 
    scale*=1.1;
    break;
  case 'c' :
    scale*=(1/1.1);
    break;
  }
}

void mousePressed() {
  if ( mouseButton == LEFT ) {
    //boolean isSelected = false; // checks, if something is selected
    for ( int i = 0; i < entities.size(); i++ ) {
      Entity en = entities.get(i);
      if ( en.isSelected ) en.updateMenu();
      en.isSelected = false;
      if ( en.icon == null || !en.canBeSelected ) continue;
      //pushMatrix();
      //translate ( field.hexes[en.x][en.y].center.x, field.hexes[en.x][en.y].center.y );
      if ( en.icon.isPressed()) {
        en.isSelected = en.canBeSelected;
        //isSelected = true;
        for ( int j = 0; j < i; j++ ) {
          entities.get(j).isSelected = false;
        }
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
void mouseDragged() {
  if ( mouseButton == LEFT ) {
    camPos.add( mouseX - pmouseX, mouseY - pmouseY );
  }
}

void draw() {
  targetHex = field.hexes[(int)field.coorsToHex( mouseX-camPos.x, mouseY-camPos.y ).x][(int)field.coorsToHex( mouseX-camPos.x, mouseY-camPos.y ).y];
  //camera( camPos.x, camPos.y, scale, camPos.x, camPos.y, 0, 0, 1, 0 );
  //translate ( camPos.x, camPos.y );
  //translate ( mouseX, mouseY );
  //scale ( scale );
  //translate ( -mouseX*scale, -mouseY*scale );
  //println ( field.coorsToHex( mouseX, mouseY ) );  
  pushMatrix();
  translate( camPos.x, camPos.y );
  background(0);
  field.draw();
  //gatherer.updateNest();
  //gatherer.draw();
  for ( Entity en : entities ) {
    en.update();
    if ( targetHex != null ) {
      //println ( targetHex.center );
    }
  }
  for ( Entity mov : entities ) {
    mov.draw();
  }
  popMatrix();
  for ( Entity en : entities ) {
    if ( targetHex.entities.contains(en) ) {
      en.displayInfo();
    }
    if ( en.isSelected ) {
      en.displayMenu();
    }
  }
  fill ( 255 );
  textSize ( 30 );
  text ( "Food: " + (int)food, 10, 10 );
}