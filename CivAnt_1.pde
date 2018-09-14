enum modeType { //<>// //<>//
  menu, game, help;
}

modeType mode = modeType.menu;
static ArrayList<RectButton> menu = new ArrayList<RectButton>();
CircButton backToMenu = new CircButton ( "", 10, 10, 20 );

PVector camPos, scalePos;
float scaleFactor = 1;

final float HEX_SIDE_SIZE = 50;
Field field;

ArrayList<Entity> entities;

Hex targetHex;

float food = 100, income = 0; // overall food supply

void setup() {
  fullScreen();
  textSize(40);
  menu.add( new RectButton ( "Play", width/2-textWidth("Play")/2, height/2, textWidth("Play"), textAscent()+textDescent() ));
  menu.add( new RectButton ( "Help", width/2-textWidth("Help")/2, height/2+textAscent()+textDescent(), textWidth("Help"), textAscent()+textDescent() ));
  menu.add( new RectButton ( "Quit", width/2-textWidth("Quit")/2, height/2+textAscent()*2+textDescent()*2, textWidth("Quit"), textAscent()+textDescent() ));

  camPos = new PVector ( 0, 0 );
  //shapeMode(CENTER);
  rectMode(CORNERS);
  textAlign( LEFT, TOP );
  FieldGenerator gen = new FieldGenerator ( 20, 30, (int)random(10000) );
  field = gen.generateField();
  println(gen.seed);

  entities = new ArrayList<Entity>();
  //entities.add ( new Movable ( "Long name of an ant", 4, 3, 4, 0 ) );
  entities.add ( new Nest( new EntityBuilder( "Nest", 4, 5 )
    .setFus(3)));
  targetHex = new Hex ( new PVector ( 0, 0 ), 0 );
}

void nextTurn() {
  for ( int i = 0; i < entities.size(); i++ ) {
    entities.get(i).nextTurn();
  }
  if ( food < 0 ) {
    food = 0;
  }
  //gatherer.updateNest();
  //gatherer.nextTurn();
}

void keyPressed () {
  // next turn
  if ( mode == modeType.game ) {
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
      scaleFactor*=1.1;
      //PVector mousePos = new PVector ( mouseX/scaleFactor, mouseY/scaleFactor );
      //camPos.add( PVector.sub( camPos, mousePos ).div(10) );
      //println ( "MousePos:", mousePos, "camPos:", camPos, "scale:", scaleFactor );
      break;
    case 'c' :
      scaleFactor/=1.1;
      break;
    }
  }
}

void mousePressed() {
  if ( mode == modeType.game ) {
    if ( backToMenu.isPressed(0) ) {
      mode = modeType.menu;
      camPos.sub ( camPos );
    } else if ( mouseButton == LEFT ) {
      //boolean isSelected = false; // checks, if something is selected
      for ( int i = 0; i < entities.size(); i++ ) {
        Entity en = entities.get(i);

        if ( en.icon == null || !en.canBeSelected ) continue;
        //pushMatrix();
        //translate ( field.hexes[en.x][en.y].center.x, field.hexes[en.x][en.y].center.y );
        if ( en.icon.isPressed()) {
          selectEntity ( i );
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
}

void selectEntity( int i ) {
  for ( int j = 0; j < entities.size(); j++ ) {
    if ( j == i ) {
      Entity en = entities.get(i); 
      en.isSelected = true;
      //camPos = PVector.sub( new PVector ( 3*width/8-HEX_SIDE_SIZE, height/2 ), field.hexes[en.x][en.y].center );
    } else {
      entities.get(j).isSelected = false;
    }
  }
}

void mouseDragged() {
  if ( mode == modeType.game ) {
    if ( mouseButton == LEFT ) {
      camPos.add( mouseX - pmouseX, mouseY - pmouseY );
    }
  }
}

void draw() {
  switch ( mode ) {
  case menu :
    background ( 0 );
    textSize ( 70 );
    fill ( 50, 255, 0 );
    text ( "CivAnt 1", width/2-textWidth("CivAnt 1")/2, height/4 );
    textSize ( 40 );
    noStroke();

    if ( mouseButton == LEFT ) {
      if ( menu.get(0).isPressed() ) {
        mode = modeType.game;
        break;
      } 
      if ( menu.get(1).isPressed() ) {
        mode = mode.help;
        break;
      }
      if ( menu.get(2).isPressed() ) {
        exit();
      }
    }
    for ( RectButton b : menu ) {
      if ( !b.isPressed() ) {
        fill ( 0, 255, 0 );
      } else {
        fill ( 255, 0, 0 );
      }
      b.draw();
    }
    break;

  case game :
    targetHex = field.hexes[(int)field.coorsToHex( mouseX-camPos.x, mouseY-camPos.y ).x][(int)field.coorsToHex( mouseX-camPos.x, mouseY-camPos.y ).y];
    pushMatrix();
    //scale ( scaleFactor );
    translate( camPos.x, camPos.y );
    background(0);
    field.draw();
    //gatherer.updateNest();
    //gatherer.draw();
    for ( int i = 0; i < entities.size(); i++ ) {
      entities.get(i).update();
      //for ( Entity en : field.hexes[entities.get(i).x][entities.get(i).y].entities ) {
      //  if ( en instanceof Squad ) {
      //    en
      //  }
      //if ( targetHex != null ) {
      //  println ( targetHex.center );
      //}
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
    updateIncome();
    fill ( 255 );
    textSize ( 30 );
    text ( "Food: " + (int)food, 20, 10 );
    fill ( income < 0 ? color(255, 0, 0) : color(0, 255, 0) );
    text ( (int)income, 30+textWidth("Food " + (int)food ), 10 );
    textSize ( 15 );
    fill ( 255, 0, 0 );
    backToMenu.draw();
    break;
  case help :
    background(0);
    textSize ( 40 );
    text ( "Controls: ", width/2-textWidth("Controls: ")/2, 10 );
    textSize ( 30 );
    text ( "Move camera: drag mouse or wasd\nTo select unit or nest click on its icon\n" +
      "When you select a unit/nest, the menu opens.\nYou can press buttons in menu of the unit/nest\n" +
      "To exit to main menu press RMB", 
      width/4, height/4 );
    if ( mousePressed && mouseButton == RIGHT ) mode = modeType.menu;
    break;
  }
}

void updateIncome() {
  income = 0;
  for ( Entity en : entities ) {
    income -= en.foodUsing;
  }
}