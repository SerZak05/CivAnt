// Behaviour - one separate game logic piece.
// Each object should contain multiple behaviours that control his perfomance.
// By combining different behaviours we can get different objects

class Behaviour {
  protected String name = "";
  protected Entity mEntity;
  // Widgets that will pop up when entity is selected or mouse is hovering above it
  protected Widget infoWidget, menuWidget; 
  Behaviour(Entity e) {
    mEntity = e;
  }
  Behaviour(Behaviour beh) {
    mEntity = beh.mEntity;
  }
  
  // returns link to our widget, so it can be displayed and we can interact with Behaviour
  Widget getInfoWidget() {    
    return infoWidget;
  }
  Widget getMenuWidget() {
    return menuWidget;
  }
  
  void nextTurn() {}
  void init() {}
  void update() {}
  
  String getName() {
    return name;
  }
}


class Movable extends Behaviour {
  int speed, MP, size; //MP (move points) - current state
  boolean isActive = true;
  color fill;
  
  private Label speedLabel;

  Movable (Entity e, JSONObject config) {
    super(e);
    speed = config.getInt("speed");
    MP = speed;
    size = config.getInt("size");
    name = config.getString("type");
    
    // Config of widgets
    infoWidget = new Widget(gameWidget);
    speedLabel = new Label(infoWidget, new PVector(0, 0));
    speedLabel.textAlignment = LEFT;
    speedLabel.textSize = 30;
    speedLabel.fill = 255;
    speedLabel.background = color(200, 170, 0);
    speedLabel.text = "Move points: " + MP + "/" + speed;
    infoWidget.pack(speedLabel);
    Label sizeLabel = new Label(infoWidget, new PVector(0, speedLabel.getHeight()));
    sizeLabel.textAlignment = LEFT;
    sizeLabel.textSize = 30;
    sizeLabel.fill = 255;
    sizeLabel.background = color(200, 170, 0);
    sizeLabel.text = "Size: " + size;
    infoWidget.pack(sizeLabel);
    
    menuWidget = null;
  }
  
  // Used, when placing entity on the field.
  // Updates the field so it doesnt update when every object is constructed
  @Override
  void init() {
    field.updateSpace();
    field.hexes[mEntity.x][mEntity.y].space = field.hexes[mEntity.x][mEntity.y].capacity - size;
    updateVisibility();
  }


  /*Movable clone() {
    /*Movable clone = (Movable)new MovableBuilder( name, x, y )
      .setSpeed(speed)
      .setSize(size)
      .setMP(MP)
      //.setCbs(canBeSelected)
      .setFtd(foodToDo)
      .setTtd(turnsToDo)
      .setFus(foodUsing)
      .setPlayer(player)
      .build();*/
    /*Movable clone = new Movab
    //clone.MP = MP;
    return clone;
  }*/

  

  private boolean pmousePressed = false;
  @Override
  void update() {
    speedLabel.text = "Move points: " + MP + "/" + speed;
    if ( MP <= 0 ) {
      isActive = false;
    }
    if ( pmousePressed && !mousePressed ) { // mouse released
      if ( mouseButton == RIGHT ) {
        HexCoor target = field.getTargetHex();
        if ( target != null ) {
          field.hexes[mEntity.x][mEntity.y].space += size;
          move ( target.x, target.y );
          field.hexes[mEntity.x][mEntity.y].space = field.hexes[mEntity.x][mEntity.y].capacity - size;
        }
      }
    }
    pmousePressed = mousePressed;
  }

  void move( int tx, int ty ) {
    int x = mEntity.x, y = mEntity.y;
    ArrayList<HexCoor> path = field.path( x, y, tx, ty, size );
    if ( path == null ) return;
    if ( path.size() > MP ) return;
    MP -= path.size();
    field.hexes[x][y].entities.remove( this );
    //field.hexes[x][y].space += size;
    PVector diff = PVector.sub(field.hexes[tx][ty].center, field.hexes[x][y].center);
    mEntity.x = tx;
    mEntity.y = ty;
    mEntity.coor.add(diff);
    updateVisibility();
    //field.hexes[x][y].space = field.hexes[x][y].capacity - size;

    //joining squad//
    /*for ( int i = 0; i < field.hexes[x][y].entities.size(); i++ ) {
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
    }*/
    field.hexes[x][y].entities.add( mEntity );
    //field.hexes[x][y].space -= size;
  }

  /*void joinSquad( Squad s ) {
    MP = 0;
    isActive = false;
    field.hexes[x][y].entities.remove(this);
    s.insects.add ( this );
    s.updateParams();
    s.updateButtons();
    field.updateSpace();
    entities.remove ( this );
  }*/

  void updateVisibility() {
    field.hexes[mEntity.x][mEntity.y].isOpened = true;
    for ( HexCoor neigh : field.getNeigh( mEntity.x, mEntity.y ) ) {
      if ( neigh.x < 0 || neigh.x >= field.w || neigh.y < 0 || neigh.y >= field.h ) continue;
      field.hexes[(int)neigh.x][(int)neigh.y].isOpened = true;
      field.hexes[(int)neigh.x][(int)neigh.y].space = field.hexes[(int)neigh.x][(int)neigh.y].capacity;
    }
  }
  
  @Override
  void nextTurn() {
    super.nextTurn();
    MP = speed;
    isActive = true;
  }

  /*void draw() {
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
      if ( mousePressed && mouseButton == RIGHT && player == PLAYER_NUM ) {
        stroke(255);
        ArrayList<HexCoor> path = 
          field.path( x, y, 
            (int)field.coorsToHex( mouseX-camera.getCameraPos().x, mouseY-camera.getCameraPos().y ).x, 
            (int)field.coorsToHex( mouseX-camera.getCameraPos().x, mouseY-camera.getCameraPos().y ).y,
            size );
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
  }*/
}
