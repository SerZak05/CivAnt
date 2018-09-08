class Entity {
  final boolean canBeSelected;
  int turnsToDo, foodToDo;

  CustomButton icon;

  String name;
  int x, y; // current position on the field
  boolean isSelected = false;
  Entity ( String name, int x_, int y_, boolean cbs, int ttd, int ftd ) {
    this.name = name;
    x = x_;
    y = y_;
    field.hexes[x][y].entities.add(this);
    canBeSelected = cbs;

    turnsToDo = ttd;
    foodToDo = ftd;
  }
  Entity clone() {
    Entity clone = new Entity ( name, x, y, canBeSelected, turnsToDo, foodToDo );
    return clone;
  }
  void updateMenu() {
  }
  void update() {
  }

  void nextTurn() {
    isSelected = false;
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
  boolean isActive = true;
  color fill;

  Movable ( String name, int x, int y, int speed, int size, boolean cbs, int ttd, int ftd ) {
    super ( name, x, y, cbs, ttd, ftd );
    this.speed = speed;
    MP = speed;
    this.size = size;

    ArrayList<CircButton> buttons = new ArrayList();
    buttons.add(new CircButton ( "", field.hexes[x][y].center.x + HEX_SIDE_SIZE/2, field.hexes[x][y].center.y - HEX_SIDE_SIZE/2, HEX_SIDE_SIZE/3 ));
    icon = new CustomButton ( name, field.hexes[x][y].center.x + HEX_SIDE_SIZE/2, field.hexes[x][y].center.y - HEX_SIDE_SIZE/2, buttons ); 
    //addMouseListener( this );
    fill = color ( 0, 255, 0 );

    field.hexes[x][y].isOpened = true;
    //println ( field.hexes[x][y].capacity - size );
    field.hexes[x][y].space = field.hexes[x][y].capacity - size;
    for ( PVector neigh : field.getNeigh( x, y ) ) {
      if ( neigh.x < 0 || neigh.x > field.w || neigh.y < 0 || neigh.y > field.h ) continue;
      field.hexes[(int)neigh.x][(int)neigh.y].isOpened = true;
      field.hexes[(int)neigh.x][(int)neigh.y].space = field.hexes[(int)neigh.x][(int)neigh.y].capacity;
    }
  }

  Movable clone() {
    Movable clone = new Movable ( name, x, y, speed, size, canBeSelected, turnsToDo, foodToDo );
    clone.MP = MP;
    return clone;
  }

  void displayInfo() {
    fill ( 255, 255, 0 );
    rect ( 0, height, width/4, 3*height/4 );
    fill ( 0 );
    textSize( (textWidth(name)>width/4 ? 30 : 60) );
    text ( name, 10, 3*height/4 + 10 );
    float first_vert_sz = textAscent()+textDescent();
    textSize ( 40 );
    text ( "Speed: " + speed, 10, 3*height/4 + first_vert_sz );
    float sec_vert_sz = textAscent()+textDescent();
    text ( "Size: " + size, 10, 3*height/4 + first_vert_sz + sec_vert_sz );
  }

  private boolean pmousePressed = false;
  void updateMenu() {
    if ( pmousePressed && !mousePressed && canBeSelected ) { // mouse released
      if ( mouseButton == RIGHT ) {
        PVector target = field.coorsToHex( mouseX-camPos.x, mouseY-camPos.y );
        if ( target != null ) {
          move ( (int)target.x, (int)target.y );
        }
      }
    }
    pmousePressed = mousePressed;
  }

  void displayMenu() {
    fill ( 255, 100, 0 );
    rect ( 3*width/4, 0, width, height );
    fill ( 0 );
    textSize( (textWidth(name)>width/4 ? 30 : 60) );
    text ( name, 3*width/4+10, 10 );
    float first_vert_sz = textAscent()+textDescent();
    textSize( 40 );
    text ( "MP: " + MP + " / " + speed, 3*width/4+10, 10+first_vert_sz );
  }

  void move( int tx, int ty ) {
    ArrayList<PVector> path = field.path( x, y, tx, ty, size );
    if ( path == null ) return;
    if ( path.size() > MP ) return;
    MP -= path.size();
    field.hexes[x][y].entities.remove( this );
    field.hexes[x][y].space += size;
    PVector diff = PVector.sub(field.hexes[tx][ty].center, field.hexes[x][y].center);
    for ( Button b : icon.parts ) {
      b.coor.add( diff );
    }
    icon.coor.add( diff );
    x = tx;
    y = ty;
    field.hexes[x][y].isOpened = true;
    field.hexes[x][y].space = field.hexes[x][y].capacity - size;
    for ( PVector neigh : field.getNeigh( x, y ) ) {
      if ( neigh.x < 0 || neigh.x >= field.w || neigh.y < 0 || neigh.y >= field.h ) continue;
      field.hexes[(int)neigh.x][(int)neigh.y].isOpened = true;
      field.hexes[(int)neigh.x][(int)neigh.y].space = field.hexes[(int)neigh.x][(int)neigh.y].capacity;
    }
    field.hexes[x][y].entities.add( this );
    //field.hexes[x][y].space -= size;
  }

  void nextTurn() {
    super.nextTurn();
    MP = speed;
    isActive = true;
  }

  void update() {
    if ( MP <= 0 ) {
      isActive = false;
    }
    if ( isSelected ) {
      updateMenu();
    }
    super.update();
  }

  void draw() {
    if ( isActive ) {
      fill = color ( 0, 255, 0 );
    } else {
      fill = color ( 0, 100, 0 );
    }
    noStroke();
    if ( isActive ) {
      fill( 255 );
    } else {
      fill ( 100 );
    }
    if ( isSelected ) {
      fill ( 255, 255, 0 );
      if ( mousePressed && mouseButton == RIGHT && canBeSelected ) {
        stroke(255);
        ArrayList<PVector> path = field.path( x, y, (int)field.coorsToHex( mouseX-camPos.x, mouseY-camPos.y ).x, (int)field.coorsToHex( mouseX-camPos.x, mouseY-camPos.y ).y, size );
        if ( path != null ) {
          path.add(0, new PVector ( x, y ));
          if ( path.size() <= MP+1 ) {
            field.drawPath ( path );
          } else {
            ArrayList<PVector> firstPath = new ArrayList();
            ArrayList<PVector> secondPath = new ArrayList();
            for ( int i = 0; i < path.size(); i++ ) {
              if ( i <= MP ) {
                firstPath.add(path.get(i));
              } else {
                secondPath.add(path.get(i));
              }
            }
            field.drawPath(firstPath);
            stroke(255, 0, 0);
            secondPath.add(0, firstPath.get(firstPath.size()-1));
            field.drawPath(secondPath);
          }
        }
      }
    }
    noStroke();
    fill ( fill );
    ellipse( field.hexes[x][y].center.x + HEX_SIDE_SIZE, field.hexes[x][y].center.y, HEX_SIDE_SIZE-10, HEX_SIDE_SIZE-10 );
    if ( icon.isPressed() && mouseButton == LEFT ) {
      fill ( 0, 0, 255 );
    } else {
      if ( isActive ) {
        fill ( 255, 0, 0 );
      } else {
        fill ( 100, 0, 0 );
      }
    }
    textSize ( 20 );

    //pushMatrix();
    //translate( field.hexes[x][y].center.x, field.hexes[x][y].center.y );
    icon.draw();
    //popMatrix();
  }
}

class NestBuilder extends Movable {
  RectButton toBuild = new RectButton ( "Build a nest", 3*width/4, height/4, width/4, height/8 );
  NestBuilder ( String name, int x, int y, int speed, int size, boolean cbs, int ttd, int ftd ) {
    super ( name, x, y, speed, size, cbs, ttd, ftd );
  }

  NestBuilder clone() {
    return new NestBuilder ( name, x, y, speed, size, canBeSelected, turnsToDo, foodToDo );
  }

  void updateMenu() {
    super.updateMenu();
    if ( toBuild.isPressed(0) ) {
      buildNest();
    }
    //println(this);
  }

  void displayMenu() {
    super.displayMenu();
    fill ( 0, 0, 255 );
    stroke ( 0 );
    toBuild.draw();
  }

  void buildNest () {
    //nest.isSelected = false;
    entities.add( new Nest ( "Builded nest", x, y, true ) );
    entities.remove(this);
  }
}



class GathererBuilder extends Movable {
  RectButton toBuild = new RectButton ( "Build a gatherer", 3*width/4, height/4, width/4, height/8 );
  int leftTurns = -1;
  GathererBuilder ( String name, int x, int y, int speed, int size, boolean cbs, int ttd, int ftd ) {
    super ( name, x, y, speed, size, cbs, ttd, ftd );
  }

  GathererBuilder clone() {
    return new GathererBuilder ( name, x, y, speed, size, canBeSelected, turnsToDo, foodToDo );
  }

  void nextTurn() {
    super.nextTurn();
    if ( leftTurns >= 0 ) {
      MP = 0;
      isActive = false;
      buildGatherer();
    }
  }

  void updateMenu() {
    super.updateMenu();
    if ( toBuild.isPressed(0) && leftTurns <= 0 ) {
      leftTurns = 5;
      isActive = false;
      isSelected = false;
      buildGatherer();
    }
    //println(this);
  }

  void displayMenu() {
    super.displayMenu();
    fill ( 0, 0, 255 );
    stroke ( 0 );
    toBuild.draw();
  }
  void displayInfo() {
    super.displayInfo();
    if ( leftTurns >= 0 ) {
      text ( "Left turns: " + leftTurns, 10, height - textAscent() - textDescent() );
    }
  }

  void buildGatherer () {
    if ( leftTurns-- <= 0 ) {
      entities.add( new ResourceGatherer ( x, y ) );
    }
  }
}

class Nest extends Entity {
  int leftTurns = 0;
  ArrayList<Entity> projects = new ArrayList<Entity>();
  ArrayList<Entity> availableProj = new ArrayList<Entity>();
  private ArrayList<RectButton> menu = new ArrayList<RectButton>();

  Nest ( String name, int x, int y, boolean cbs ) {
    super ( name, x, y, cbs, 0, 0 );
    //projects.add(new Movable( "Spawned insect", x, y, 3, 0 ) );
    availableProj.add( new Movable( "Solder 1", x, y, 4, 1, true, 3, 20 ));
    availableProj.add( new Movable( "Solder 2", x, y, 3, 1, true, 2, 10 ));
    availableProj.add( new NestBuilder( "Nest builder", x, y, 2, 2, true, 4, 40 ));
    availableProj.add( new GathererBuilder ( "Gatherer builder", x, y, 3, 1, true, 3, 30 ));
    for ( int i = 0; i < availableProj.size(); i++ ) {
      menu.add( new RectButton ( availableProj.get(i).name, 3*width/4, height/4 + i*height/8, width/4, height/8 ));
    }

    ArrayList<Button> buttons = new ArrayList<Button>();
    buttons.add( new CircButton ( "", field.hexes[x][y].center.x+HEX_SIDE_SIZE/4, field.hexes[x][y].center.y-HEX_SIDE_SIZE/4, HEX_SIDE_SIZE/2 ) );
    buttons.add( new RectButton ( "", field.hexes[x][y].center.x+HEX_SIDE_SIZE/4, field.hexes[x][y].center.y-HEX_SIDE_SIZE/2, 3*HEX_SIDE_SIZE/2, HEX_SIDE_SIZE/2 ) );
    buttons.add( new CircButton ( "", field.hexes[x][y].center.x+7*HEX_SIDE_SIZE/4, field.hexes[x][y].center.y-HEX_SIDE_SIZE/4, HEX_SIDE_SIZE/2 ) );
    icon = new CustomButton ( name, field.hexes[x][y].center.x+HEX_SIDE_SIZE/4, field.hexes[x][y].center.y-HEX_SIDE_SIZE/2, buttons );
  }

  void update() {
    if ( isSelected ) {
      updateMenu();
    }
  }

  void displayInfo() {
    fill ( 100, 255, 50 );
    rect ( 0, height, width/4, 3*height/4 );
    fill ( 0 );
    textSize( (textWidth(name)>width/4 ? 30 : 60) );
    text ( name, 10, 3*height/4 + 10 );
    float first_vert_sz = textAscent()+textDescent();
    textSize ( 20 );
    text ( "Current project: " + ( projects.isEmpty() ? "NO PROJECT" : projects.get(0).name ), 10, 3*height/4 + first_vert_sz );
    float sec_vert_sz = textAscent()+textDescent();
  }

  void updateMenu() {
    if ( availableProj.size() != menu.size() ) { //update buttons
      menu.clear();
      for ( int i = 0; i < availableProj.size(); i++ ) {
        menu.add( new RectButton ( availableProj.get(i).name, 3*width/4, height/4 + i*height/8, width/4, height/8 ));
      }
    }
    for ( int i = 0; i < menu.size(); i++ ) {
      if ( menu.get(i).isPressed(0) && food >= availableProj.get(i).foodToDo ) {
        if ( projects.isEmpty() ) {
          leftTurns = availableProj.get(i).turnsToDo;
        }
        projects.add(availableProj.get(i).clone());
        food -= availableProj.get(i).foodToDo;
      }
    }
  }


  void displayMenu() {
    fill ( 255, 100, 0 ); 
    stroke(0);
    rect ( 3*width/4, 0, width, height ); 
    fill ( 0 ); 
    textSize( (textWidth(name)>width/4 ? 30 : 60) ); 
    text ( name, 3*width/4+10, 10 ); 
    float first_vert_sz = textAscent()+textDescent(); 
    textSize( 40 ); 
    text ( projects.isEmpty() ? "Select project:" : "Current project:\n"+projects.get(0).name+"\nTurns left: "+leftTurns, 3*width/4+10, 10+first_vert_sz ); 

    if ( projects.isEmpty() ) {
      for ( Button b : menu ) {
        fill ( 50, 100, 255 ); 
        b.draw();
      }
    }
  }

  void nextTurn() {
    super.nextTurn();
    if ( leftTurns <= 0 ) {
      spawnProject();
      if ( !projects.isEmpty() ) {
        leftTurns = projects.get(0).turnsToDo;
      }
    } else {
      leftTurns--;
    }
  }

  void spawnProject() {
    if ( !projects.isEmpty() ) {
      entities.add( projects.get(0) ); 
      projects.remove(0);
    }
  }

  void draw () {
    pushStyle(); 
    noStroke(); 
    rectMode( CENTER ); 
    fill ( 255, 100, 255 ); 
    rect ( field.hexes[x][y].center.x+HEX_SIDE_SIZE, field.hexes[x][y].center.y, HEX_SIDE_SIZE-10, HEX_SIDE_SIZE-10 );
    if ( icon.isPressed() ) {
      fill ( 255, 0, 0 );
    } else {
      fill ( 0, 0, 255 );
    }
    textSize(20);
    icon.draw();
    popStyle();
  }
}

// Squad of movables
//class Squad extends Movable {
//  ArrayList<Movable> insects;
//  ArrayList<RectButton> menu;
//  Squad ( String name, int x, int y, boolean cbs, ArrayList ins ) {
//    insects = ins;
//    menu = new ArrayList<RectButton>();
//    int minspeed = 1000;
//    int size = 0;
//    for ( Movable m : ins ) {
//      size+=m.size;
//      if ( m.speed < minspeed ) {
//        minspeed = m.speed;
//      }

//      menu.add( new RectButton ( m.name, 3*width/4, height/4 + ins.indexOf(m)*height/8, width/4, height/8 ) );
//    }
//    super( name, x, y, speed, size, cbs, 0, 0 );
//  }

//  void displayMenu() {
//    super.displayMenu();
//    for ( RectButton b : menu ) {
//      b.draw();
//    }
//  }
//}