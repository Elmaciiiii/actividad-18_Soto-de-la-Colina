// Triángulo de Sierpinski con personalización avanzada
// Controles: ↑/↓ para profundidad, R para rotar, C para cambiar colores, SPACE para animar

int depth = 5;
float triangleHeight;
PVector p1, p2, p3;
float rotation = 0;
boolean autoRotate = false;
int colorMode = 0;
float hueOffset = 0;

void setup() {
  size(800, 800);
  triangleHeight = sqrt(3) / 2 * width;
  p1 = new PVector(width / 2, 100);
  p2 = new PVector(100, height - 100);
  p3 = new PVector(width - 100, height - 100);
  colorMode(HSB, 360, 100, 100);
}

void draw() {
  background(0);
  
  // Animación automática de rotación
  if (autoRotate) {
    rotation += 0.01;
  }
  
  // Animación de colores
  hueOffset += 0.5;
  if (hueOffset > 360) hueOffset = 0;
  
  // Aplicar transformaciones
  pushMatrix();
  translate(width / 2, height / 2);
  rotate(rotation);
  translate(-width / 2, -height / 2);
  
  noStroke();
  drawTriangle(depth, p1, p2, p3, 0);
  
  popMatrix();
  
  // Mostrar información
  displayInfo();
}

void drawTriangle(int d, PVector p1, PVector p2, PVector p3, int level) {
  if (d == 0) {
    // Aplicar colores según el modo seleccionado
    applyColor(level);
    triangle(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);
  } else {
    PVector mid1 = new PVector((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
    PVector mid2 = new PVector((p2.x + p3.x) / 2, (p2.y + p3.y) / 2);
    PVector mid3 = new PVector((p1.x + p3.x) / 2, (p1.y + p3.y) / 2);
    
    drawTriangle(d - 1, p1, mid1, mid3, level + 1);
    drawTriangle(d - 1, mid1, p2, mid2, level + 1);
    drawTriangle(d - 1, mid3, mid2, p3, level + 1);
  }
}

void applyColor(int level) {
  switch(colorMode) {
    case 0: // Degradado por profundidad
      float hue = (level * 40 + hueOffset) % 360;
      fill(hue, 80, 90);
      break;
    case 1: // Colores cálidos
      fill((level * 30 + hueOffset) % 60, 90, 95);
      break;
    case 2: // Colores fríos
      fill((level * 30 + hueOffset + 180) % 180 + 180, 85, 90);
      break;
    case 3: // Arcoíris completo
      fill((level * 60 + hueOffset) % 360, 100, 95);
      break;
  }
}

void displayInfo() {
  fill(255);
  textAlign(LEFT);
  textSize(16);
  text("Profundidad: " + depth + " (↑/↓)", 10, 25);
  text("Rotación: " + (autoRotate ? "ON" : "OFF") + " (SPACE)", 10, 45);
  text("Modo Color: " + colorMode + " (C)", 10, 65);
  text("Rotar Manual: R", 10, 85);
}

void keyPressed() {
  if (keyCode == UP && depth < 8) {
    depth++;
  } else if (keyCode == DOWN && depth > 0) {
    depth--;
  } else if (key == ' ') {
    autoRotate = !autoRotate;
  } else if (key == 'r' || key == 'R') {
    rotation += PI / 6;
  } else if (key == 'c' || key == 'C') {
    colorMode = (colorMode + 1) % 4;
  }
}
