class Hex {
  boolean isVisible = false, isOpened = false;
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
}

class Field {
  int w, h; // width and height of the field
  Hex[][] hexes; // array of the hexagons

  final PShape shape; // shape of the hexagon

  /// Constructor ///
  Field ( int w_, int h_ ) {
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
    hexes[5][5].space = 0;
    hexes[5][4].space = 0;
    hexes[5][3].space = 0;
    hexes[4][3].space = 0;
    hexes[3][3].resource = ResourceType.Flower;
    hexes[2][2].resource = ResourceType.Grass;
    hexes[3][2].resource = ResourceType.Grass;

    // setting the shape
    shape = createShape();

    shape.beginShape();
    shape.fill( 0, 255, 0 );
    shape.stroke(255);
    shape.vertex( 0, 0 );
    shape.vertex( HEX_SIDE_SIZE/2, - HEX_SIDE_SIZE/2 );
    shape.vertex( 3*HEX_SIDE_SIZE/2, - HEX_SIDE_SIZE/2 );
    shape.vertex( 2*HEX_SIDE_SIZE, 0 );
    shape.vertex( 3*HEX_SIDE_SIZE/2, HEX_SIDE_SIZE/2 );
    shape.vertex( HEX_SIDE_SIZE/2, HEX_SIDE_SIZE/2 );
    shape.endShape(CLOSE);
  }

  /// checking if the coor-s are inside hex[i][j] ///
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

  // just transforming regular coor-s into hex coor-s
  PVector coorsToHex ( float cx, float cy ) {
    for ( int i = 0; i < w; i++ ) {
      for ( int j = 0; j < h; j++ ) {
        if ( isInside( i, j, cx, cy ) ) return new PVector ( i, j );
      }
    }
    return new PVector ( 0, 0 );
  }

  // just a list of neighbours of hex[i][j]
  PVector[] getNeigh ( int i, int j ) {
    PVector[] result = new PVector[6];
    result[0] = new PVector ( i-1, j+1 );
    result[1] = new PVector ( i, j+1 );
    result[2] = new PVector ( i+1, j );
    result[3] = new PVector ( i+1, j-1 );
    result[4] = new PVector ( i, j-1 );
    result[5] = new PVector ( i-1, j );
    return result;
  }

  /// finding a path from hex[a][b] to hex[c][d] with size s///

  // new A* version yummy!!! //

  ArrayList<PVector> path ( int fx, int fy, int tx, int ty, int size ) {
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
          (int)getNeigh((int)current.x, (int)current.y)[i].x, 
          (int)getNeigh((int)current.x, (int)current.y)[i].y, 
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
    ArrayList<PVector> result = new ArrayList<PVector>();
    Node node = new Node ( 0, 0, 0, 0 );
    for ( Node n : close ) {
      if ( n.x == tx && n.y == ty ) node = n;
    }
    while ( node.x != fx || node.y != fy ) {
      result.add( new PVector ( node.x, node.y ) );
      for ( Node n : close ) {
        if ( n.x == node.px && n.y == node.py ) node = n;
      }
    }
    java.util.Collections.reverse(result);

    //println( "Final result: " + result );
    return result;
  }

  // just drawing a path between hex[a][b] and hex[c][d]
  void drawPath ( ArrayList<PVector> path ) {
    if ( path == null ) {
      return;
    }
    PVector ppv = new PVector ( path.get(0).x, path.get(0).y );
    for ( PVector pv : path ) {
      PVector currCenter = hexes[(int)pv.x][(int)pv.y].center;
      PVector prevCenter = hexes[(int)ppv.x][(int)ppv.y].center;
      line ( prevCenter.x + HEX_SIDE_SIZE, prevCenter.y, currCenter.x + HEX_SIDE_SIZE, currCenter.y );
      ppv = pv;
    }
  }

  /// drawing the field ///
  void draw() {
    for ( int i = 0; i < w; i++ ) {
      for ( int j = 0; j < h; j++ ) {
        //println ( "Hex[" + i + "][" + j + "] with space " + hexes[i][j].space );
        if ( !hexes[i][j].isOpened ) {
          shape.setFill(255);
          shape( shape, hexes[i][j].center.x, hexes[i][j].center.y );
          continue;
        }
        if ( hexes[i][j].space == 0 ) {
          //println ( i, j );
          shape.setFill(true);
          shape.setFill( 0 );
        } else {
          shape.setFill(true);
          shape.setFill( 50 );
        }
        shape( shape, hexes[i][j].center.x, hexes[i][j].center.y );
        switch ( hexes[i][j].resource ) {
        case Grass:
          for ( int k = 0; k < 200; k++ ) {
            PVector coor = new PVector ( 0, 0 );
            while ( !isInside(i, j, coor.x, coor.y) ) {
              coor = new PVector ( random ( hexes[i][j].center.x, hexes[i][j].center.x+HEX_SIDE_SIZE*2 ), 
                random ( hexes[i][j].center.y - HEX_SIDE_SIZE/2, hexes[i][j].center.y + HEX_SIDE_SIZE/2 ) );
            }
            //println ( coor );
            stroke ( random(50), 255, 50 );
            line ( coor.x, coor.y, coor.x, coor.y-10 );
          }
          break;
        case Flower:
          shape.setFill(false);
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
        }
      }
    }
  }
}


enum ResourceType {
  None, Grass, Flower;
}


class ResourceGatherer extends Entity {
  int nx = -1, ny = -1; // nearest nest`s coor
  ResourceGatherer ( int x, int y ) {
    super ( "", x, y, false, 0, 0 );
    this.x = x;
    this.y = y;
  }

  void update() {
    super.update();
    nx = ny = -1;
    float dist = 1e+10;
    for ( Entity en : entities ) {
      if ( en instanceof Nest ) {
        if ( nx == -1 && ny == -1 ) {
          nx = en.x;
          ny = en.y;
          continue;
        }
        if ( PVector.dist ( field.hexes[x][y].center, field.hexes[nx][ny].center ) < dist ) {
          nx = en.x;
          ny = en.y;
          dist = PVector.dist ( field.hexes[x][y].center, field.hexes[nx][ny].center );
        }
      }
    }
  }

  void nextTurn() {
    food += field.hexes[x][y].resource.ordinal();
  }
  void draw() {
    stroke ( 0, 150, 0 );
    fill ( 250, 250, 0 );
    ellipse ( field.hexes[x][y].center.x+HEX_SIDE_SIZE, field.hexes[x][y].center.y, 10, 10 );
    stroke ( 0, 255, 0 );
    line ( field.hexes[x][y].center.x+HEX_SIDE_SIZE, field.hexes[x][y].center.y, 
      field.hexes[nx][ny].center.x+HEX_SIDE_SIZE, field.hexes[nx][ny].center.y );
  }
}