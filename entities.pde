///Builder///
class EntityBuilder {
  String name;
  HexCoor coor;
  //////
  boolean canBeSelected = true;
  int turnsToDo = 0;
  int foodToDo = 0;
  int foodUsing = 0;
  int player = 0; // 0 - our player
  EntityBuilder ( String name, int x, int y ) {
    this.name = name;
    coor = new HexCoor( x, y );
  }
  EntityBuilder setCbs ( boolean cbs ) {
    canBeSelected = cbs;
    return this;
  }
  EntityBuilder setTtd ( int ttd ) {
    turnsToDo = ttd;
    return this;
  }
  EntityBuilder setFtd ( int ftd ) {
    foodToDo = ftd;
    return this;
  }
  EntityBuilder setFus ( int fus ) {
    foodUsing = fus;
    return this;
  }
  EntityBuilder setPlayer ( int pl ) {
    player = pl;
    return this;
  }
  Entity build() {
    return new Entity ( this );
  }
}


class Entity {
  boolean canBeSelected;
  int turnsToDo, foodToDo, foodUsing;
  int size = 0;
  int player = 0; // player number

  CustomButton icon;

  String name;
  int x, y; // current position on the field
  boolean isSelected = false;
  Entity ( EntityBuilder builder ) {
    name = builder.name;
    x = builder.coor.x;
    y = builder.coor.y;
    field.hexes[x][y].entities.add(this);
    canBeSelected = builder.canBeSelected;

    turnsToDo = builder.turnsToDo;
    foodToDo = builder.foodToDo;
    foodUsing = builder.foodUsing;
  }

  Entity clone() {
    Entity clone = new EntityBuilder( name, x, y )
      .setCbs(canBeSelected)
      .setFtd(foodToDo)
      .setTtd(turnsToDo)
      .setFus(foodUsing)
      .build();
    return clone;
  }
  void updateMenu() {
  }
  void update() {
  }

  void nextTurn() {
    isSelected = false;
    food -= foodUsing;
  }

  void displayInfo() {
  }
  void displayMenu() {
  }

  void draw() {
  }
}



///
///MOVABLES///
///
///Builder///
class MovableBuilder extends EntityBuilder {
  int speed, MP, size; 
  MovableBuilder ( String name, int x, int y ) {
    super ( name, x, y );
  }
  MovableBuilder setSpeed ( int speed ) {
    this.speed = speed;
    return this;
  }
  MovableBuilder setSize ( int size ) {
    this.size = size;
    return this;
  }
  MovableBuilder setMP ( int mp ) {
    MP = mp;
    return this;
  }
  Entity build() {
    return new Movable(this);
  }
}

class Movable extends Entity {
  int speed, MP, size; //MP (move points) - current state
  boolean isActive = true;
  color fill;

  Movable ( MovableBuilder builder ) {
    super ( builder );
    speed = builder.speed;
    MP = builder.MP;
    size = builder.size;

    ArrayList<CircButton> buttons = new ArrayList();
    buttons.add(new CircButton ( "", field.hexes[x][y].center.x + HEX_SIDE_SIZE/2, field.hexes[x][y].center.y - HEX_SIDE_SIZE/2, HEX_SIDE_SIZE/3 ));
    icon = new CustomButton ( name, field.hexes[x][y].center.x + HEX_SIDE_SIZE/2, field.hexes[x][y].center.y - HEX_SIDE_SIZE/2, buttons ); 
    //addMouseListener( this );
    fill = color ( 255, 255, 0 );

    //println ( field.hexes[x][y].capacity - size );
    field.updateSpace();
    field.hexes[x][y].space = field.hexes[x][y].capacity - size;
    updateVisibility();
  }


  Movable clone() {
    Movable clone = (Movable)new MovableBuilder( name, x, y )
      .setSpeed(speed)
      .setSize(size)
      .setMP(MP)
      .setCbs(canBeSelected)
      .setFtd(foodToDo)
      .setTtd(turnsToDo)
      .setFus(foodUsing)
      .build();
    //clone.MP = MP;
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
        HexCoor target = field.coorsToHex( mouseX-camPos.x, mouseY-camPos.y );
        if ( target != null ) {
          field.hexes[x][y].space += size;
          move ( target.x, target.y );
          field.hexes[x][y].space = field.hexes[x][y].capacity - size;
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
    ArrayList<HexCoor> path = field.path( x, y, tx, ty, size );
    if ( path == null ) return;
    if ( path.size() > MP ) return;
    MP -= path.size();
    field.hexes[x][y].entities.remove( this );
    //field.hexes[x][y].space += size;
    PVector diff = PVector.sub(field.hexes[tx][ty].center, field.hexes[x][y].center);
    for ( Button b : icon.parts ) {
      b.coor.add( diff );
    }
    icon.coor.add( diff );
    x = tx;
    y = ty;
    updateVisibility();
    //field.hexes[x][y].space = field.hexes[x][y].capacity - size;
    for ( int i = 0; i < field.hexes[x][y].entities.size(); i++ ) {
      Entity en = field.hexes[x][y].entities.get(i);
      if ( en instanceof Squad ) {
        if ( !((Squad)en).insects.contains(this) ) {
          joinSquad ( (Squad)en );
        }
        return;
      } 
      if ( en instanceof Movable ) {
        Squad sq = new Squad ( "Squad", x, y, true, new ArrayList<Movable>());
        sq.isActive = false;
        sq.MP = 0;
        entities.add ( sq );
        ((Movable) en).joinSquad( sq );
        joinSquad( sq );
      }
    }
    field.hexes[x][y].entities.add( this );
    //field.hexes[x][y].space -= size;
  }

  void joinSquad( Squad s ) {
    MP = 0;
    isActive = false;
    field.hexes[x][y].entities.remove(this);
    s.insects.add ( this );
    s.updateButtons();
    entities.remove ( this );
  }

  void updateVisibility() {
    field.hexes[x][y].isOpened = true;
    for ( HexCoor neigh : field.getNeigh( x, y ) ) {
      if ( neigh.x < 0 || neigh.x >= field.w || neigh.y < 0 || neigh.y >= field.h ) continue;
      field.hexes[(int)neigh.x][(int)neigh.y].isOpened = true;
      field.hexes[(int)neigh.x][(int)neigh.y].space = field.hexes[(int)neigh.x][(int)neigh.y].capacity;
    }
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
      fill = color ( 255, 255, 0 );
    } else {
      fill = color ( 100, 100, 0 );
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
        ArrayList<HexCoor> path = field.path( x, y, (int)field.coorsToHex( mouseX-camPos.x, mouseY-camPos.y ).x, (int)field.coorsToHex( mouseX-camPos.x, mouseY-camPos.y ).y, size );
        if ( path != null ) {
          path.add(0, new HexCoor ( x, y ));
          if ( path.size() <= MP+1 ) {
            field.drawPath ( path );
          } else {
            ArrayList<HexCoor> firstPath = new ArrayList();
            ArrayList<HexCoor> secondPath = new ArrayList();
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



/// Workers ///
class Worker extends Movable {
  RectButton toBuild = new RectButton ( "Build", 3*width/4, height/4, width/4, height/8 );
  Worker ( MovableBuilder builder ) {
    super ( builder );
  }

  /////Builder is MovableBuilder///
  //class WorkerBuilder extends MovableBuilder {
  //  WorkerBuilder ( String name, int x, int y ) {
  //    super ( name, x, y );
  //  }

  //}

  Worker clone() {
    return (Worker)new MovableBuilder ( name, x, y ).setCbs(canBeSelected)
      .setFtd(foodToDo)
      .setTtd(turnsToDo)
      .setFus(foodUsing)
      .build();
  }

  void updateMenu() {
    super.updateMenu();
    if ( toBuild.isPressed(0) ) {
      build();
    }
    //println(this);
  }

  void displayMenu() {
    super.displayMenu();
    fill ( 0, 0, 255 );
    stroke ( 0 );
    toBuild.draw();
  }

  void build () {
    //nest.isSelected = false;
    //entities.add( new Nest ( "Builded nest", x, y, true ) );
    //entities.remove(this);
  }
}

class NestBuilder extends Worker {
  //RectButton toBuild = new RectButton ( "Build a nest", 3*width/4, height/4, width/4, height/8 );
  NestBuilder ( MovableBuilder builder ) {
    super ( builder );
    toBuild.name = "Build a nest";
  }

  NestBuilder clone() {
    return new NestBuilder( (MovableBuilder)new MovableBuilder ( name, x, y )
      .setSpeed(speed)
      .setSize(size)
      .setMP(MP)
      .setCbs(canBeSelected)
      .setFtd(foodToDo)
      .setTtd(turnsToDo)
      .setFus(foodUsing));
  }

  void build () {
    //nest.isSelected = false;
    entities.add( new Nest( new EntityBuilder( "Builded nest", x, y )
      .setCbs(canBeSelected)
      .setFus(3)));
    entities.remove(this);
  }
}



class GathererBuilder extends Worker {
  //RectButton toBuild = new RectButton ( "Build a gatherer", 3*width/4, height/4, width/4, height/8 );
  int leftTurns = -1;
  GathererBuilder ( MovableBuilder builder ) {
    super ( builder );
    toBuild.name = "Build a gatherer";
  }

  GathererBuilder clone() {
    return new GathererBuilder( (MovableBuilder)new MovableBuilder ( name, x, y )
      .setSpeed(speed)
      .setSize(size)
      .setMP(MP)
      .setCbs(canBeSelected)
      .setFtd(foodToDo)
      .setTtd(turnsToDo)
      .setFus(foodUsing));
  }

  void nextTurn() {
    super.nextTurn();
    if ( leftTurns >= 0 ) {
      MP = 0;
      isActive = false;
      build();
    }
  }

  void updateMenu() {
    if ( toBuild.isPressed(0) && leftTurns <= 0 ) {
      leftTurns = 5;
      isActive = false;
      isSelected = false;
      build();
    }
    super.updateMenu();
    //println(this);
  }

  void displayInfo() {
    super.displayInfo();
    if ( leftTurns >= 0 ) {
      text ( "Left turns: " + leftTurns, 10, height - textAscent() - textDescent() );
    }
  }

  void build () {
    if ( leftTurns-- <= 0 ) {
      entities.add( new ResourceGatherer ( x, y ) );
    }
  }
}

/// Solders ///
///Builder///
class SolderBuilder extends MovableBuilder {
  int attack, lives, totalLives;
  SolderBuilder( String name, int x, int y ) {
    super( name, x, y );
  }
  SolderBuilder setAttack( int att ) {
    attack = att;
    return this;
  }
  SolderBuilder setTotalLives( int totliv ) {
    totalLives = totliv;
    return this;
  }
  SolderBuilder setLives( int liv ) {
    lives = liv;
    return this;
  }
}

class Solder extends Movable {
  int attack;
  int lives, totalLives;
  Solder ( SolderBuilder builder ) {
    super( builder );
    attack = builder.attack;
    totalLives = builder.totalLives;
    lives = builder.lives;
  }


  Solder clone() {
    return (Solder)new SolderBuilder( name, x, y )
      .setAttack(attack)
      .setLives(totalLives)
      .setTotalLives(totalLives)
      .setCbs(canBeSelected)
      .setFtd(foodToDo)
      .setTtd(turnsToDo)
      .setFus(foodUsing)
      .build();
  }
  void attack( Movable en ) {
  }
}

class RangedSolder extends Solder {
  int range;
  RangedSolder ( RangedSolderBuilder builder ) {
    super ( builder );
    range = builder.range;
  }

  ///Builder///
  class RangedSolderBuilder extends SolderBuilder {
    int range;
    RangedSolderBuilder( String name, int x, int y ) {
      super( name, x, y );
    }
    RangedSolderBuilder setRange( int r ) {
      range = r;
      return this;
    }
  }
  RangedSolder clone() {
    return (RangedSolder)new RangedSolderBuilder( name, x, y )
      .setRange(range)
      .setAttack(attack)
      .setLives(totalLives)
      .setTotalLives(totalLives)
      .setCbs(canBeSelected)
      .setFtd(foodToDo)
      .setTtd(turnsToDo)
      .setFus(foodUsing)
      .build();
  }
  void attack ( Movable en ) {
    if ( new HexCoor( x, y ).dist( new HexCoor( en.x, en.y ) ) <= range ) {
    }
  }
}

//Squad of movables
class Squad extends Movable {
  ArrayList<Movable> insects;
  ArrayList<RectButton> menu;
  Squad ( String name, int x, int y, boolean cbs, ArrayList<Movable> ins ) {
    super ( (MovableBuilder)new MovableBuilder( name, x, y )
      .setCbs(cbs));
    insects = ins;
    for ( Movable i : insects ) {
      if ( i.speed < speed ) {
        speed = i.speed;
      }
      size+=i.size;
      foodUsing+=i.foodUsing;
    }
    menu = new ArrayList<RectButton>();
    updateButtons();
  }

  void removeInsect ( Movable ins ) {
    entities.add( ins );
    ins.canBeSelected = true;
    ins.isSelected = true;
    field.hexes[x][y].entities.add ( ins );
    isSelected = false;
    insects.remove(ins);
    if ( insects.size() == 1 ) {
      Movable ins2 = insects.get(0);
      removeInsect(ins2);
      ins2.isSelected = false;
      field.hexes[x][y].entities.remove(this);
      entities.remove ( this );
    } else if ( insects.isEmpty() ) {
      field.hexes[x][y].entities.remove(this);
      entities.remove ( this );
    }
    updateButtons();
  }

  void removeInsect ( int i ) {
    removeInsect ( insects.get(i) );
  }

  void move( int tx, int ty ) {
    super.move( tx, ty );
    for ( int i = 0; i < insects.size(); i++ ) {
      insects.get(i).move ( tx, ty );
    }
  }

  void displayInfo() {
    super.displayInfo();
    text ( "Number of units: " + insects.size(), 10, height-10 );
  }

  void updateButtons() {
    if ( menu.size() == insects.size() ) return;
    menu.clear();
    for ( int i = 0; i < insects.size(); i++ ) {
      menu.add( new RectButton ( insects.get(i).name, 3*width/4, height/4 + i*height/8, width/4, height/8 ));
    }
  }

  void updateMenu() {
    super.updateMenu();
    for ( RectButton b : menu ) {
      if ( b.isPressed() ) {
        removeInsect ( menu.indexOf(b) );
        break;
      }
    }
  }

  void displayMenu() {
    super.displayMenu();
    for ( RectButton b : menu ) {
      b.draw();
    }
  }

  void nextTurn() {
    super.nextTurn();
    for ( Movable en : insects ) {
      en.nextTurn();
    }
  }
}