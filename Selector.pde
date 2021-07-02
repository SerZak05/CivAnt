// Selector is used for processing selection of entities on the Field.
// Selector stores all selected entites, sets to draw their menus (as well as processes info widgets too)
import java.util.HashSet;
import java.util.Collection;


final class Selector implements MouseListener {
  // Using HashSet here for quick adding and removing.
  private HashSet<Entity> selectedEntities = new HashSet<Entity>();
  private Widget menu = null, info = null;
  private PVector menuPos = new PVector(width - 300, 0), infoPos = new PVector(0, 300);
  private color menuColor = color(200, 170, 0), infoColor = color(200, 170, 0);
  
  Selector() {
    mouseLoop.addListener(this);
  }
  
  boolean isSelected(Entity e) {
    if ( e == null ) return false;
    return selectedEntities.contains(e);
  }
  
  boolean isSingleSelected(Entity e) {
    return isSelected(e) && selectedEntities.size() == 1;
  }
  
  @Override
  Float getZ() {return defaultEntityZ;}
  
  // Creates menu widget for entity based on its behaviours
  private Widget createMenuForEntity(Entity e) {
    Widget res = new Widget(null, menuPos);
    // Name of the entity
    Label menuNameLabel = new Label(res);
    menuNameLabel.text = e.name;
    menuNameLabel.fill = 0;
    menuNameLabel.background = menuColor;
    menuNameLabel.textSize = 50;
    res.pack(menuNameLabel);

    // List of all behaviours below
    Label behavioursList = new Label(res);
    for ( Behaviour b : e.behaviours ) {
      behavioursList.text += b.getName() + ' ';
    }
    behavioursList.fill = 0;
    behavioursList.background = menuColor;
    behavioursList.textSize = 30;
    res.pack(behavioursList);

    // All behaviours' menus
    for ( Behaviour b : e.behaviours ) {
      Widget mWidget = b.getMenuWidget();
      if (mWidget != null) {
        mWidget.parent = res;
        res.pack(b.getMenuWidget());
      }
    }

    // Closing menu button
    Button closeMenuButton = new RectButton(res, "X", 
      200, 0, 100, menuNameLabel.getHeight());
    closeMenuButton.callback = new Callback() {
      @Override
      public void callback() {
        deselectAll();
      }
    };
    res.addChild(closeMenuButton);

    return res;
  }
  
  // Creats button for entity for selecting
  private Button getButtonForEntity(final Entity e) {
    Button b = new RectButton(null, e.name, width - menuPos.x, 75);
    b.releasedColor = color(255, 0, 0);
    b.pressedColor = color(0, 200, 0);
    b.callback = new Callback() {
      @Override 
      public void callback() {
        println("Selecting one of many");
        deselectAll();
        selectEntity(e);
      }
    };
    return b;
  }
  
  // Creats menu based on selecting one of selected entities
  private Widget createMenuForMultipleEntities() {
    Widget res = new Widget(null, menuPos);

    // Label at the top
    Label multipleLabel = new Label(res);
    multipleLabel.background = menuColor;
    multipleLabel.fill = 0;
    multipleLabel.text = "Multiple selected:";
    multipleLabel.textSize = 30;
    multipleLabel.textAlignment = LEFT;
    res.pack(multipleLabel);

    // Buttons for each of selected entities
    for ( Entity en : selectedEntities ) {
      Button b = getButtonForEntity(en);
      b.parent = menu;
      res.pack(b);
    }
    return res;
  }
  
  void selectEntity(Entity e) {
    selectedEntities.add(e);
    if ( selectedEntities.size() == 1 ) {
      // No entities -> 1 entity
      menu = createMenuForEntity(e);
      drawer.addWidget(menu);
    } else if ( selectedEntities.size() == 2 ) {
      // 1 entity -> multiple entities
      drawer.removeWidget(menu);
      menu = createMenuForMultipleEntities();
      drawer.addWidget(menu);
    } else {
      // Creating new button for new entity
      Button b = getButtonForEntity(e);
      b.parent = menu;
      menu.pack(b);
    }
  }
  
  void deselectEntity(Entity e) {
    selectedEntities.remove(e);
    if ( selectedEntities.isEmpty() ) {
      // 1 entity -> no entities
      drawer.removeWidget(menu);
      menu = null;
    } else if ( selectedEntities.size() == 1 ) {
      // Multiple entities -> 1 entity
      drawer.removeWidget(menu);
      menu = createMenuForEntity(selectedEntities.iterator().next());
      drawer.addWidget(menu);
    } else {
      // Reconfiguring menu panel
      drawer.removeWidget(menu);
      menu = createMenuForMultipleEntities();
      drawer.addWidget(menu);
    }
  }
  
  void deselectAll() {
    selectedEntities.clear();
    drawer.removeWidget(menu);
    menu = null;
  }
  
  // Listens to key presses and releases for SHIFT modifier
  private boolean isShifted = false;
  void keyPressed() {
    if ( keyCode == SHIFT ) 
      isShifted = true;
  }
  
  void keyReleased() {
    if ( keyCode == SHIFT )
      isShifted = false;
  }
  
  // Listens to mouse clicks to update selection
  @Override
  boolean processMouseEvent(MouseEventType t) {
    if ( t != MouseEventType.CLICKED ) return true;
    if ( field == null ) return true;
    HexCoor targetCoor = field.getTargetHex();
    Collection<Entity> entities;
    if ( targetCoor == null ) {
      // If mouse is out of bounds, entities list is empty
      entities = new ArrayList<Entity>();
    } else {
      entities = field.getHex(targetCoor).entities;
    }
    
    if ( !isShifted ) {
      // If shifted, add entities to current selection.
      // Otherwise, deselect all.
      deselectAll();
    } else {
      println("SHIFT");
    }
    
    for ( Entity e : entities ) {
      selectEntity(e);
    }
    return false;
  }
  
  private Widget createInfoWidgetForSingleEntity(Entity e) {
    Widget res = new Widget(null);
    Label sizeLabel = new Label(res);
    sizeLabel.textAlignment = LEFT;
    sizeLabel.textSize = 30;
    sizeLabel.fill = 255;
    sizeLabel.background = color(200, 170, 0);
    sizeLabel.text = "Size: " + e.size;
    res.pack(sizeLabel);
    return res;
  }
  
  // Updates info panel using field targetHex()
  // TODO set this as processEvent on change target event
  void updateInfo() {
    HexCoor targetCoor = field.getTargetHex();
    Collection<Entity> entities;
    if ( targetCoor == null ) 
      entities = new ArrayList<Entity>();
    else
      entities = field.getHex(targetCoor).entities;

    drawer.removeWidget(info);
    if ( entities.isEmpty() ) {
      info = null;
      return;
    }

    info = new Widget(null, infoPos);
    if ( entities.size() == 1 ) {
      Label infoNameLabel = new Label(info);
      infoNameLabel.text = entities.iterator().next().name;
      infoNameLabel.fill = 0;
      infoNameLabel.background = infoColor;
      infoNameLabel.textSize = 40;
      info.pack(infoNameLabel);
      for ( Behaviour b : entities.iterator().next().behaviours ) {
        Widget iWidget = b.getInfoWidget();
        if (iWidget != null) {
          iWidget.parent = info;
          info.pack(b.getInfoWidget());
        }
      }
    } else {
      // Multiple entities on 1 tile
      Label infoNameLabel = new Label(info);
      infoNameLabel.text = "Multiple entities";
      infoNameLabel.fill = 0;
      infoNameLabel.background = infoColor;
      infoNameLabel.textSize = 40;
      info.pack(infoNameLabel);
    }
    drawer.addWidget(info);
  }
}
