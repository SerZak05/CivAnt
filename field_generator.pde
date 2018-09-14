class FieldGenerator {
  int x, y;
  int grassClusters = 10;
  int clusterSize = 50;
  int riverLength = 20;
  int riverNum = 2;
  int seed;
  FieldGenerator ( int x, int y, int seed ) {
    this.seed = seed;
    randomSeed ( seed );
    this.x = x;
    this.y = y;
  }

  Field generateField() {
    Field result = new Field ( x, y );

    /// generating graas clusters ///
    for ( int i = 0; i < grassClusters; i++ ) {
      ArrayList<HexCoor> cluster = new ArrayList<HexCoor>();
      //result.hexes[randomHex().x][randomHex().y].resource = ResourceType.Grass;
      cluster.add( randomHex() );

      ArrayList<HexCoor> neighbours = new ArrayList<HexCoor>();
      // setting up neighbours
      HexCoor[] neigh = result.getNeigh ( cluster.get(0).x, cluster.get(0).y );
      for ( HexCoor hex : neigh ) {
        if ( hex.x < 0 || hex.x >= result.w || hex.y < 0 || hex.y >= result.h ) {
          continue;
        }
        neighbours.add ( hex );
      }

      for ( int j = 0; j < clusterSize; j++ ) {
        if ( neighbours.isEmpty() ) break;
        HexCoor hex = neighbours.get ( (int)random(neighbours.size()) );
        neighbours.remove ( hex );
        cluster.add ( hex );
        for ( HexCoor h : result.getNeigh ( hex.x, hex.y ) ) {
          if ( h.x < 0 || h.x >= result.w || h.y < 0 || h.y >= result.h ) {
            continue;
          }
          neighbours.add ( h );
        }
      }
      for ( HexCoor hex : cluster ) {
        result.hexes[hex.x][hex.y].resource = ResourceType.Grass;
      }
      for ( int j = 0; j < random ( cluster.size()/2 ); j++ ) {
        HexCoor coor = cluster.get((int)random(cluster.size()));
        result.hexes[coor.x][coor.y].resource = ResourceType.Flower;
      }
    }

    /// generating water ///
    for ( int i = 0; i < riverNum; i++ ) {
      ArrayList<HexCoor> river = new ArrayList<HexCoor>();
      river.add( randomHex() );
      HexCoor hex = river.get(0);
      int rot = (int)random ( 6 );
      for ( int j = 0; j < riverLength; j++ ) {
        rot = (rot+(round(random(-1, 1))))%6;
        if ( rot < 0 ) {
          rot+=6;
        }
        HexCoor newHex = result.getNeigh(hex.x, hex.y)[rot];
        if ( newHex.x < 0 || newHex.x >= result.w || newHex.y < 0 || newHex.y >= result.h ) {
          j--;
          continue;
        }
        hex = newHex;
        river.add(hex);
      }
      for ( HexCoor h : river ) {
        result.hexes[h.x][h.y].capacity = 0;
      }
    }
    return result;
  }

  HexCoor randomHex() {
    return new HexCoor ( (int)random(x), (int)random(y) );
  }
}