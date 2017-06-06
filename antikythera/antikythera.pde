Player player;
PriorityQueue enemyContainer;
LLStack Upgrades; 
boolean continueGame; 
boolean paused;
int circleSize, currentScore, highScore, difficulty, difficulty2; //difficulty is a var for time in sec and difficulty2 is a var for time in millisec

void setup() {
  background(0); 
  fullScreen();
  //drawIntroMenu();
  //size(600, 600);
  continueGame = true;
  paused = false; 
  circleSize = 15; 
  //currentScore = highScore = 0; 
  player = new Player();
  enemyContainer = new PriorityQueue();
  Upgrades = new LLStack(); 
  difficulty = 3; 
  difficulty2 = 55;
}

void draw() {
  if (continueGame) {
    determineDifficulty();
    background(0);
    //frameRate(10);
    drawCircle(); 
    currentScore += (int) (10/6); //equal to 1 point per millisecond
    textSize(50); 
    text(currentScore, width/2 - 25, height/2 + 15);    
    player.drawCharacter();
    addEnemy(); //will only add enemy every 5 seconds
    drawEnemies(); 
    cleanEnemies();
    stroke(255);
    //line(enemy1.getPosX(), enemy1.getPosY(), player.getPosX(), player.getPosY());
    stroke(0);
    if (isDead() || paused)
      continueGame = false;
  } else if (paused && !continueGame) {
    background(0); 
    drawUpgradeMenu();
  } else if (!paused && !isDead())
    continueGame = true;
  else {
    background(0);
    fill(255); 
    textSize(50); 
    text(currentScore, width/2 - 25, height/2 + 15); //prints final score
    if (currentScore >= highScore) {
      highScore = currentScore; 
      textSize(20); 
      text("Congratulations! You beat the highscore", width/2 - 150, height/2 - 40);
    }
  }
}


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
  text("Cost:500", width/8 + 25, height/2 + 100);
  //description  
  textSize(20);
  fill(0);
  text("earn double points for a", width/8 + 5, height/2 + 145);
  text("limited amount of time", width/8 + 7, height/2 + 180);
  //slow down    
  fill(255);
  rect(width/2 - 135, height/2, 250, 200);
  textSize(30);
  fill(0);
  text("Slow Down", width/2 - 90, height/2 + 40);
  text("Cost:300", width/2 - 90, height/2 + 100);
  textSize(20);
  fill(0);
  text("slow down enemies", width/2 - 100, height/2 + 165);
  //tbd
  fill(255);
  rect(5*(width/8) + 55, height/2, 250, 200);
  textSize(30);
  fill(0);
  text("TBD", 5*(width/8) + 50, height/2 + 40);
  textSize(20);
  fill(0);
  text("tbd", 5*(width/8) + 50, height/2 + 80);
}

//draws the most recently acquired upgrade on the side of the 
void drawUpgradeContainer() {
}

//draws start menu
void drawIntroMenu(){
 background(0);
 fill(255);
 textSize(60);
 text("Antikythera",width/2 - 75, height/2 - 200);
 //play button
 fill(255);
 rect(width/2 - 75, height/2, 150, 100);
 fill(0);
 textSize(30);
 text("Play",width/2 - 65, height/2 + 30);
 //instructions button
 fill(255);
 rect(width/2 - 75, height/2 + 200, 150, 100);
 fill(0);
 textSize(30);
 text("Instructions",width/2 - 70, height/2 + 30);
}

//draws instructions for gameplay
void drawInstructions(){
  background(0);
  fill(255);
  textSize(40);
  text("Instructions", width/2 - 75, height/2 - 200);
  textSize(20);
  text("Press the spacebar to switch sides and avoid enemies",width/2 - 100, height/2 - 100);
  text("Press P to pause game and buy an upgrade if you have enough points", width/2 - 150, height/2);
  text("You can only pause after getting at least 500 points", width/2 - 200, height/2 + 100);
  text("press spacebar to start game!",width/2 - 50, height/2 + 150);
}

//switches character's edge upon hitting space
void keyPressed() {
  if (key == ' ') { 
    if (continueGame)
      player.switchSides();
    else {
      player = new Player(); 
      currentScore = 0; 
      enemyContainer = new PriorityQueue();      
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

void cleanEnemies() {
  if (enemyContainer.isEmpty())
    return; 
  if (enemyContainer.pop().isDead())
    enemyContainer.remove();
}