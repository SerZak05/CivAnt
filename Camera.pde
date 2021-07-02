final class Camera implements MouseListener {
  private boolean movingUp = false;
  private boolean movingLeft = false;
  private boolean movingRight = false;
  private boolean movingDown = false;
  private boolean scalingIn = false;
  private boolean scalingOut = false;
  private float cameraSpeed = 15;
  private float scalingSpeed = 1.05;
  
  Camera() {
    println("Adding camera");
    mouseLoop.addListener(this);
  }
  
  @Override
  Float getZ() {return 5.0;}

  void keyPressed() {
    switch(key) {
    case 'w':
      movingUp = true;
      break;
    case 'a':
      movingLeft = true;
      break;
    case 's':
      movingDown = true;
      break;
    case 'd':
      movingRight = true;
      break;
    case 'z': 
      scalingIn = true;
      //PVector mousePos = new PVector ( mouseX/scaleFactor, mouseY/scaleFactor );
      //camPos.add( PVector.sub( camPos, mousePos ).div(10) );
      //println ( "MousePos:", mousePos, "camPos:", camPos, "scale:", scaleFactor );
      break;
    case 'x' :
      scalingOut = true;
      break;
    }
  }

  void keyReleased() {
    switch(key) {
    case 'w':
      movingUp = false;
      break;
    case 'a':
      movingLeft = false;
      break;
    case 's':
      movingDown = false;
      break;
    case 'd':
      movingRight = false;
      break;
    case 'z': 
      scalingIn = false;
      //PVector mousePos = new PVector ( mouseX/scaleFactor, mouseY/scaleFactor );
      //camPos.add( PVector.sub( camPos, mousePos ).div(10) );
      //println ( "MousePos:", mousePos, "camPos:", camPos, "scale:", scaleFactor );
      break;
    case 'x' :
      scalingOut = false;
      break;
    }
  }

  @Override
  boolean processMouseEvent(MouseEventType t) {
    if ( t != MouseEventType.DRAGGED ) return true;
    if ( mode == ModeType.game ) {
      if ( mouseButton == LEFT ) {
        field.coor.add( (mouseX - pmouseX) / field.getGlobalScale(), (mouseY - pmouseY) / field.getGlobalScale() );
      }
    }
    return true;
  }
  
  void mouseWheel(float cnt) {
    if (cnt > 0) field.scale /= scalingSpeed;
    if (cnt < 0) field.scale *= scalingSpeed;
  }

  void update() {
    if (movingUp) {
      field.coor.y += cameraSpeed;
    }
    if (movingLeft) {
      field.coor.x += cameraSpeed;
    }
    if (movingDown) {
      field.coor.y -= cameraSpeed;
    }
    if (movingRight) {
      field.coor.x -= cameraSpeed;
    }
    if (scalingIn) {
      field.scale *= scalingSpeed;
    }
    if (scalingOut) {
      field.scale /= scalingSpeed;
    }
  }
}
