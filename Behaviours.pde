// Behaviour - one separate game logic piece.
// Each object should contain multiple behaviours that control his perfomance.
// By combining different behaviours we can get different objects

abstract class Behaviour {
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
  final Widget getInfoWidget() {    
    return infoWidget;
  }
  final Widget getMenuWidget() {
    return menuWidget;
  }
  
  abstract void nextTurn();
  abstract void init();
  abstract void update();
  
  final String getName() {
    return name;
  }
}


class Movable extends Behaviour implements MouseListener {
  int speed, MP; //MP (move points) - current state
  boolean isActive = true;
  color fill;
  
  private Label speedLabel;

  Movable (Entity e, JSONObject config) {
    super(e);
    speed = config.getInt("speed");
    MP = speed;
    name = config.getString("type");
    
    // Config of widgets
    infoWidget = new Widget(null);
    speedLabel = new Label(infoWidget, new PVector(0, 0));
    speedLabel.textAlignment = LEFT;
    speedLabel.textSize = 30;
    speedLabel.fill = 255;
    speedLabel.background = color(200, 170, 0);
    speedLabel.text = "Move points: " + MP + "/" + speed;
    infoWidget.pack(speedLabel);
    
    menuWidget = null;    
  }
  
  @Override
  Float getZ() {
    return 0.5;
  }
  
  // Used, when placing entity on the field.
  // Updates the field so it doesnt update when every object is constructed
  @Override
  void init() {
    // field.updateSpace();
    // field.hexes[mEntity.x][mEntity.y].space = field.hexes[mEntity.x][mEntity.y].capacity - size;
    mouseLoop.addListener(this);
    // updateVisibility();
  } 

  @Override
  void update() {
    speedLabel.text = "Move points: " + MP + "/" + speed;
    if ( MP <= 0 ) {
      isActive = false;
    }
  }
  
  @Override
  boolean processMouseEvent(MouseEventType t) {
    if ( selector.isSingleSelected(mEntity) ) {
      if ( mouseButton == RIGHT ) {
        // Blocking clicked, because blocking released
        if ( t == MouseEventType.CLICKED ) return false;
        if ( t != MouseEventType.RELEASED ) return true;
        HexCoor target = field.getTargetHex();
        if ( target != null ) {
          move ( target.x, target.y );
        }
      } else {
        return true;
      }
    }
    return true;
  }

  void move( int tx, int ty ) {
    ArrayList<HexCoor> path = field.path( mEntity.x, mEntity.y, tx, ty, mEntity.size );
    if ( path == null ) return;
    if ( path.size() > MP ) return;

    MP -= path.size();
    field.hexes[mEntity.x][mEntity.y].removeEntity(mEntity);
    PVector diff = PVector.sub(field.hexes[tx][ty].center, field.hexes[mEntity.x][mEntity.y].center);
    mEntity.x = tx;
    mEntity.y = ty;
    mEntity.coor.add(diff);
    field.hexes[mEntity.x][mEntity.y].addEntity(mEntity);
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
      if ( !field.isHexInside(new HexCoor(neigh.x, neigh.y)) ) continue;
      field.hexes[(int)neigh.x][(int)neigh.y].isOpened = true;
      field.hexes[(int)neigh.x][(int)neigh.y].space = field.hexes[(int)neigh.x][(int)neigh.y].capacity;
    }
  }
  
  @Override
  void nextTurn() {
    MP = speed;
    isActive = true;
  }
}

class Builder extends Behaviour {
  private ArrayList<String> availableBuilds = new ArrayList<String>();
  private Entity currProject = null;
  private int currTurn, totalTurns;

  private Label projectLabel;
  private Widget projectsButtons;
  private Label currBuilding;

  Builder(Entity e, JSONObject config) {
    super(e);
    String[] builds = config.getJSONArray("builds").getStringArray();
    for ( String str : builds ) {
      availableBuilds.add(str);
    }
    name = "Builder";
    
    // menu and info panels
    menuWidget = new Widget(null);
    projectLabel = new Label(menuWidget);
    projectLabel.background = color(200, 170, 0);
    projectLabel.text = "Select next project";
    projectLabel.textSize = 30;
    projectLabel.textAlignment = LEFT;
    menuWidget.pack(projectLabel);
    
    projectsButtons = new Widget(menuWidget) {
      @Override float getHeight() {
        float res = 0;
        for ( Widget child : children ) {
          res += child.getHeight();
        }
        return res;
      }
    };
    
    final Builder self = this; 
    
    for ( String str : availableBuilds ) {
      final Button b = new RectButton(projectsButtons, str, 300, 75);
      b.pressedColor = color(200, 0, 0);
      b.releasedColor = color(255, 0, 0);
      
      b.callback = new Callback() {
        @Override
        void callback() {
          println("Callback");
          self.selectProject(b.label.text);
        }
      };
      projectsButtons.pack(b);
    }
    menuWidget.pack(projectsButtons);
    
    currBuilding = new Label(menuWidget);
    currBuilding.background = color(200, 170, 0);
    currBuilding.text = "No project";
    currBuilding.textSize = 30;
    currBuilding.textAlignment = LEFT;
    menuWidget.pack(currBuilding);
    
    infoWidget = null;
  }

  @Override
  void init() {}

  @Override
  void nextTurn() {
    if (currProject != null) { // if building
      currTurn++;
      if (currTurn == totalTurns) {
        build();
      }
    }
    if (currProject != null) {
      currBuilding.text = "Building: " + currProject.name + "\nTurns left: " + (totalTurns - currTurn);
      projectLabel.text = "Change project:";
    } else {
      currBuilding.text = "No project";
      projectLabel.text = "Select next project:";
    }
  }
  
  @Override
  void update() {
    /*for ( Widget w : projectsButtons.children ) {
      Button b = (Button)w;
      if (b.isReleased()) {
        selectProject(b.label.text);
      }
    }*/
  }
  
  private void build() {
    currProject.player = mEntity.player;
    field.addEntity(currProject, new HexCoor(mEntity.x, mEntity.y));
    currProject = null;
    currTurn = 0;
  }
  
  private void selectProject(String project) {
    println("Selected a project: " + project);
    currProject = new Entity(unitsConfig, project);
    totalTurns = currProject.turnsToMake;
    food -= currProject.foodToMake;
  }
}
