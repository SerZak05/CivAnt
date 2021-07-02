// MouseLoop -- class to distribute mouse events
// Objects will get their mouse event based on z coordinate
// Objects can block event from going through them (you can't select an entity through button)


import java.util.TreeMap;
import java.util.SortedMap;
import java.util.Map;


enum MouseEventType {
  PRESSED, DRAGGED, RELEASED, CLICKED
}


interface MouseListener {
  // Return false to block mouse event
  boolean processMouseEvent(MouseEventType t);
  // Returns z coordinate of the listener (greater z -> furhter away -> later get event) 
  Float getZ();
}


class MouseLoop {
  private SortedMap<Float, ArrayList<MouseListener>> listeners = new TreeMap<Float, ArrayList<MouseListener>>(
    new Comparator<Float>() {
      @Override
      public int compare(Float o1, Float o2) {
        return Float.compare(o1, o2);
      }
    }
  );
  
  private ArrayList<MouseListener> toAdd = new ArrayList<MouseListener>(), toRemove = new ArrayList<MouseListener>();
  
  void addListener(MouseListener l) {
    toAdd.add(l);
  }
  
  void removeListener(MouseListener l) {
    toRemove.add(l);
  }
  
  // Removes from listening all tree of widgets
  void removeAllTree(Widget w) {
    if ( w == null ) return;
    toRemove.add(w);
    for ( Widget child : w.children ) {
      removeAllTree(child);
    }
  }
  
  private void addListenerToMap(MouseListener l) {
    if ( l == null ) return;
    if ( !listeners.keySet().contains(l.getZ()) ) {
      listeners.put(l.getZ(), new ArrayList<MouseListener>());
    }
    listeners.get(l.getZ()).add(l);
  }
  
  private void removeListenerFromMap(MouseListener l) {
    if ( l == null ) return;
    if ( !listeners.keySet().contains(l.getZ()) ) return;
    listeners.get(l.getZ()).remove(l);
    if ( listeners.get(l.getZ()).isEmpty() )
      listeners.remove(l.getZ());
  }
  
  void updateListeners() {
    for ( MouseListener l : toAdd ) {
      addListenerToMap(l);
    }
    toAdd.clear();
    for ( MouseListener l : toRemove ) {
      removeListenerFromMap(l);
    }
    toRemove.clear();
  }
  
  void processMouseEvent(MouseEventType t) {
    println("MouseEventType: " + t);
    for ( Map.Entry<Float, ArrayList<MouseListener>> entry : listeners.entrySet() ) {
      boolean pass = true;
      for ( MouseListener l : entry.getValue() ) {
        println("Listening: " + l);
        if (!l.processMouseEvent(t)) pass = false;
      }
      if (!pass) break;
    }
    updateListeners();
  }
}
