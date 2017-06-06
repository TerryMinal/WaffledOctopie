class Enemy extends Character {
  protected int priority; //lower number is higher priority 
  protected int bornTime;
  protected float timeExisted; //enemy dies after 5 seconds
  protected boolean shouldFlickr; 
  
  public Enemy() {
    super(width/2, height/2, 400, 40, (int) random(0, 360), true, color(180, 0, 0)); 
    priority = 0;
    bornTime = second()%60;
    timeExisted = 0;
    shouldFlickr = true; 
    if (random(100) < 50) {
      out = true;
    } else
      out = false; 
    super.switchSides();
    posX = width/2 + radius * cos(radians(angle));
    posY = height/2 + radius * sin(radians(angle));
  }

  public Enemy(float posX, float posY, float radius, int size, int angle, 
    boolean out, color myColor, int inputPriority) {
    super(posX, posY, 400, size, angle, out, myColor); 
    shouldFlickr = true; 
    bornTime = second()%60;
    timeExisted = 0;
    priority = inputPriority;
    super.radius = radius;
  }

  public void drawCharacter() {
    if (isFlickr())
      fill(100); //enemy is not active/detectable at this point
    else 
      fill(myColor);
    noStroke();
    ellipse(posX, posY, size, size);
    updateCoordinates();
    stroke(10); //resets stroke
    fill(255); //resets fill color to white
  }

  public void updateCoordinates() {
    angle = (angle - 2) % 360; //changing 2 will change the speed in which the character moves around the circle 
    posX = width/2 + radius * cos(radians(angle));  //width/2 centers the x cor of character
    posY = height/2 + radius * sin(radians(angle)); //height/2 centers the y cor of character
  }


 //determines whether the enemy is being previewed or has actually spawned and can kill player
  public boolean isFlickr() {
    if (second()%60 - bornTime <= 2 && shouldFlickr) {
      if (second()%60 - bornTime == 2)
        shouldFlickr = false;
      return true; 
    }
    else 
      return false;
  }
  

  public boolean isDead() {
    timeExisted += (float) 1/60; //adds 1 for every frame equating to adding 1 per second
    if (timeExisted >= 5 && !isFlickr())
      return true; 
    else 
      return false;
  }
  
  public int getPriority() {
    return priority;
  }
}