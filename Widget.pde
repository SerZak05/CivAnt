static Float defaultZ = new Float(0);
void setZ(float z) {
  defaultZ = z;
}

class Widget {
  protected ArrayList<Widget> children = new ArrayList<Widget>();
  protected Widget parent;
  PVector coor;
  float scale = 1;
  Float z;

  Widget(Widget parent, PVector coor) {
    this.parent = parent;
    z = new Float(defaultZ);
    this.coor = new PVector(coor.x, coor.y);
  }
  
  Widget(Widget parent) {
    this.parent = parent;
    z = new Float(defaultZ);
    coor = new PVector();
  }

  final PVector getGlobalCoords() {
    if (parent == null) { //this Widget is a root
      return coor;
    }
    return PVector.add(PVector.mult(coor, getGlobalScale()), parent.getGlobalCoords());
  }
  
  final float getGlobalScale() {
    if (parent == null) {
      return scale;
    }
    return parent.getGlobalScale() * scale;
  }
  
  final PVector globalToRelCoords(PVector glob) {
    PVector rel_scaled = PVector.sub(glob, getGlobalCoords());
    return rel_scaled.div(getGlobalScale());
  }
  
  final void transformMatrix() {
    if (parent != null) {
      parent.transformMatrix();
    }
    scale(scale);
    translate(coor.x, coor.y);
  }
  
  float getWidth() {
    return 0;
  }
  
  float getHeight() {
    return 0;
  }

  void update() {
  }

  final void addChild(Widget newChild) {
    if(newChild == null) return;
    println("Adding child: " + newChild.toString());
    children.add(newChild);
  }

  final void removeChild(Widget child) {
    println("Removing child: " + child.toString());
    children.remove(child);
  }

  void draw() {
  }

  /*final void drawChildren() {
    for (Widget child : children) {
      pushMatrix();
      translate(coor.x, coor.y);
      child.draw();
      child.drawChildren();
      popMatrix();
    }
  }*/
  
  void updateChildren() {
    for (int i = 0; i < children.size(); i++) {
      children.get(i).update();
      children.get(i).updateChildren();
    }
  }
  
  // Places new child into this widget according to the rule (left to right, etc.)
  // For now, from top to the bottom only
  void pack(Widget newChild) {
    if(newChild == null) return;
    if(children.isEmpty()) {
      newChild.coor = new PVector();
    } else {
      Widget last = children.get(children.size() - 1);
      newChild.coor = new PVector(last.coor.x, last.coor.y + last.getHeight());
    }
    println("New coords: " + newChild.coor.toString());
    addChild(newChild);
  }
}

class Label extends Widget {
  private String text;
  int textSize, textAlignment;
  color fill, background;
  boolean noBackground = false;
  float padding = 10;
  Label(Widget parent, PVector coor) {
    super(parent, coor);
    text = "";
  }
  
  Label(Widget parent) {
    super(parent);
    text = "";
  }

  void setText(String newText) {
    text = newText;
  }
  
  @Override
  float getWidth() {
    pushStyle();
    textSize(textSize);
    float res = textWidth(text) + 2 * padding; 
    popStyle();
    return res;
  }
  @Override
  float getHeight() {
    pushStyle();
    textSize(textSize);
    int lineCount = 1;
    for ( int i = 0; i < text.length(); i++ ) {
      if (text.charAt(i) == '\n') lineCount++;
    }
    float res = (textAscent()+textDescent()) * lineCount + 2 * padding;
    popStyle();
    return res;
  }

  @Override
  void draw() {
    pushMatrix();
    transformMatrix();
    pushStyle();
    textAlign(textAlignment);
    textSize(textSize);
    if(!noBackground) {
      fill(background);
      rectMode(CORNER);
      rect(0, 0, getWidth(), getHeight());
    }
    fill(fill);
    text(text, padding, padding + textAscent());
    popStyle();
    popMatrix();
  }
}

interface Callback {
  void callback();
}

// just a button
class Button extends Widget {
  float sizeX;
  Label label;

  color pressedColor = color(200, 0, 0), releasedColor = color(255, 0, 0);

  Callback callback = null;

  Button ( Widget parent, String name, float x, float y, float sx ) {
    super(parent, new PVector(x, y));
    sizeX = sx;
    initLabel(name);
  }
  
  Button(Widget parent, String name, float size) {
    super(parent);
    sizeX = size;
    initLabel(name);
  }
  
  private void initLabel(String text) {
    label = new Label(this, new PVector(0, 0));
    label.text = text;
    label.noBackground = true;
    label.fill = 255;
    label.textSize = 20;
    addChild(label);
  }
  
  boolean mouseHover() {
    return false;
  }
  private boolean pmouseHover = false;
  boolean mouseEnter() {
    return !pmouseHover && mouseHover();
  }
  boolean mouseExit() {
    return pmouseHover && !mouseHover();
  }

  boolean isPressed() {
    return mousePressed && mouseHover();
  }
  private boolean pmousePressed = false;
  boolean isReleased() {
    return pmousePressed && !isPressed() && !mouseExit();
  }

  @Override
    void update() {
    if (isReleased() && callback != null) {
      callback.callback();
    }
    pmouseHover = mouseHover();
    pmousePressed = isPressed();
  }
}

class RectButton extends Button {
  private float sizeY;
  RectButton ( Widget parent, String name, float x, float y, float sx, float sy ) {
    super ( parent, name, x, y, sx );
    sizeY = sy;
  }
  
  RectButton(Widget parent, String name, float sizeX, float sizeY) {
    super(parent, name, sizeX);
    this.sizeY = sizeY;
  }

  @Override
  boolean mouseHover() {
    PVector globalCoors = getGlobalCoords();
    float globalScale = getGlobalScale();
    return 
      mouseX > globalCoors.x && 
      mouseX < globalCoors.x + sizeX * globalScale && 
      mouseY > globalCoors.y && 
      mouseY < globalCoors.y + sizeY * globalScale;
  }

  @Override
  void draw() {
    pushStyle();
    pushMatrix();
    transformMatrix();
    rectMode ( CORNER );
    if (isPressed()) {
      fill(pressedColor);
    } else {
      fill(releasedColor);
    }
    rect ( 0, 0, sizeX, sizeY );
    popStyle();
    popMatrix();
  }
  
  @Override
  float getWidth() {
    return sizeX;
  }
  
  @Override
  float getHeight() {
    return sizeY;
  }
}

class CircButton extends Button {
  CircButton ( Widget parent, String name, float x, float y, float size ) {
    super ( parent, name, x, y, size );
  }

  CircButton ( Widget parent, String name, PVector coor, float size ) {
    super ( parent, name, coor.x, coor.y, size );
  }

  @Override
  boolean mouseHover() {
    PVector globalCoords = getGlobalCoords();
    return dist ( globalCoords.x, globalCoords.y, mouseX, mouseY ) < sizeX * getGlobalScale()/2;
  }

  @Override
  void draw() {
    pushStyle();
    pushMatrix();
    transformMatrix();
    if (isPressed()) {
      fill(pressedColor);
    } else {
      fill(releasedColor);
    }
    ellipse ( 0, 0, sizeX, sizeX );
    popMatrix();
    popStyle();
  }
  
  @Override
  float getWidth() {
    return sizeX;
  }
  
  @Override
  float getHeight() {
    return sizeX;
  }
}


/*class CustomButton extends Button {
  ArrayList<Button> parts;
  CustomButton ( Widget parent, String name, float x, float y, ArrayList p ) {
    super ( parent, name, x, y, 0 );
    parts = p;
  }
  CustomButton ( Widget parent, String name, PVector coor, ArrayList p ) {
    super ( parent, name, coor.x, coor.y, 0 );
    parts = p;
  }

  @Override
    boolean mouseHover() {
    for ( Button button : parts ) {
      if ( button.mouseHover() ) return true;
    }
    return false;
  }

  @Override
    void draw() {
    for ( Button button : parts ) {
      pushStyle();
      button.draw();
      popStyle();
    }
  }
}*/
