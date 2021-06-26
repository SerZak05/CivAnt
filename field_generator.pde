class FieldGenerator {
  final int x, y;
  final int grassClusters = 10;
  final int clusterSize = 50;
  final int rockNum = 10;
  final int rockMaxSize = 5;
  final int riverLength = 20;
  final int riverNum = 2;
  int seed;
  FieldGenerator ( int x, int y, int seed ) {
    this.seed = seed;
    randomSeed ( seed );
    this.x = x;
    this.y = y;
  }

  Field generateField() {
    Field result = new Field(gameWidget, x, y);

    /// generating grass clusters ///
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
    /// generating rocks ///
    for ( int i = 0; i < rockNum; i++ ) {
      int size = (int)random(1, rockMaxSize);
      ArrayList<HexCoor> rock = new ArrayList<HexCoor>(size);
      rock.add( randomHex() );
      ArrayList<HexCoor> neighbours = new ArrayList<HexCoor>();
      // setting up neighbours
      HexCoor[] neigh = result.getNeigh ( rock.get(0).x, rock.get(0).y );
      for ( HexCoor hex : neigh ) {
        if ( hex.x < 0 || hex.x >= result.w || hex.y < 0 || hex.y >= result.h ) {
          continue;
        }
        neighbours.add ( hex );
      }
      for ( int j = 0; j < size; j++ ) {
        float cost = 1e+5;
        HexCoor next = new HexCoor(1000, 1000);
        for ( HexCoor h : neighbours ) {
          float c = random(0.75, 1.25)*h.dist(h);
          if ( cost > c ) {
            next = new HexCoor( h.x, h.y );
          }
        }
        rock.add(next);
        HexCoor[] nextNeigh = result.getNeigh ( next.x, next.y );
        for ( HexCoor hex : neigh ) {
          if ( hex.x < 0 || hex.x >= result.w || hex.y < 0 || hex.y >= result.h ) {
            continue;
          }
          neighbours.add ( hex );
        }
        neighbours.remove(next);
      }
      for ( HexCoor hex : rock ) {
        result.hexes[hex.x][hex.y].capacity = 1;
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
