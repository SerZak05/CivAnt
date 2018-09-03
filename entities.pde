class Entity {
  final boolean canBeSelected;
  int turnsToDo;

  CustomButton icon;

  String name;
  int x, y; // current position on the field
  boolean isSelected = false;
  Entity ( String name, int x_, int y_, int ttd ) {
    this.name = name;
    x = x_;
    y = y_;
    field.hexes[x][y].entities.add(this);
    canBeSelected = true;

    turnsToDo = ttd;
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

  Movable ( String name, int x, int y, int speed, int size, int ttd ) {
    super ( name, x, y, ttd );
    this.speed = speed;
    MP = speed;
    this.size = size;

    ArrayList<CircButton> buttons = new ArrayList();
    buttons.add(new CircButton ( "", field.hexes[x][y].center.x + HEX_SIDE_SIZE/2, field.hexes[x][y].center.y - HEX_SIDE_SIZE/2, HEX_SIDE_SIZE/3 ));
    icon = new CustomButton ( name, field.hexes[x][y].center.x + HEX_SIDE_SIZE/2, field.hexes[x][y].center.y - HEX_SIDE_SIZE/2, buttons ); 
    //addMouseListener( this );
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
        PVector target = field.coorsToHex( mouseX, mouseY );
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
    field.hexes[x][y].entities.add( this );
    field.hexes[x][y].space -= size;
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
        ArrayList<PVector> path = field.path( x, y, (int)field.coorsToHex( mouseX, mouseY ).x, (int)field.coorsToHex( mouseX, mouseY ).y, size );
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
    fill ( 0, 255, 0 );
    ellipse( field.hexes[x][y].center.x + HEX_SIDE_SIZE, field.hexes[x][y].center.y, HEX_SIDE_SIZE-10, HEX_SIDE_SIZE-10 );
    if ( icon.isPressed() ) {
      fill ( 0, 0, 255 );
    } else {
      fill ( 255, 0, 0 );
    }
    textSize ( 20 );
    //pushMatrix();
    //translate( field.hexes[x][y].center.x, field.hexes[x][y].center.y );
    icon.draw();
    //popMatrix();
    if ( isSelected ) {
      displayMenu();
    }
  }
}




class Nest extends Entity {
  int leftTurns = 0;
  ArrayList<Entity> projects = new ArrayList<Entity>();
  ArrayList<Entity> availableProj = new ArrayList();
  private ArrayList<RectButton> menu = new ArrayList();

  Nest ( String name, int x, int y ) {
    super ( name, x, y, 0 );
    //projects.add(new Movable( "Spawned insect", x, y, 3, 0 ) );
    availableProj.add( new Movable( "Insect 1", x, y, 4, 1, 3 ));
    availableProj.add( new Movable( "Insect 2", x, y, 3, 1, 2 ));
    for ( int i = 0; i < availableProj.size(); i++ ) {
      menu.add( new RectButton ( availableProj.get(i).name, 3*width/4, height/4 + i*height/8, width/4, height/8 ));
    }

    ArrayList<Button> buttons = new ArrayList<Button>();
    buttons.add( new CircButton ( "", field.hexes[x][y].center.x+HEX_SIDE_SIZE/4, field.hexes[x][y].center.y-HEX_SIDE_SIZE/4, HEX_SIDE_SIZE/2 ) );
    buttons.add( new RectButton ( "", field.hexes[x][y].center.x+HEX_SIDE_SIZE/4, field.hexes[x][y].center.y-HEX_SIDE_SIZE/2, 3*HEX_SIDE_SIZE/2, HEX_SIDE_SIZE/2 ) );
    buttons.add( new CircButton ( "", field.hexes[x][y].center.x+7*HEX_SIDE_SIZE/4, field.hexes[x][y].center.y-HEX_SIDE_SIZE/4, HEX_SIDE_SIZE/2 ) );
    icon = new CustomButton ( name, field.hexes[x][y].center.x+HEX_SIDE_SIZE/4, field.hexes[x][y].center.y-HEX_SIDE_SIZE/2, buttons );
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
      if ( menu.get(i).isPressed() ) {
        if ( projects.isEmpty() ) {
          leftTurns = availableProj.get(i).turnsToDo;
        }
        projects.add(availableProj.get(i));
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
    if ( isSelected ) {
      displayMenu();
    }
  }
}