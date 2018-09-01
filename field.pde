class Hex {
  int capacity; // over all capacity
  int space; // current capacity
  final PVector center;

  ArrayList<Entity> entities = new ArrayList<Entity>(); // entities, who are on that hex

  Hex ( PVector coor, int cap ) {
    space = capacity = cap;
    center = new PVector ( coor.x, coor.y );
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

    // setting the shape
    shape = createShape();

    shape.beginShape();
    shape.stroke(255);
    shape.noFill();
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
        //println( neighbour.x, neighbour.y, hexes[neighbour.x][neighbour.y].capacity, size);

        if (
          neighbour.x < 0 || neighbour.x >= w || neighbour.y < 0 || neighbour.y >= h || //out of the map
          hexes[neighbour.x][neighbour.y].space < size ) // hex capacity is to small 
        {
          continue;
        }
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
        //println ( "Hex[" + i + "][" + j + "] with center in " + hexes[i][j].center );
        shape( shape, hexes[i][j].center.x, hexes[i][j].center.y );
      }
    }
  }
}