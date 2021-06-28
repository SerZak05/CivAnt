enum modeType { //<>//
  menu, game, help;
}

modeType mode = modeType.menu;

final int PLAYER_NUM = 0;

Camera camera;

Widget currScene = null;
Widget mainMenuWidget, gameWidget;

final float HEX_SIDE_SIZE = 50;
Field field;

ArrayList<Entity> entities;
Entity selectedEntity = null;

JSONObject unitsConfig;

float food = 100, income = 0; // overall food supply

void setup() {
  fullScreen();
  textSize(40);
  mainMenuWidget = new Widget(null, new PVector(width / 2, height / 4));
  gameWidget = new Widget(null);
  {
    Label l = new Label(mainMenuWidget);
    l.textSize = 70;
    l.textAlignment = LEFT;
    l.fill = color(50, 255, 0);
    l.text = "CivAnt";
    mainMenuWidget.pack(l);
  }
  {
    RectButton b = new RectButton( mainMenuWidget, "Play", 
      0, 0, 
      textWidth("Play"), textAscent()+textDescent() );
    b.callback = new Callback() {
      @Override
        public void callback() {
        mode = modeType.game;
      }
    };
    mainMenuWidget.pack(b);
  }
  {
    RectButton b = new RectButton( mainMenuWidget, "Help", 
      0, 0, 
      textWidth("Help"), textAscent()+textDescent() );
    b.callback = new Callback() {
      @Override
        public void callback() {
        mode = modeType.help;
      }
    };
    mainMenuWidget.pack(b);
  }
  {
    RectButton b = new RectButton( mainMenuWidget, "Quit", 
      0, 0, 
      textWidth("Quit"), textAscent()+textDescent() );
    b.callback = new Callback() {
      @Override
        public void callback() {
        exit();
      }
    };
    mainMenuWidget.pack(b);
  }

  CircButton backToMenuButton = new CircButton(gameWidget, "Back to menu", 15, 15, 100);
  backToMenuButton.callback = new Callback() {
    @Override
      public void callback() {
      mode = modeType.menu;
    }
  };

  gameWidget.addChild(backToMenuButton);

  camera = new Camera();

  //shapeMode(CENTER);
  rectMode(CORNERS);
  textAlign( LEFT, TOP );
  FieldGenerator gen = new FieldGenerator ( 20, 30, (int)random(1e+9) );
  field = gen.generateField();
  println(gen.seed);
  gameWidget.addChild(field);

  unitsConfig = loadJSONObject("assets/units.json");
  entities = new ArrayList<Entity>();
  Entity e = new Entity(unitsConfig, "Recon");
  e.init(new HexCoor(0, 0));
  entities.add(e);
  
  Entity nest = new Entity(unitsConfig, "Nest");
  nest.init(new HexCoor(2, 2));
  entities.add(nest);
  
  /* //entities.add ( new Movable ( "Long name of an ant", 4, 3, 4, 0 ) );
   entities.add ( new Nest( new EntityBuilder( "Nest", 2, 5 )
   .setFus(3)));*/
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

void mouseDragged() {
  camera.mouseDragged();
}

void keyPressed () {
  camera.keyPressed();
  // next turn
  if ( mode == modeType.game ) {
    switch ( key ) {
    case ' ':
      nextTurn();
      break;
    }
  }
}

void keyReleased() {
  camera.keyReleased();
}

void draw() {
  background(0);
  if (currScene != null) {
    currScene.updateChildren();
    currScene.drawChildren();
  }
  switch ( mode ) {
  case menu:
    currScene = mainMenuWidget;
    break;
  case game :
    currScene = gameWidget;
    camera.update();
    updateIncome();


    fill ( 255 );
    textSize ( 30 );
    text ( "Food: " + (int)food, 100, 10 );
    fill ( income < 0 ? color(255, 0, 0) : color(0, 255, 0) );
    text ( (int)income, 120+textWidth("Food " + (int)food ), 10 );
    textSize ( 15 );
    fill ( 255, 0, 0 );
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
