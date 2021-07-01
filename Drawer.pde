import java.util.TreeMap;
import java.util.Iterator;
import java.util.Comparator;
import java.util.Map;


class Drawer {
  // Map z -> Widget
  // Used in drawing
  // Widgets with greater z coor will appear farther away (on the background)
  // For exaple, all UI elements should appear closer, than the field.
  // TreeMap is used to sort all Widgets by their z axis.
  
  private TreeMap<Float, ArrayList<Widget>> allWidgets = 
    new TreeMap<Float, ArrayList<Widget>>(
    new Comparator<Float>() {
      public int compare(Float o1, Float o2) {
        return Float.compare(o2, o1);
      }
    });
  
  void draw() {
    for ( Map.Entry<Float, ArrayList<Widget>> entry : allWidgets.entrySet() ) {
      for ( Widget w : entry.getValue() ) {
        w.draw();
      }
    }
  }
  
  void addWidget(Widget w) {
    println("Adding widget to drawer: " + w);
    if ( !allWidgets.containsKey(w.z) ) allWidgets.put(w.z, new ArrayList<Widget>());
    // Adding object
    allWidgets.get(w.z).add(w);
    // Adding all children
    for ( Widget child : w.children ) {
      addWidget(child);
    }
  }
  
  void removeWidget(Widget w) {
    println("Removing widget from drawer: " + w);
    if ( w == null ) {
      println("Removing null from the Drawer!");
      return;
    }
    if ( !allWidgets.containsKey(w.z) ) {
      println("Removing non-existing widget (z not found) from Drawer: " + w);
      return;
    }
    // Removing object
    if ( !allWidgets.get(w.z).contains(w) ) {
      println("Removing non-existing widget from Drawer: " + w);
      return;
    }
    allWidgets.get(w.z).remove(w);
    if ( allWidgets.get(w.z).isEmpty() ) {
      allWidgets.remove(w.z);
    }
    // Removing all children
    for ( Widget child : w.children ) {
      removeWidget(child);
    }
  }
}
