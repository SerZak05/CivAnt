class Entity extends Widget {
  //boolean canBeSelected;
  private int turnsToMake, foodToMake, foodUsing;
  private int player = 0; // player number
  
  ArrayList<Behaviour> behaviours = new ArrayList<Behaviour>();

  private Button icon;
  
  private Widget menu, info;
  
  private boolean hasInit = false;

  String name;
  int x, y; // current position on the field
  // private boolean isSelected = false;
  private Button closeMenuButton;
  
  private PImage mImage;

  Entity (JSONObject unitsConfig, String name) {
    super(field);
    this.name = name;

    println();
    println("Configuring entity " + toString());
    JSONObject config = unitsConfig.getJSONObject(name);
    //Food config
    turnsToMake = config.getInt("turnsToMake", 0);
    foodToMake = config.getInt("foodToCost", 0);
    foodUsing = config.getInt("foodConsumption", 0);
    println("Turns to make: " + turnsToMake);
    println("Food to make: " + foodToMake);
    println("Food using: " + foodUsing);
    
    // Behaviours config
    JSONArray behavioursConfig = config.getJSONArray("behaviours");
    println(behavioursConfig);
    
    for ( int i = 0; i < behavioursConfig.size(); i++ ) {
      JSONObject behConfig = behavioursConfig.getJSONObject(i);
      // typeName -> Class
      Behaviour beh = buildBehaviour(this, behConfig);
      behaviours.add(beh);
    }
    
    // Configuring image
    PImage mask = null;
    try {
      mImage = loadImage(config.getString("picture"));
      mask = loadImage(config.getString("mask"));
    } catch (Exception e) {
      println("No picture/mask specified for " + name);
    }
    if(mImage != null && mask != null) {
      mImage.mask(mask);
    }
    int newHeight = round(mImage.height * HEX_SIDE_SIZE / mImage.width);
    mImage.resize(round(HEX_SIDE_SIZE), newHeight);
    
    // Configuring icon
    final Entity self = this;
    icon = new RectButton ( this, name, 
      HEX_SIDE_SIZE/2, 
      - 3*HEX_SIDE_SIZE/4,
      HEX_SIDE_SIZE,
      25);
    icon.callback = new Callback() {
      @Override
      public void callback() {
        self.select();
      }
    };
    icon.label.padding = 0;
    addChild(icon);
    
    // Setting up z coords (for drawing)
    z = new Float(defaultEntityZ);
    icon.z = new Float(z - 0.5);
    icon.label.z = new Float(z - 0.5);
    
    // Configuring menu and info widgets
    info = new Widget(null, new PVector(0, 300));
    menu = new Widget(null, new PVector(width - 300, 0));
    
    updateMenuInfo();
  }
  
  // init is used when the entity is placed on the field.
  // After init Entity starts to update and draw.
  void init(HexCoor hexCoor) {
    hasInit = true;
    x = hexCoor.x;
    y = hexCoor.y;
    coor = new PVector(field.hexToCoor(hexCoor).x, field.hexToCoor(hexCoor).y);
    for ( Behaviour b : behaviours ) {
      b.init();
    }
    drawer.addWidget(this);
  }

  /*Entity clone() {
    Entity clone = new EntityBuilder( name, x, y )
      //.setCbs(canBeSelected)
      .setFtd(foodToMake)
      .setTtd(turnsToMake)
      .setFus(foodUsing)
      .setPlayer(player)
      .build();
    return clone;
  }*/
  // updates menu and info widgets with all behaviours' widgets
  void updateMenuInfo() {
    final Entity self = this;

    menu.children.clear();
    info.children.clear();
    Label infoNameLabel = new Label(info);
    infoNameLabel.text = name;
    infoNameLabel.fill = 0;
    infoNameLabel.background = color(200, 170, 0);
    infoNameLabel.textSize = 40;
    info.pack(infoNameLabel);
    Label menuNameLabel = new Label(menu);
    menuNameLabel.text = name;
    menuNameLabel.fill = 0;
    menuNameLabel.background = color(200, 170, 0);
    menuNameLabel.textSize = 50;
    menu.pack(menuNameLabel);
    
    Label behavioursList = new Label(menu);
    for ( Behaviour b : behaviours ) {
      behavioursList.text += b.getName() + ' ';
    }
    behavioursList.fill = 0;
    behavioursList.background = color(200, 170, 0);
    behavioursList.textSize = 30;
    menu.pack(behavioursList);
    
    for ( Behaviour b : behaviours ) {
      Widget mWidget = b.getMenuWidget();
      if (mWidget != null) {
        mWidget.parent = menu;
        menu.pack(b.getMenuWidget());
      }
      Widget iWidget = b.getInfoWidget();
      if (iWidget != null) {
        iWidget.parent = info;
        info.pack(b.getInfoWidget());
      }
    }
    closeMenuButton = new RectButton(menu, "X", 
      200, 0, 100, menuNameLabel.getHeight());
    closeMenuButton.callback = new Callback() {
      @Override
      public void callback() {
        self.deselect();
      }
    };
    menu.addChild(closeMenuButton);
  }
  
  void update() {
    if (!hasInit) return;
    for ( int i = 0; i < behaviours.size(); i++ ) {
      behaviours.get(i).update();
    }
    
    if ( this == selectedEntity ) {
      displayMenu();
    } else {
      hideMenu();
    }
    if ( field.getTargetHex() != null && field.getTargetHex().x == x && field.getTargetHex().y == y ) {
      displayInfo();
    } else {
      hideInfo();
    }
  }
  
  void select() {
    selectedEntity = this;
  }
  
  void deselect() {
    selectedEntity = null;
  }

  void nextTurn() {
    if(!hasInit) return;
    deselect();
    food -= foodUsing;
    for ( Behaviour b : behaviours ) {
      b.nextTurn();
    }
  }
  private boolean isShowingInfo = false;
  private boolean isShowingMenu = false;
  private void displayInfo() {
    if(!isShowingInfo) {
      isShowingInfo = true;
      currScene.addChild(info);
      drawer.addWidget(info);
    }
  }
  private void hideInfo() {
    if(isShowingInfo) {
      isShowingInfo = false;
      currScene.removeChild(info);
      drawer.removeWidget(info);
    }
  }
  private void displayMenu() {
    if(!isShowingMenu) {
      isShowingMenu = true;
      currScene.addChild(menu);
      drawer.addWidget(menu);
    }
  }
  private void hideMenu() {
    if(isShowingMenu) {
      isShowingMenu = false;
      currScene.removeChild(menu);
      drawer.removeWidget(menu);
    }
  }

  void draw() {
    if(!hasInit) return;
    pushMatrix();
    transformMatrix();
    if(mImage == null) {
      fill(0, 255, 100);
      ellipse(HEX_SIDE_SIZE, 0, HEX_SIDE_SIZE, HEX_SIDE_SIZE);
    } else {
      imageMode(CENTER);
      image(mImage, HEX_SIDE_SIZE, 0);
    }
    popMatrix();
  }
}



///
///MOVABLES///
///



/*/// Workers ///
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
    return (Worker)new MovableBuilder ( name, x, y )
      //.setCbs(canBeSelected)
      .setFtd(foodToDo)
      .setTtd(turnsToDo)
      .setFus(foodUsing)
      .setPlayer(player)
      .build();
  }

  void updateMenu() {
    super.updateMenu();
    if ( toBuild.isPressed() ) {
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
      //.setCbs(canBeSelected)
      .setFtd(foodToDo)
      .setTtd(turnsToDo)
      .setPlayer(player)
      .setFus(foodUsing));
  }

  void build () {
    //nest.isSelected = false;
    entities.add( new Nest( new EntityBuilder( "Builded nest", x, y )
      //.setCbs(canBeSelected)
      .setPlayer(player)
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
      //.setCbs(canBeSelected)
      .setFtd(foodToDo)
      .setTtd(turnsToDo)
      .setFus(foodUsing)
      .setPlayer(player));
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
    if ( toBuild.isPressed() && leftTurns <= 0 ) {
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
      //.setCbs(canBeSelected)
      .setFtd(foodToDo)
      .setTtd(turnsToDo)
      .setFus(foodUsing)
      .setPlayer(player)
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
      //.setCbs(canBeSelected)
      .setFtd(foodToDo)
      .setTtd(turnsToDo)
      .setFus(foodUsing)
      .setPlayer(player)
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
    updateParams();
    menu = new ArrayList<RectButton>();
    updateButtons();
  }

  void updateParams() {
    speed = (int)1e+5;
    size = 0;
    foodUsing = 0;
    for ( Movable i : insects ) {
      if ( i.speed < speed ) {
        speed = i.speed;
        println(speed);
      }
      size+=i.size;
      foodUsing+=i.foodUsing;
    }
  }

  void removeInsect ( Movable ins ) {
    entities.add( ins );
    //ins.canBeSelected = true;
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

  void joinSquad( Squad sq ) {
    while ( insects.size() != 0 ) {
      insects.get(0).joinSquad(sq);
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
      fill(0, 0, 255);
      stroke(0);
      b.draw();
    }
  }

  void nextTurn() {
    super.nextTurn();
    for ( Movable en : insects ) {
      en.nextTurn();
    }
  }
}*/
