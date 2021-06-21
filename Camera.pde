class Camera {
  private PVector camPos = new PVector(0, 0);
  private boolean movingUp = false;
  private boolean movingLeft = false;
  private boolean movingRight = false;
  private boolean movingDown = false;
  private boolean scalingIn = false;
  private boolean scalingOut = false;
  private float scaleFactor = 1;
  private float cameraSpeed = 15;
  
  
  PVector getCameraPos() {
    return new PVector(camPos.x, camPos.y);
  }
  
  float getScaleFactor() {
    return scaleFactor;
  }
  

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

  void mouseDragged() {
    if ( mode == modeType.game ) {
      if ( mouseButton == LEFT ) {
        camPos.add( mouseX - pmouseX, mouseY - pmouseY );
      }
    }
  }

  void update() {
    if (movingUp) {
      camPos.y += cameraSpeed;
    }
    if (movingLeft) {
      camPos.x += cameraSpeed;
    }
    if (movingDown) {
      camPos.y -= cameraSpeed;
    }
    if (movingRight) {
      camPos.x -= cameraSpeed;
    }
  }
}
