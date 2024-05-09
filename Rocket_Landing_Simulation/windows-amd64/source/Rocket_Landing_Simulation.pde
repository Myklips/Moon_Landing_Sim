PShape rocket;  //<>//

int terrainSize = 257; // Increase the size of the terrain grid
float[][] terrain = new float[terrainSize][terrainSize];
float roughness = 0.4; // Reduce the roughness for a smoother terrain

float gravity = 1; // Adjust the strength of gravity
float rocketY = -120; // Initial Y position of the rocketship above the terrain
boolean landed = false; // Flag to track if the rocket has landed

float landingRotation = 0.05;
boolean landingRotated = false; 

boolean thrustersActive = false; // Flag to track if thrusters are active
float thrustPower = 0.3; // Power of thrust

PVector landingNormal; 

void setup() {
  size(800, 600, P3D);
  generateTerrain();
  

  rocket = loadShape("rocket.obj"); 
  rocket.scale(0.03); 
  
  
  rocket.rotateX(PI);
}

void draw() {
  background(80, 81, 80); 
  

  camera(0, -100, -120,  
         0, 0, 0,       
         0, 1, 0);     
  
  // Rotate the scene by 180 degrees around the Y-axis
  rotateY(PI);
  
  
  for (int x = 0; x < terrainSize - 1; x++) {
    beginShape(TRIANGLE_STRIP);
    for (int y = 0; y < terrainSize; y++) {
      // Render terrain upright
      vertex(x - terrainSize/2, terrain[x][y], y - terrainSize/2);
      vertex(x + 1 - terrainSize/2, terrain[x + 1][y], y - terrainSize/2);
    }
    endShape();
  }
  
 
  fill(246, 241, 213);
  
 
  pushMatrix();
  translate(0, rocketY - rocket.getHeight() * 0.5, 0); 
  

  if (landed) {
    rotateTerrainNormal(landingNormal);
    landingRotated = true; // Set flag to indicate rotation has been applied
  }
  
  shape(rocket);
  popMatrix();
  
  // Apply gravity to rocketship
  if (!landed && rocketY < getTerrainHeight(0, 0) + rocket.getHeight() * 0.5 - 3) {
    if (thrustersActive) {
      rocketY += thrustPower; // Adjust the rocketship's position with thrust power
    } else {
      rocketY += gravity; // Adjust the rocketship's position with full gravity
    }
  }
  
  // Check if rocket has landed
  if (!landed && rocketY >= getTerrainHeight(0, 0) + rocket.getHeight() * 0.5 - 3) {
    landed = true; 
    landingNormal = calculateTerrainNormal(0, 0); // Calculate terrain normal at rocket's position
  }
}

float getTerrainHeight(float x, float z) {
  int terrainX = int(map(x, -width/2, width/2, 0, terrainSize - 1));
  int terrainZ = int(map(z, -height/2, height/2, 0, terrainSize - 1));
  terrainX = constrain(terrainX, 0, terrainSize - 1);
  terrainZ = constrain(terrainZ, 0, terrainSize - 1);
  return terrain[terrainX][terrainZ];
}

void generateTerrain() {
  terrain[0][0] = random(0, 100);
  terrain[0][terrainSize-1] = random(0, 100);
  terrain[terrainSize-1][0] = random(0, 100);
  terrain[terrainSize-1][terrainSize-1] = random(0, 100);
  
  int step = terrainSize - 1;
  float scale = 100; // Initial scale of the terrain
  
  while (step > 1) {
    // Diamond step
    for (int y = 0; y < terrainSize - 1; y += step) {
      for (int x = 0; x < terrainSize - 1; x += step) {
        float avg = (terrain[x][y] + terrain[x+step][y] + terrain[x][y+step] + terrain[x+step][y+step]) / 4;
        terrain[x+step/2][y+step/2] = avg + random(-scale, scale);
      }
    }
    
    // Square step
    for (int y = 0; y < terrainSize - 1; y += step/2) {
      for (int x = (y + step/2) % step; x < terrainSize - 1; x += step) {
        float avg = 0;
        int count = 0;
        if (x - step/2 >= 0) {
          avg += terrain[x-step/2][y];
          count++;
        }
        if (x + step/2 < terrainSize) {
          avg += terrain[x+step/2][y];
          count++;
        }
        if (y - step/2 >= 0) {
          avg += terrain[x][y-step/2];
          count++;
        }
        if (y + step/2 < terrainSize) {
          avg += terrain[x][y+step/2];
          count++;
        }
        terrain[x][y] = avg / count + random(-scale, scale);
      }
    }
    
    step /= 2;
    scale *= roughness;
  }
}

// Activate thrusters when up arrow is pressed
void keyPressed() {
  if (keyCode == UP) {
    thrustersActive = true;
  }
}


void keyReleased() {
  if (keyCode == UP) {
    thrustersActive = false;
  }
}


PVector calculateTerrainNormal(float x, float z) {
  PVector[] vertices = new PVector[4];
  
  vertices[0] = new PVector(x - 1, getTerrainHeight(x - 1, z), z);
  vertices[1] = new PVector(x + 1, getTerrainHeight(x + 1, z), z);
  vertices[2] = new PVector(x, getTerrainHeight(x, z - 1), z - 1);
  vertices[3] = new PVector(x, getTerrainHeight(x, z + 1), z + 1);
  
 
  PVector edge1 = PVector.sub(vertices[1], vertices[0]);
  PVector edge2 = PVector.sub(vertices[2], vertices[0]);
  PVector normal1 = edge1.cross(edge2);
  
  edge1 = PVector.sub(vertices[2], vertices[1]);
  edge2 = PVector.sub(vertices[3], vertices[1]);
  PVector normal2 = edge1.cross(edge2);
  
  // Average the normals to get a smoother result
  PVector terrainNormal = normal1.add(normal2).normalize();
  
  return terrainNormal;
}

// Rotate the rocketship based on terrain normal
void rotateTerrainNormal(PVector terrainNormal) {
  float rotationAngle = PVector.angleBetween(new PVector(0, 1, 0), terrainNormal);
  float softenedRotationAngle = rotationAngle * 0.3;
  // Rotate the rocketship around the axis of terain normal
  rotate(softenedRotationAngle, terrainNormal.x, terrainNormal.y, terrainNormal.z);
}
