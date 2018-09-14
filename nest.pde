
/// Nest ///
class Nest extends Entity {
  int leftTurns = 0;
  ArrayList<Entity> projects = new ArrayList<Entity>();
  ArrayList<Entity> availableProj = new ArrayList<Entity>();
  private ArrayList<RectButton> menu = new ArrayList<RectButton>();

  Nest ( EntityBuilder builder ) {
    super ( builder );
    //projects.add(new Movable( "Spawned insect", x, y, 3, 0 ) );
    availableProj.add( new MovableBuilder( "Movable 1", x, y )    
      .setSpeed(4)
      .setSize(2)
      .setMP(4)
      .setTtd(3)
      .setFtd(25)
      .setFus(1)
      .build());
    availableProj.add( new MovableBuilder( "Movable 2", x, y )    
      .setSpeed(3)
      .setSize(1)
      .setMP(3)
      .setTtd(3)
      .setFtd(15)
      .setFus(1)
      .build());
    availableProj.add( new NestBuilder((MovableBuilder)new MovableBuilder( "Nest builder", x, y )    
      .setSpeed(3)
      .setSize(1)
      .setMP(3)
      .setTtd(3)
      .setFtd(15)
      .setFus(1)));
    availableProj.add( new GathererBuilder((MovableBuilder)new MovableBuilder( "Gatherer builder", x, y )    
      .setSpeed(3)
      .setSize(1)
      .setTtd(3)
      .setFtd(15)
      .setFus(1)));
    updateButtons();

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
    //float sec_vert_sz = textAscent()+textDescent();
  }

  private void updateButtons() {
    if ( availableProj.size() != menu.size() ) { //update buttons
      menu.clear();
      for ( int i = 0; i < availableProj.size(); i++ ) {
        menu.add( new RectButton ( availableProj.get(i).name, 3*width/4, height/4 + i*height/8, width/4, height/8 ));
      }
    }
  }

  void updateMenu() {
    updateButtons();
    for ( int i = 0; i < menu.size(); i++ ) {
      if ( menu.get(i).isPressed(0) && food >= availableProj.get(i).foodToDo ) {
        if ( projects.isEmpty() ) {
          leftTurns = availableProj.get(i).turnsToDo;
        }
        projects.add(availableProj.get(i).clone());
        food -= availableProj.get(i).foodToDo;
        isSelected = false;
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
      for ( RectButton b : menu ) {
        fill ( 50, 100, 255 ); 
        b.draw();
        fill ( 255 );
        text ( "Food needed: " + availableProj.get(menu.indexOf(b)).foodToDo, b.coor.x, b.coor.y + b.sizeY/2 );
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
//int minspeed = 1000;
//    int size = 0;
//    for ( Movable m : ins ) {
//      size+=m.size;
//      if ( m.speed < minspeed ) {
//        minspeed = m.speed;
//      }

//      menu.add( new RectButton ( m.name, 3*width/4, height/4 + ins.indexOf(m)*height/8, width/4, height/8 ) );
//    }