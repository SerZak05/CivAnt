enum ModeType { //<>//
  menu, game, help;
}

ModeType mode;

final int PLAYER_NUM = 0;

Camera camera;
Selector selector;

Widget currScene = null;

final float HEX_SIDE_SIZE = 50;
Field field;

JSONObject unitsConfig;

float food = 100, income = 0; // overall food supply

void setup() {
  fullScreen();
  textSize(40);
  
  camera = new Camera();
  selector = new Selector();

  //shapeMode(CENTER);
  rectMode(CORNERS);
  textAlign( LEFT, TOP );
  unitsConfig = loadJSONObject("assets/units.json");
  changeScene(ModeType.menu);
}

void nextTurn() {
  for ( int i = 0; i < field.children.size(); i++ ) {
    ((Entity)field.children.get(i)).nextTurn();
  }
  if ( food < 0 ) {
    food = 0;
  }
  //gatherer.updateNest();
  //gatherer.nextTurn();
}

void keyPressed () {
  camera.keyPressed();
  selector.keyPressed();
  // next turn
  if ( mode == ModeType.game ) {
    switch ( key ) {
    case ' ':
      nextTurn();
      break;
    }
  }
}

void keyReleased() {
  camera.keyReleased();
  selector.keyReleased();
}

void mouseWheel(MouseEvent me) {
  camera.mouseWheel(me.getCount());
}

MouseLoop mouseLoop = new MouseLoop();
void mouseClicked() {
  mouseLoop.processMouseEvent(MouseEventType.CLICKED);
}

void mousePressed() {
  mouseLoop.processMouseEvent(MouseEventType.PRESSED);
}

void mouseDragged() {
  mouseLoop.processMouseEvent(MouseEventType.DRAGGED);
}

void mouseReleased() {
  mouseLoop.processMouseEvent(MouseEventType.RELEASED);
}

Drawer drawer = new Drawer();
void draw() {
  background(0);
  if (currScene != null) {
    currScene.updateChildren();
    drawer.draw();
  }
  switch ( mode ) {
  case game :
    camera.update();
    selector.updateInfo();
    updateIncome();


    fill ( 255 );
    textSize ( 30 );
    text ( "Food: " + (int)food, 200, 20 );
    fill ( income < 0 ? color(255, 0, 0) : color(0, 255, 0) );
    text ( (int)income, 220+textWidth("Food " + (int)food ), 20 );
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
    if ( mousePressed && mouseButton == RIGHT ) changeScene(ModeType.menu);
    break;
  }
}

void updateIncome() {
  income = 0;
  for ( Widget en : field.children ) {
    income -= ((Entity)en).foodUsing;
  }
}
