Player player;
Enemy enemy; 
PriorityQueue enemyContainer; 
ArrayList<Upgrades> UpgradesDisplayer;
LLStack upgradesStorage; 
LLStack Upgrades; 
int state, previousState; 
boolean useUpgrades;
public int currentScore;
int circleSize, highScore, difficulty, difficulty2; //difficulty is a var for time in sec and difficulty2 is a var for time in millisec


void setup() {
  background(0); 
  fullScreen();
  state = 0;
  //size(600, 600);
  circleSize = 15;
  state = previousState = 0; 
  useUpgrades = false; 
  //currentScore = highScore = 0; 
  player = new Player();
  enemyContainer = new PriorityQueue();
  UpgradesDisplayer = new ArrayList<Upgrades>();
  UpgradesDisplayer.add(new UpgradeDoublePoints()); 
  upgradesStorage = new LLStack();
  //upgradesStorage.push(new UpgradeSlowDown()); 
  Upgrades = new LLStack(); 
  difficulty = 3; 
  difficulty2 = 55;
}

void draw() {
  switch (state) {
  case 0:
    drawIntroMenu(); 
    break; 
  case 1:
    playGame();
    break;
  case 2: //paused menu
    pauseMenu();
    break;
  case 3: 
    resetGame();
    break;
  case 4:
    drawInstructions(); 
    break;
  }
}

//switches character's edge upon hitting space
void keyPressed() {
  if (key == ' ') { 
    if (state == 1)
      player.switchSides();
    else
      state = 1;
  }
  if (key == 'p') {
    if (currentScore >= 300) {
      if (state == 2)
        state = 1;
      else 
      state = 2;
    }
    //if (state == 2) {
    //  if (key == 'q')
    //  if (key == 'w')
    //  if (key == 'e')
    //}
  }
  if (key == '1') {
    if (state == 4)
      state = previousState; 
    else {
      previousState = state;
      state = 4;
    }
  }
  if (key == 's') 
    state = 1;
  if (key == 'z' && !upgradesStorage.isEmpty())
    useUpgrades = true;
}

//------------------ GAME METHODS -------------------
//for when the game is still playing 
void playGame() {
  if (isDead())
    state = 3;
  determineDifficulty();
  background(0);
  //frameRate(10);
  drawCircle(); 
  currentScore += 1; //equal to 60 points per secon
  textSize(50); 
  text(currentScore, width/2 - 25, height/2 + 15);    
  player.drawCharacter();
  addEnemy(); //will only add enemy every 5 seconds
  drawEnemies(); 
  drawUpgrades();
  //addUpgrades();
  if (useUpgrades)
    useUpgrades();
  cleanEnemies();
  stroke(255);
  stroke(0);
}

//when the player enters the pause menu
void pauseMenu() {
  background(0); 
  drawUpgradeMenu();
}

//when the player dies the game resets itself and updates the highscore if need be
void resetGame() {
  background(0);
  fill(255); 
  enemyContainer = new PriorityQueue(); 
  upgradesStorage = new LLStack(); 
  UpgradesDisplayer = new ArrayList<Upgrades>(); 
  textSize(50); 
  text(currentScore, width/2 - 25, height/2 + 15); //prints final score
  if (currentScore >= highScore) {
    highScore = currentScore; 
    textSize(20); 
    text("Congratulations! You beat the highscore", width/2 - 150, height/2 - 40);
  }
  player = new Player(); 
  currentScore = 0;
}
//determines difficulty of game based on currentScore
void determineDifficulty() {
  if (currentScore == 400) {
    difficulty2 = 40;
  }
  if (currentScore == 600) {
    difficulty = 2;
  }
  if (currentScore == 2000) {
    difficulty2 = 30;
  }
  if (currentScore> 4000 && currentScore%1000 == 0 && difficulty2 != 0) {
    if (currentScore == 4000)
      difficulty = 1;
    difficulty2 -= 1;
    System.out.println(difficulty2);
  }
}

// ---------------------------- ENEMY METHODS ---------------------------
boolean isDead() { //checks if the player is touching any enemies at all
  for (int i = 0; i < enemyContainer.size(); i++) {
    if (player.touching(enemyContainer.get(i)))
      return true;
  }
  return false;
}

//every 10 seconds add an enemy . The new enemy is decided randomly
void addEnemy() {
  if (second()%difficulty == 0 && frameCount%difficulty2 == 0) {  //checks to see if x seconds passed and that if it is 1 frame within the 60 fps
    float dec = random(100);
    Enemy adder; 
    if (dec > 50)
      adder = new EnemyOne(); 
    else 
    adder = new Enemy(); 
    enemyContainer.add(adder);
  }
}

void drawEnemies() { //draws all enemies in the priorityQueue
  for (int i = 0; i < enemyContainer.size(); i++) {
    enemyContainer.get(i).drawCharacter();
  }
}

void cleanEnemies() {
  if (enemyContainer.isEmpty())
    return; 
  if (enemyContainer.pop().isDead())
    enemyContainer.remove();
}

void drawUpgrades() {
  Upgrades x;
  for (int i = 0; i < UpgradesDisplayer.size(); i++) {
    x = UpgradesDisplayer.get(i); 
    x.drawUpgrades(); 
    if (player.touchingUpgrades(x)) {
      upgradesStorage.push(x);
      UpgradesDisplayer.remove(i);
    }
  }
}

// ----------------------- UPGGRADE METHODS -----------------------
//debugging
void addUpgrades() { 
  Upgrades adder = new UpgradeDoublePoints() ; 
  UpgradesDisplayer.add(adder);
}

void drawStorageUpgrade() {
  upgradesStorage.peek().drawUpgrades();
}

void useUpgrades() {
  if (upgradesStorage.isEmpty())
    return;
  if (upgradesStorage.peek().stillWorking()) {
    upgradesStorage.peek().useUpgrade();
  } else {
    upgradesStorage.pop();
    useUpgrades = false;
  }
}

// ---------------------------------------------- HARDCODED MENU METHODS -----------------------------------
//draws two circles. There is an outer circle that represents the outer edge circle and an inner
//circle that will help form the inner edge
void drawCircle() {
  float r = 2 * 400 - player.getSize();
  fill(245); 
  ellipse(width/2, height/2, r, r); //draws outer circle
  fill(0); //makes inner circle black. Appears concentric
  ellipse(width/2, height/2, r - 2 * player.getSize() - circleSize, r - 2 * player.getSize() - circleSize); // draws inner circle... 15 is an arbitrary number used for appearance sake
  fill(255); //resets filling to be white
}

//draws the menu for when the player pauses and is making a purchase for upgrades
void drawUpgradeMenu() {
  //ADD CURRENT SCORE IN CORNER
  fill(255);
  textSize(50);
  text("Paused", width/2 - 100, height/2 - 200);
  fill(255);
  textSize(25);
  text("Choose an upgrade for a certain amount of points or press P to return to game", width/6 - 50, height/2 - 100);
  //double points
  fill(255);
  rect(width/8, height/2, 250, 200);
  textSize(30);
  fill(0);
  text("Double Points", width/8 + 25, height/2 + 40);
  text("-500 pts", width/8 + 40, height/2 + 100);
  //description  
  textSize(20);
  fill(0);
  text("earn double points for a", width/8 + 5, height/2 + 155);
  text("limited amount of time", width/8 + 7, height/2 + 180);
  //slow down    
  fill(255);
  rect(width/2 - 135, height/2, 250, 200);
  textSize(30);
  fill(0);
  text("Slow Down", width/2 - 90, height/2 + 40);
  text("-300 pts", width/2 - 80, height/2 + 100);
  textSize(20);
  fill(0);
  text("slow down enemies", width/2 - 100, height/2 + 165);
  //survive three hits
  fill(255);
  rect(5*(width/8) + 55, height/2, 250, 200);
  textSize(27);
  fill(0);
  text("Temporary", 5*(width/8) + 110, height/2 + 30);
  text("Invincibility", 5*(width/8) + 105, height/2 + 60);
  textSize(30);
  text("-700 pts", 5*(width/8) + 120, height/2 + 100);
  textSize(20);
  fill(0);
  text("survive three hits", 5*(width/8) + 90, height/2 + 155);
  text("from an enemy", 5*(width/8) + 100, height/2 + 180);
}

//draws the most recently acquired upgrade on the side of the 
void drawUpgradeContainer() {
}

//draws start menu
void drawIntroMenu() {
  background(0);
  fill(0,100,255);
  textSize(60);
  text("Antikythera", width/2 - 200, height/2 - 200);
  //play
  fill(255);
  textSize(30);
  text("Press s to play", width/2 - 200, height/2 - 40);
  //instructions
  text("Press 1 for instructions", width/2 - 200, height/2 + 40);
}

//draws instructions for gameplay
void drawInstructions() {
  background(0);
  fill(255);
  textSize(40);
  text("Instructions", width/2 - 75, height/2 - 200);
  textSize(20);
  text("Press the spacebar to switch sides and avoid enemies", width/2 - 100, height/2 - 150);
  text("Press P to pause game and buy an upgrade if you have enough points", width/2 - 200, height/2);
  text("You can only pause after getting at least 500 points", width/2 - 200, height/2 + 100);
  text("press spacebar to start game!", width/2 - 50, height/2 + 150);
<<<<<<< HEAD
}

//switches character's edge upon hitting space
void keyPressed() {
  if (key == ' ') { 
    if (continueGame)
      player.switchSides();
    else {
      continueGame = true;
    }
  }
  if (key == 'p') {
    if (currentScore >= 300)
      paused = !paused;
    //if (paused) {
    //  if (key == 'q')
    //  if (key == 'w')
    //  if (key == 'e')
    //}
  }

  //if (introMenu) {

  //}
  if (key == 's') 
    introMenu = false;
  if (key == 'z' && !upgradesStorage.isEmpty())
    useUpgrades = true;
}

//determines difficulty of game based on currentScore
void determineDifficulty() {
  if (currentScore == 400) {
    difficulty2 = 40;
  }
  if (currentScore == 600) {
    difficulty = 2;
  }
  if (currentScore == 2000) {
    difficulty2 = 30;
  }
  if (currentScore> 4000 && currentScore%1000 == 0 && difficulty2 != 0) {
    if (currentScore == 4000)
      difficulty = 1;
    difficulty2 -= 1;
    System.out.println(difficulty2);
  }
}

//every 10 seconds add an enemy . The new enemy is decided randomly
void addEnemy() {
  if (second()%difficulty == 0 && frameCount%difficulty2 == 0) {  //checks to see if x seconds passed and that if it is 1 frame within the 60 fps
    float dec = random(100);
    Enemy adder; 
    if (dec > 50)
      adder = new EnemyOne(); 
    else 
    adder = new Enemy(); 
    enemyContainer.add(adder);
  }
}

void drawEnemies() { //draws all enemies in the priorityQueue
  for (int i = 0; i < enemyContainer.size(); i++) {
    enemyContainer.get(i).drawCharacter();
  }
}

boolean isDead() { //checks if the player is touching any enemies at all
  for (int i = 0; i < enemyContainer.size(); i++) {
    if (player.touching(enemyContainer.get(i)))
      return true;
  }
  return false;
}

void drawUpgrades() {
  UpgradeSlowDown x = new UpgradeSlowDown();
  
  x.drawUpgrades(); 
  /* for (int i = 0; i < UpgradesDisplayer.size(); i++) {
    x = UpgradesDisplayer.get(i); 
    x.drawUpgrades(); 
    if (player.touchingUpgrades(x)) {
      upgradesStorage.push(x);
      UpgradesDisplayer.remove(i);
    }
  }
   */ 
  
}

//debugging
void addUpgrades() { 
  Upgrades adder = new UpgradeDoublePoints() ; 
  upgradesStorage.push(adder);
}

void drawStorageUpgrade() {
  upgradesStorage.peek().drawUpgrades();
}

void useUpgrades() {
  if (upgradesStorage.isEmpty())
    return;
  if (upgradesStorage.peek().stillWorking()) {
    upgradesStorage.peek().useUpgrade();
  } else {
    upgradesStorage.pop();
    useUpgrades = false;
  }
}

void cleanEnemies() {
  if (enemyContainer.isEmpty())
    return; 
  if (enemyContainer.pop().isDead())
    enemyContainer.remove();
=======
>>>>>>> 434d7ce1bc47d7d7a78232dd2b3785f878c12152
}