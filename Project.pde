// Defined data paths ensures this source code compiles out the box
// When launched from the folder provided in the .zip
String jpgpath = "../data/uk-admin.jpg";
String csvpath = "../data/Data.csv";

// initialising our Table object and PImage object to store our csv file and map jpg respectively.
PImage mapImage;
PFont hudFont;
Table table;

// Create an ArrayList to store the cubes
ArrayList<PShape> cubes = new ArrayList<PShape>();

//year controller for data switching
int year = 1991;

// used to detect a double click later in our mousedblclicked() fuction
int dblClick = 0;

// Camera X and Y set to what might come across as seemingly strange values.
// After implementing my cubes properly i had a right barney fixing the positions
// so instead, I just moved the map and camera to match :)
// min X and Y are to help cap off the amount a user can move away from the map for usability.
float cameraX = -541;
float cameraY = -701;
float cameraZ = 0;
float cameraZoom = 1.0;
float pitch = 0.0;
float yaw = 0.0;
float cameraMinX = -900;
float cameraMaxX = -250;
float cameraMinY = -900;
float cameraMaxY = -250;

void setup() {
  size(700, 800, P3D);
  lights();
  //Global ambient light
  ambientLight(50, 50, 50);
  //Direction light to be our "sun"
  directionalLight(255,255,255, 0, 1, -1);
  // Loading our external data
  mapImage = loadImage("V:/Uni/gfx/cw2/data/uk-admin.jpg");
  table = loadTable("V:/Uni/gfx/cw2/data/Data.csv", "header");
  
  smooth(4); // x4 anti aliasing
  
  // mix and max population values, used for colour coding our cubes
  // Does not define anything to do with the data we handle.
  int maxPop = 910000;
  int minPop = 10000;
  
  hudFont = createFont("Arial Bold", 24);


  // Initialising cubes location. This is defined later per cube by the geoloc array coords.
  float xPos = 0.0;
  float yPos = 0.0;

  // This array contains our vector coordinates for each city. Values defined later during setup
  // geolocs = geographical locations
  PVector[] geoloc = new PVector[80];

  // Set up perspective camera projection
  float fov = PI/3.0;
  float aspect = float(width)/float(height);
  float cameraZ = height/(2.0*tan(fov/2.0));
  perspective(fov, aspect, cameraZ/10.0, cameraZ*10.0);
  
  // ====================================== Parsing of data file begins here ====================================
  // Keeping the instrusive junk data at the end of the csv file from ruining the program with great malice
  for (TableRow row : table.rows()) {
    // Declaring id then iterating it, to ensure that our loops later match with the data
    // Not the best solution, suspect this causes some problem that I have yet to discover properly.
    int id = row.getInt("No");
    id--;
    // Helps to prevent any nasty array out of bounds errors
    if (id <= -1) {
      id = 0;
    }
    // Another few lines specifically to prevent the junk data (or junk programming) ruining things
    boolean firstZeroFound = false;
    // If we've already encountered the first instance of an ID of zero, skip any subsequent instances
    if (firstZeroFound && id == 0) {
      continue;
    }
    // If this is the first instance of an ID of zero, mark the flag variable as true so we skip subsequent instances
    if (id == 0) {
      firstZeroFound = true;
    }
    // Initializing population outside of this loop as we use it for our cube colour definition
    // The count of population could do with some normalisation
    // TODO normalise data with [x' = (x - min(x)) / (max(x) - min(x))]
    long population = 0;
    String valueStr = row.getString(Integer.toString(year));
    if (!valueStr.isEmpty() && id <= 80 ) {
      // Removing empty spaces or commas using regular expressions
      valueStr = valueStr.replaceAll("(?<=\\d),(?=\\d)", "");
      // Removing any "..." entries and placing them with an arbitrary value, with 1 being chosen for least visual impact
      valueStr = valueStr.replaceAll("\\.\\.\\.", "1");
      // Converting our string to a long
      population = Long.parseLong(valueStr);
    }
    // ====================================== Parsing of data file ends here ====================================

    // Initialising our gradient colour.
    color cg;
    if (population == 0 || population == 1) {
      cg = color(0, 0, 255); // set to blue where the data is not there, done 0 OR 1 just incase of bad data
    } else {
      // set to gradient between green and red
      cg = lerpColor(color(0, 255, 0), color(255, 0, 0), map(population, minPop, maxPop, 0, 1));
    }

    // Create a cube shape with height based on the population value, capped to prevent
    // London from stealing the show with a supermassive population count comparible to
    // elsewhere, normalisation may resolve this and remove the need for the cap. 
    float cubeHeight = min(population / 5000, 500);
    PShape cube = createShape(BOX, 3, 3, cubeHeight+1);
    // Setting our cube location values based on the contents of geoloc.
    if (id < geoloc.length && geoloc[id] != null) {
      xPos = (geoloc[id].x - geoloc[0].x);
      yPos = (geoloc[id].y - geoloc[0].y);
    }
    // apply our [c]olour [g]radient from earlier
    cube.setFill(cg);
    // Add a thick outline to the cube
    cube.setStroke(color(0)); // Set outline color to black
    cube.setStrokeWeight(1.5); // Set outline thickness to 2
    // Move this instance of the cube to the corresponding cities location
    cube.translate(xPos, yPos, cubeHeight / 2); // Translate the cube along the z-axis by half its height

    // add this cube to our array of cubes.
    cubes.add(cube);

    // Defining the locations of our towns and cities, address index matches data list n-1
    // London:
    geoloc[0] = new PVector(540, 700);
    // Birmingham:
    geoloc[1] = new PVector(459, 603);
    // Glasgow
    geoloc[2] = new PVector(392, 285);
    // Liverpool
    geoloc[3] = new PVector(420, 515);
    // Bristol
    geoloc[4] = new PVector(410, 685);
    // Sheffield
    geoloc[5] = new PVector(490, 528);
    // Manchester
    geoloc[6] = new PVector(456, 515);
    // Leeds
    geoloc[7] = new PVector(497, 492);
    // Edinburgh
    geoloc[8] = new PVector(440, 300);
    // Leicester
    geoloc[9] = new PVector(502, 597);
    // Bradford
    geoloc[10] = new PVector(479, 490);
    // Cardiff
    geoloc[11] = new PVector(378, 675);
    // Coventry
    geoloc[12] = new PVector(478, 613);
    // Nottingham
    geoloc[13] = new PVector(504, 568);
    // Kingston Upon Hull (just hull lol who gave hull such a name)
    geoloc[14] = new PVector(556, 505);
    // Belfast
    geoloc[15] = new PVector(289, 390);
    // Stoke-On-trent
    geoloc[16] = new PVector(453, 557);
    // Newcastle Upon Tyne
    geoloc[17] = new PVector(504, 392);
    // Derby
    geoloc[18] = new PVector(488, 571);
    // Southhampton
    geoloc[19] = new PVector(466, 742);
    // Portsmouth
    geoloc[20] = new PVector(484, 754);
    // Plymouth
    geoloc[21] = new PVector(313, 764);
    // Brighton and Hove
    geoloc[22] = new PVector(534, 757);
    // Reading
    geoloc[23] = new PVector(494, 699);
    // Northampton
    geoloc[24] = new PVector(511, 631);
    // Luton
    geoloc[25] = new PVector(530, 664);
    // Wolverhampton
    geoloc[26] = new PVector(450, 593);
    // Aberdeen
    geoloc[27] = new PVector(510, 203);
    // Bolton
    geoloc[28] = new PVector(445, 506);
    // Bournmouth
    geoloc[29] = new PVector(440, 753);
    // Norwich
    geoloc[30] = new PVector(628, 612);
    // Swindon
    geoloc[31] = new PVector(456, 682);
    // Swansea
    geoloc[32] = new PVector(337, 659);
    // Southend-on-Sea (said like: saaaaaaarfend)
    geoloc[33] = new PVector(587, 702);
    // Middlesbrough
    geoloc[34] = new PVector(519, 433);
    // Sunderland
    geoloc[35] = new PVector(514, 405);
    // Milton Keynes
    geoloc[36] = new PVector(516, 647);
    // Warrington
    geoloc[37] = new PVector(438, 522);
    // Huddersfield
    geoloc[38] = new PVector(488, 505);
    // Peterborough
    geoloc[39] = new PVector(545, 605);
    // Oxford
    geoloc[40] = new PVector(486, 672);
    // Slough
    geoloc[41] = new PVector(517, 698);
    // Poole
    geoloc[42] = new PVector(435, 754);
    // York
    geoloc[43] = new PVector(523, 484);
    // Blackpool
    geoloc[44] = new PVector(420, 481);
    // Dundee
    geoloc[45] = new PVector(465, 257);
    // Cambridge
    geoloc[46] = new PVector(566, 643);
    // Ipswich
    geoloc[47] = new PVector(615, 661);
    // Birkenhead {([avoid])}
    geoloc[48] = new PVector(414, 518);
    // Telford
    geoloc[49] = new PVector(433, 580);
    // Gloucester
    geoloc[50] = new PVector(436, 654);
    // Sale (be careful of sharks)
    geoloc[51] = new PVector(446, 522);
    // Watford
    geoloc[52] = new PVector(529, 684);
    // Newport
    geoloc[53] = new PVector(392, 672);
    // Solihull
    geoloc[54] = new PVector(468, 612);
    // High Wycombe
    geoloc[55] = new PVector(503, 688);
    // Gateshead
    geoloc[56] = new PVector(502, 398);
    // Colchester
    geoloc[57] = new PVector(597, 673);
    // Blackburn
    geoloc[58] = new PVector(452, 486);
    // Cheltenham
    geoloc[59] = new PVector(443, 652);
    // Exeter
    geoloc[60] = new PVector(351, 741);
    // Chelmsford
    geoloc[61] = new PVector(578, 687);
    // Doncaster
    geoloc[62] = new PVector(514, 519);
    // Rotherham
    geoloc[63] = new PVector(503, 531);
    // Eastbourne
    geoloc[64] = new PVector(555, 765);
    // Worthing
    geoloc[65] = new PVector(520, 757);
    // Sutton Coldfield
    geoloc[66] = new PVector(465, 598);
    // Rochdale
    geoloc[67] = new PVector(461, 506);
    // Maidstone
    geoloc[68] = new PVector(577, 725);
    // Basingstoke
    geoloc[69] = new PVector(480, 713);
    // Basildon
    geoloc[70] = new PVector(573, 693);
    // Crawley
    geoloc[71] = new PVector(534, 733);
    // Stockport
    geoloc[72] = new PVector(460, 524);
    // Woking
    geoloc[73] = new PVector(516, 713);
    // Gillingham
    geoloc[74] = new PVector(584, 718);
    // Salford
    geoloc[75] = new PVector(448, 515);
    // Wigan
    geoloc[76] = new PVector(435, 511);
    // St Helens
    geoloc[77] = new PVector(432, 515);
    // Lincoln
    geoloc[78] = new PVector(537, 551);
    // Worcester
    geoloc[79] = new PVector(440, 626);
  }
}

// Keybinds, self explainatory.
// cubes.clear() makes sure any drawn cubes from the previous data set are obliterated.
void keyPressed() {
  switch (key) {
  case '1':
    year = 1991;
    cubes.clear();
    setup();
    break;
  case '2':
    year = 2001;
    cubes.clear();
    setup();
    break;
  case '3':
    year = 2011;
    cubes.clear();
    setup();
    break;
  case 'w':
    pitch += 0.1;
    break;
  case 's':
    pitch -= 0.1;
    break;
  case 'a':
    yaw += 0.05;
    break;
  case 'd':
    yaw -= 0.05;
    break;
  case 'c':
    centerCamera();
    break;
  default:
    if (keyCode == DOWN) {
      cameraY += 10;
    } else if (keyCode == UP) {
      cameraY -= 10;
    } else if (keyCode == RIGHT) {
      cameraX += 10;
    } else if (keyCode == LEFT) {
      cameraX -= 10;
    }
  }
}

// Mousebinds for dragging our view around.
void mouseDragged() {
  cameraX += mouseX - pmouseX;
  cameraY += mouseY - pmouseY;
}

// Scroll to zoom in or out
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (e > 0) {
    cameraZ -= 20;
  } else if (e < 0) {
    cameraZ += 20;
  }
  // Cap the zoom level to prevent over/under zooming
  if (cameraZ < 0.1) {
    cameraZ = 0.1;
  } else if (cameraZ > 600) {
    cameraZ = 600;
  }
}

void mouseClicked() {
  // check if less than 300 ms elapsed, this seems a comfortable timing.
  if (millis() - dblClick < 300) {
    centerCamera();
  }
  dblClick = millis();
}

// Function for camera "centering" for easy calling.
void centerCamera() {
  cameraX = -541;
  cameraY = -701;
  cameraZ = 0;
  cameraZoom = 1.0;
  pitch = 0.0;
  yaw = 0.0;
}

void drawShadows() {
  pushMatrix();
  // Apply a shadow projection matrix
  applyMatrix(1, 0, 0, 0, 0, 1, 0, 0, -1.0 / -1, -1.0 / -1, 1, 0, 0, 0, 0, 1);
  scale(1, 1, 0);
  // Draw the cubes in shadow color
  for (PShape cube : cubes) {
    pushMatrix();
    translate(cube.getVertex(0).x, cube.getVertex(0).y, cube.getVertex(0).z);
    fill(0, 0, 0, 100);
    box(3, 3, cube.getVertex(0).z);
    popMatrix();
  }
  popMatrix();
}

void draw() {
  // Set background to black
  background(0);
  // Put our camera at the defined coords, see comment above value declaration for detail
  translate(-cameraX, -cameraY, cameraZ);
  rotateX(pitch);
  rotateZ(yaw);
  
  // limit the camera's X and Y coordinate to the specified range for each draw, prevents getting lost in the void
  if (cameraX < cameraMinX) {
    cameraX = cameraMinX;
  } else if (cameraX > cameraMaxX) {
    cameraX = cameraMaxX;
  } else if (cameraY < cameraMinY) {
    cameraY = cameraMinY;
  } else if (cameraY > cameraMaxY) {
    cameraY = cameraMaxY;
  }

  // Draws the map
  image(mapImage, -541, -701, width, height);
  // Uses the positional matrix to store our map image location and translate it to adjust
  // according to computed width and height.
  pushMatrix();
  translate(width/2, height/2);
  popMatrix();
  
  drawShadows();
  // Draw the complete array of cubes
  for (PShape cube : cubes) {
    shape(cube);
  }
  
  drawHUD();
  
  // Draw some text on our map for explaination.
  fill(255);
  textSize(16);
  textAlign(LEFT, TOP);
  fill(0);
  text("Interactive Scatter Plot Graph", -530, -75, 1);
  text("Datasets are for: 1991, 2001, 2011", -530, -55, 1);
  text("Blue cube means no Data", -530, -35, 1);
  text("Green to Red is low to High population", -530, -15, 1);
  
}

void drawHUD() {
pushMatrix();
  resetMatrix();
  camera(); 
  hint(DISABLE_DEPTH_TEST); // Prevents hud occulsion under PImage
  pushStyle();
  textFont(hudFont);
  textSize(14);
  fill(255);
  textAlign(LEFT, TOP);
  text("Drag the mouse to Move, or use the arrow keys.", 5, 5, 1);
  text("W, A, S and D will pitch and rotate the camera.", 5, 20, 1);
  text("C or Double Click to reset the camera.", 5, 35, 1);
  text("Press 1 For 1991 Dataset.", 5, 50, 1);
  text("Press 2 For 2001 Dataset.", 5, 65, 1);
  text("Press 3 For 2011 Dataset.", 5, 80, 1);
  fill(255, 0, 0);
  text("CONTROLS ^", 5, 95, 1);
  fill(255);
  textSize(24);
  text("Current Year: " + year, 5, 120);
  popStyle();
  hint(ENABLE_DEPTH_TEST); // putting this back on to not break anything
  popMatrix();
}
