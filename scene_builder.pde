void changeScene(ModeType newMode) {
  // Setting mode
  mode = newMode;
  
  // Removing from drawer
  drawer.removeWidget(currScene);
  
  // Creating new scene
  Widget res = new Widget(null);
  switch (newMode) {
  case menu: // Main menu scene
    res = new Widget(null, new PVector(width / 2, height / 4));
    {
      Label l = new Label(res);
      l.textSize = 70;
      l.textAlignment = LEFT;
      l.fill = color(50, 255, 0);
      l.text = "CivAnt";
      res.pack(l);
    }
    textSize(50);
    {
      RectButton b = new RectButton( res, "Play", 
        0, 0, 
        textWidth("Play"), textAscent()+textDescent() );
      b.callback = new Callback() {
        @Override
          public void callback() {
          changeScene(ModeType.game);
        }
      };
      res.pack(b);
    }
    {
      RectButton b = new RectButton( res, "Help", 
        0, 0, 
        textWidth("Help"), textAscent()+textDescent() );
      b.callback = new Callback() {
        @Override
          public void callback() {
          changeScene(ModeType.help);
        }
      };
      res.pack(b);
    }
    {
      RectButton b = new RectButton( res, "Quit", 
        0, 0, 
        textWidth("Quit"), textAscent()+textDescent() );
      b.callback = new Callback() {
        @Override
          public void callback() {
          exit();
        }
      };
      res.pack(b);
    }
    // Setting to draw
    drawer.addWidget(res);
    break;

  case game: // Main game scene
    CircButton backToMenuButton = new CircButton(res, "Back to menu", 15, 15, 100);
    backToMenuButton.callback = new Callback() {
      @Override
        public void callback() {
        changeScene(ModeType.menu);
      }
    };
  
    res.addChild(backToMenuButton);
    
    // Generating field
    FieldGenerator gen = new FieldGenerator ( 20, 30, (int)random(1e+9) );
    field = gen.generateField(res);
    println(gen.seed);
    res.addChild(field);

    // Setting to draw 
    drawer.addWidget(res);

    // Adding starting entities
    Entity e = new Entity(unitsConfig, "Recon");
    Entity nest = new Entity(unitsConfig, "Nest");
    field.addEntity(e, new HexCoor(0, 0));
    field.addEntity(nest, new HexCoor(2, 2));
    break;
  default:
    res = null;
  }
  currScene = res;
}
