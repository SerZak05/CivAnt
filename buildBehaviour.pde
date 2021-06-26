// Function that build behaviour from JSON file.
// It selects certain type of behaviour according to type (String) from file

Behaviour buildBehaviour(Entity e, JSONObject config) {
  Behaviour res = null;
  String type = config.getString("type");
  switch(type) {
    case "Movable":
      res = new Movable(e, config);
    break;
  }
  return res;
}
