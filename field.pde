class Hex {
  boolean isVisible = false, isOpened = true;
  int capacity; // over all capacity
  int space; // current capacity
  final PVector center;

  ArrayList<Entity> entities = new ArrayList<Entity>(); // entities, who are on that hex
  ResourceType resource;

  Hex ( PVector coor, int cap ) {
    space = capacity = cap;
    center = new PVector ( coor.x, coor.y );
    resource = ResourceType.None;
  }
  Hex ( PVector coor, int cap, ResourceType r ) {
    space = capacity = cap;
    center = new PVector ( coor.x, coor.y );
    resource = r;
  }

  PShape getShape() {
    PShape shape = createShape();

    shape.beginShape();
    shape.vertex( 0, 0 );
    shape.vertex( HEX_SIDE_SIZE/2, - HEX_SIDE_SIZE/2 );
    shape.vertex( 3*HEX_SIDE_SIZE/2, - HEX_SIDE_SIZE/2 );
    shape.vertex( 2*HEX_SIDE_SIZE, 0 );
    shape.vertex( 3*HEX_SIDE_SIZE/2, HEX_SIDE_SIZE/2 );
    shape.vertex( HEX_SIDE_SIZE/2, HEX_SIDE_SIZE/2 );
    shape.endShape(CLOSE);

    return shape;
  }

  PShape getShape(color fill, color stroke) {
    PShape shape = createShape();

    shape.beginShape();
    shape.vertex( 0, 0 );
    shape.vertex( HEX_SIDE_SIZE/2, - HEX_SIDE_SIZE/2 );
    shape.vertex( 3*HEX_SIDE_SIZE/2, - HEX_SIDE_SIZE/2 );
    shape.vertex( 2*HEX_SIDE_SIZE, 0 );
    shape.vertex( 3*HEX_SIDE_SIZE/2, HEX_SIDE_SIZE/2 );
    shape.vertex( HEX_SIDE_SIZE/2, HEX_SIDE_SIZE/2 );

    shape.fill(fill);
    shape.stroke(stroke);
    shape.endShape(CLOSE);

    return shape;
  }
}

class Field extends Widget {
  int w, h; // width and height of the field
  Hex[][] hexes; // array of the hexagons

  final PShape shape; // shape of the hexagon
  final PShape wall; // wall texture
  PShape[] textures = new PShape[3];
  //PShape grassShape; // grass texture ( for now )

  /// Constructor ///
  Field ( Widget parent, int w_, int h_ ) {
    super(parent, new PVector());
    z = new Float(defaultFieldZ);
    w = w_;
    h = h_;
    hexes = new Hex[w][h];

    // setting all hexes
    PVector coor = new PVector ( 0, height/2 );
    for ( int i = 0; i < w; i++ ) {
      for ( int j = 0; j < h; j++ ) {
        hexes[i][j] = new Hex( coor, 2 );
        coor.y += HEX_SIDE_SIZE/2;
        coor.x += 3*HEX_SIDE_SIZE/2;
      }
      coor.y -= h*HEX_SIDE_SIZE/2 + HEX_SIDE_SIZE/2;
      coor.x -= 3*h*HEX_SIDE_SIZE/2 - 3*HEX_SIDE_SIZE/2;
    }

    // setting the shape
    Hex hex = new Hex(new PVector(), 0);
    wall = hex.getShape(color(0, 0, 200), color(255));

    shape = hex.getShape(color(50), color(255));

    final PShape sandShape = hex.getShape(color(200, 200, 0), color(255));
    textures[0] = sandShape;

    final PShape grassShape = hex.getShape(color(10, 200, 10), color(255));
    textures[1] = grassShape;

    textures[2] = grassShape;
  }

  /*void updateSpace() {
    for ( int i = 0; i < w; i++ ) {
      for ( int j = 0; j < h; j++ ) {
        Hex hex = hexes[i][j]; 
        if ( !hex.isOpened ) {
          hex.space = 0;
          continue;
        }
        hex.space = hex.capacity;
        for ( Entity en : hex.entities ) {
          hex.space -= en.size;
        }
      }
    }
  }*/
  
  // checks if the hexCoor is valid coor and not outside the field
  boolean isHexInside(HexCoor hexCoor) {
    return hexCoor.x >= 0 &&
      hexCoor.x < w &&
      hexCoor.y >= 0 &&
      hexCoor.y < h;
  }
  
  Hex getHex(HexCoor hexCoor) {
    if(!isHexInside(hexCoor)) return null;
    return hexes[hexCoor.x][hexCoor.y];
  }

  /// checking if the relative coor-s are inside hex[i][j] ///
  boolean isInside( int i, int j, float x, float y ) {
    //for (; i >= 0; i-- ) {
    //  shape.translate( HEX_SIDE_SIZE*2, 0 );
    //}
    //for (; j >= 0; j-- ) {
    //  shape.translate( 0, HEX_SIDE_SIZE/2 );
    //}
    boolean result = true;

    for ( int k = 0; k < 6; k++ ) {
      PVector v1, v2;
      v1 = shape.getVertex( k ).add(hexes[i][j].center);
      v2 = shape.getVertex( (k+1) % 6 ).add(hexes[i][j].center);

      float D = (x - v1.x) * (v2.y - v1.y) - (y - v1.y) * (v2.x - v1.x);
      //println ( "Coor-s: ", i, j, "D =", D );
      if ( D > 0 ) result = false;
    }
    shape.resetMatrix();
    //if ( result ) println ( hexes[i][j].center, mouseX, mouseY  );
    return result;
  }

  HexCoor getTargetHex() {
    PVector relCoords = globalToRelCoords(new PVector(mouseX, mouseY));
    return coorsToHex(relCoords.x, relCoords.y);
  }

  // just transforming regular coor-s into hex coor-s
  HexCoor coorsToHex ( float cx, float cy ) {
    for ( int i = 0; i < w; i++ ) {
      for ( int j = 0; j < h; j++ ) {
        if ( isInside( i, j, cx, cy ) ) return new HexCoor ( i, j );
      }
    }
    return null;
  }

  PVector hexToCoor(HexCoor hexCoor) {
    return hexes[hexCoor.x][hexCoor.y].center;
  }

  // just a list of neighbours of hex[i][j]
  HexCoor[] getNeigh ( int i, int j ) {
    HexCoor[] result = new HexCoor[6];
    result[0] = new HexCoor ( i-1, j+1 );
    result[1] = new HexCoor ( i, j+1 );
    result[2] = new HexCoor ( i+1, j );
    result[3] = new HexCoor ( i+1, j-1 );
    result[4] = new HexCoor ( i, j-1 );
    result[5] = new HexCoor ( i-1, j );
    return result;
  }

  /// finding a path from hex[a][b] to hex[c][d] with size s///

  // new A* version yummy!!! //

  ArrayList<HexCoor> path ( int fx, int fy, int tx, int ty, int size ) {
    // quick exit with error  
    if ( tx < 0 || tx > w || ty < 0 || ty > h ) return null;
    if ( field.hexes[tx][ty].space < size ) return null;
    ArrayList<Node> close = new ArrayList<Node>();
    ArrayList<Node> open = new ArrayList<Node>();
    open.add( new Node ( fx, fy, fx, fy ) );

    while ( true ) {
      //println( open, close );
      if ( open.isEmpty() ) return null;
      Node current = open.get(0);
      for ( Node n : open ) {
        if ( n.F < current.F ) current = n;
      }
      open.remove(current);
      close.add(current);

      if ( current.x == tx && current.y == ty ) {
        break;
      }

      for ( int i = 0; i < 6; i++ ) {
        Node neighbour = new Node ( 
          getNeigh(current.x, current.y)[i].x, 
          getNeigh(current.x, current.y)[i].y, 
          current.x, current.y
          );


        if (
          neighbour.x < 0 || neighbour.x >= w || neighbour.y < 0 || neighbour.y >= h || //out of the map
          hexes[neighbour.x][neighbour.y].space < size ) // hex capacity is to small 
        {
          continue;
        }
        //println( neighbour.x, neighbour.y, hexes[neighbour.x][neighbour.y].capacity, size);
        boolean isBeingContained = false; // neighbour <...> by close
        for ( Node n : close ) {
          if ( neighbour.x == n.x && neighbour.y == n.y ) {
            isBeingContained = true;
            break;
          }
        }
        if ( isBeingContained ) continue;


        //println ( "Current node is: " + current.x + ", " + current.y + 
        //  "\nThe neighbour coor-s are : " + neighbour.x + ", " + neighbour.y );
        int G = current.G + 1;
        int H = abs( neighbour.x - tx ) + abs( neighbour.y - ty );
        int F = G + H;
        //println ( "Neighbours' F = " + F );

        if ( !open.contains(neighbour) || F < neighbour.F ) {
          neighbour.G = G;
          neighbour.H = H;
          neighbour.F = F;
          if ( !(open.contains(neighbour) || close.contains(neighbour) ) ) open.add( neighbour );
        }
      }
    }
    ArrayList<HexCoor> result = new ArrayList<HexCoor>();
    Node node = new Node ( 0, 0, 0, 0 );
    for ( Node n : close ) {
      if ( n.x == tx && n.y == ty ) node = n;
    }
    while ( node.x != fx || node.y != fy ) {
      result.add( new HexCoor ( node.x, node.y ) );
      for ( Node n : close ) {
        if ( n.x == node.px && n.y == node.py ) node = n;
      }
    }
    java.util.Collections.reverse(result);

    //println( "Final result: " + result );
    return result;
  }

  // just drawing a path between hex[a][b] and hex[c][d]
  void drawPath ( ArrayList<HexCoor> path ) {
    if ( path == null ) {
      return;
    }
    HexCoor ppv = new HexCoor ( path.get(0).x, path.get(0).y );
    for ( HexCoor pv : path ) {
      PVector currCenter = hexes[pv.x][pv.y].center;
      PVector prevCenter = hexes[ppv.x][ppv.y].center;
      line ( prevCenter.x + HEX_SIDE_SIZE, prevCenter.y, currCenter.x + HEX_SIDE_SIZE, currCenter.y );
      ppv = pv;
    }
  }
  
  void addEntity(Entity e, HexCoor to) {
    e.init(to);
    hexes[to.x][to.y].entities.add(e);
    addChild(e);
  }

  /// drawing the field ///
  void draw() {
    pushMatrix();
    transformMatrix();
    for ( int i = 0; i < w; i++ ) {
      for ( int j = 0; j < h; j++ ) {
        //println ( "Hex[" + i + "][" + j + "] with space " + hexes[i][j].space );
        if ( !hexes[i][j].isOpened ) {
          shape.setFill(255);
          shape( shape, hexes[i][j].center.x, hexes[i][j].center.y );
          continue;
        }
        shape.setFill(true);
        shape.setFill( 50 );

        shape( textures[0], hexes[i][j].center.x, hexes[i][j].center.y );
        //shape( textures[hexes[i][j].resource.ordinal()], hexes[i][j].center.x, hexes[i][j].center.y );

        // draw resource
        switch ( hexes[i][j].resource ) {
          //case None:
          //  shape( shape, hexes[i][j].center.x, hexes[i][j].center.y );
          //  break;
        case Flower:
          //shape.setFill(false);
          shape( textures[1], hexes[i][j].center.x, hexes[i][j].center.y );
          pushMatrix();
          translate ( hexes[i][j].center.x + HEX_SIDE_SIZE, hexes[i][j].center.y );
          noStroke();
          fill ( 200, 0, 0 );
          for ( int k = 0; k < 6; k++ ) {
            ellipse ( HEX_SIDE_SIZE/4, 0, HEX_SIDE_SIZE/2, HEX_SIDE_SIZE/4 );
            rotate( radians(60) );
          }
          fill ( 200, 200, 0 );
          ellipse ( 0, 0, HEX_SIDE_SIZE/2, HEX_SIDE_SIZE/2 );
          popMatrix();
          break;
        case Grass:
          //for ( int k = 0; k < 200; k++ ) {
          //  PVector coor = new PVector ( 0, 0 );
          //  while ( !isInside(i, j, coor.x, coor.y) ) {
          //    coor = new PVector ( random ( hexes[i][j].center.x, hexes[i][j].center.x+HEX_SIDE_SIZE*2 ), 
          //      random ( hexes[i][j].center.y - HEX_SIDE_SIZE/2, hexes[i][j].center.y + HEX_SIDE_SIZE/2 ) );
          //  }
          //  //println ( coor );
          //  stroke ( random(50), 255, 50 );
          //  line ( coor.x, coor.y, coor.x, coor.y-10 );
          shape( textures[1], hexes[i][j].center.x, hexes[i][j].center.y );
          break;
        }
        // draw terrain
        switch ( hexes[i][j].capacity ) {
        case 0 : 
          shape ( wall, hexes[i][j].center.x, hexes[i][j].center.y );
          break;
        case 1 :
          shape ( shape, hexes[i][j].center.x, hexes[i][j].center.y );
          break;
          //if ( hexes[i][j].capacity == 0 ) {
          //  //println ( i, j );
          //  shape ( wall, hexes[i][j].center.x, hexes[i][j].center.y );
          //}
        }
        fill(0);
        textSize(15);
        text("Cap: " + hexes[i][j].capacity + " Sp: " + hexes[i][j].space, hexes[i][j].center.x, hexes[i][j].center.y );
      }
    }
    popMatrix();
  }
}


enum ResourceType {
  None, Grass, Flower;
}


/*class ResourceGatherer extends Entity {
 HexCoor nest; // nearest nest`s coor
 ResourceGatherer ( int x, int y ) {
 super ( new EntityBuilder( "", x, y ) );
 this.x = x;
 this.y = y;
 }
 
 void update() {
 super.update();
 //nx = ny = -1;
 int dist = (int)1e+10;
 for ( Entity en : entities ) {
 //println ( en.getClass().getSimpleName() );
 if ( en instanceof Nest ) {
 if ( nest == null ) {
 nest = new HexCoor( en.x, en.y );
 dist = nest.dist ( new HexCoor( x, y ) );
 //println( "Nest == null", nest.x, nest.y, dist ); 
 continue;
 }
 if ( new HexCoor( x, y ).dist ( new HexCoor(en.x, en.y) ) < dist ) {
 //nx = en.x;
 //ny = en.y;
 nest = new HexCoor( en.x, en.y );
 dist = nest.dist( new HexCoor( x, y ) );
 //println( "Nest != null", en.x, en.y, "", nest.x, nest.y, dist );
 }
 //println ( "Gatherers coor:", x, y, "Nearest nest coor:", nest.x, nest.y, "Current nest coor:", en.x, en.y, dist );
 }
 }
 }
 
 void nextTurn() {
 //food += field.hexes[x][y].resource.ordinal();
 foodUsing = -field.hexes[x][y].resource.ordinal();
 super.nextTurn();
 }
 void draw() {
 stroke ( 0, 150, 0 );
 fill ( 250, 250, 0 );
 ellipse ( field.hexes[x][y].center.x+HEX_SIDE_SIZE, field.hexes[x][y].center.y, 10, 10 );
 stroke ( 0, 255, 0 );
 line ( field.hexes[x][y].center.x+HEX_SIDE_SIZE, field.hexes[x][y].center.y, 
 field.hexes[nest.x][nest.y].center.x+HEX_SIDE_SIZE, field.hexes[nest.x][nest.y].center.y );
 }
 }*/
