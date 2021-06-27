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
  Widget getInfoWidget() {    
    return infoWidget;
  }
  Widget getMenuWidget() {
    return menuWidget;
  }
  
  abstract void nextTurn();
  abstract void init();
  abstract void update();
  
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

  private boolean pmousePressed = false;
  @Override
  void update() {
    speedLabel.text = "Move points: " + MP + "/" + speed;
    if ( MP <= 0 ) {
      isActive = false;
    }
    if ( mEntity == selectedEntity && pmousePressed && !mousePressed ) { // mouse released
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
    // updateVisibility();
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
    for ( String str : availableBuilds ) {
      Button b = new RectButton(projectsButtons, str, 300, 75) {
        @Override
        boolean isReleased() {
          boolean res = super.isReleased();
          //if (res) println("Released");
          println(getGlobalCoords());
          return res;
        }
      };
      b.pressedColor = color(200, 0, 0);
      b.releasedColor = color(255, 0, 0);
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
  void init() {
    
  }
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
    for ( Widget w : projectsButtons.children ) {
      Button b = (Button)w;
      if (b.isReleased()) {
        selectProject(b.name);
      }
    }
  }
  
  private void build() {
    currProject.player = mEntity.player;
    currProject.init(new HexCoor(mEntity.x, mEntity.y));
    entities.add(currProject);
    currProject = null;
    currTurn = 0;
  }
  
  private void selectProject(String project) {
    println("Selected a project: " + project);
    currProject = new Entity(unitsConfig, project);
    totalTurns = currProject.turnsToMake;
    food -= currProject.foodToMake;
    mEntity.deselect();
  }
}
