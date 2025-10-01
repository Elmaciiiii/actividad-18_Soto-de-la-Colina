// Conjunto de Mandelbrot optimizado con zoom, arrastre y modo explorador
// Controles: Click+Arrastrar, Rueda para zoom, C colores, E explorador, R resetear

float centerX = -0.5;
float centerY = 0;
float zoom = 1;
int maxIterations = 100;
int colorPalette = 0;
boolean explorerMode = false;

// Variables para arrastrar
boolean dragging = false;
float dragStartX, dragStartY;
float dragCenterX, dragCenterY;

// Variables para modo explorador
float explorerZoom = 1;
float targetExplorerZoom = 1;
int explorerIterations = 100;
float explorerCenterX = -0.5;
float explorerCenterY = 0;
int explorerFrameCount = 0;
int currentZone = 0;

// Zonas famosas para explorar (nombre, x, y, zoom objetivo)
float[][] explorerZones = {
  {-0.5, 0, 3},                    // Vista completa
  {-0.7, 0.1, 15},                 // Bulbo principal
  {0.285, 0.01, 80},               // Mini-Mandelbrot
  {-0.16, 1.04, 50},               // Elephant Valley
  {-0.7269, 0.1889, 120},          // Espirales dobles
  {-0.7453, 0.1127, 200},          // Seahorse Valley
  {-0.5, -0.6, 25},                // Zona inferior
  {-0.235125, 0.827215, 150}       // Triple espiral
};

void setup() {
  size(800, 800);
  colorMode(RGB, 255);
  noLoop(); // Optimización: solo redibuja cuando es necesario
  println("Controles:");
  println("- Click+Arrastrar: Mover");
  println("- Rueda Mouse: Zoom");
  println("- C: Cambiar paleta");
  println("- E: Modo Explorador");
  println("- R: Resetear");
}

void draw() {
  background(0);
  
  if (explorerMode) {
    explorerFrameCount++;
    
    // Transición suave entre zonas
    explorerCenterX = lerp(explorerCenterX, explorerZones[currentZone][0], 0.015);
    explorerCenterY = lerp(explorerCenterY, explorerZones[currentZone][1], 0.015);
    
    // Zoom suave con lerp hacia el objetivo
    explorerZoom = lerp(explorerZoom, targetExplorerZoom, 0.01);
    
    // CAMBIAR DE ZONA cuando el zoom está cerca del objetivo
    if (abs(explorerZoom - targetExplorerZoom) < targetExplorerZoom * 0.15) {
      // Ya llegó al 85% del zoom objetivo, cambiar de zona
      currentZone = (currentZone + 1) % explorerZones.length;
      targetExplorerZoom = explorerZones[currentZone][2];
      explorerZoom = 1; // Resetear zoom para la nueva zona
      explorerCenterX = explorerZones[currentZone][0];
      explorerCenterY = explorerZones[currentZone][1];
      println("→ Zona " + (currentZone + 1) + "/" + explorerZones.length + " | Zoom objetivo: " + targetExplorerZoom + "x");
    }
    
    // Iteraciones variables (detalle que respira)
    explorerIterations = 100 + (int)(80 * abs(sin(explorerFrameCount * 0.015)));
    if (explorerIterations < 80) explorerIterations = 80;
    
    // Cambio automático de paleta cada 10 segundos
    if (explorerFrameCount % 600 == 0) {
      colorPalette = (colorPalette + 1) % 6;
    }
    
    drawMandelbrot(explorerCenterX, explorerCenterY, explorerZoom, explorerIterations, true);
  } else {
    noLoop(); // Desactivar animación cuando no está explorando
    drawMandelbrot(centerX, centerY, zoom, maxIterations, false);
  }
  
  displayInfo();
}

void drawMandelbrot(float cx, float cy, float z, int maxIter, boolean animateColors) {
  loadPixels();
  
  float w = 4.0 / z;
  float h = (w * height) / width;
  float xmin = cx - w / 2.0;
  float ymin = cy - h / 2.0;
  
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      float a = map(x, 0, width, xmin, xmin + w);
      float b = map(y, 0, height, ymin, ymin + h);
      
      float ca = a;
      float cb = b;
      
      int n = 0;
      
      while (n < maxIter) {
        float aa = a * a - b * b;
        float bb = 2.0 * a * b;
        
        a = aa + ca;
        b = bb + cb;
        
        if (abs(a + b) > 16) break;
        
        n++;
      }
      
      int pix = x + y * width;
      
      if (n == maxIter) {
        pixels[pix] = color(0);
      } else {
        pixels[pix] = getColor(n, maxIter, animateColors);
      }
    }
  }
  
  updatePixels();
}

color getColor(int n, int maxIter, boolean animated) {
  float t = (float)n / maxIter;
  
  // Colores dinámicos en modo explorador
  float colorShift = animated ? sin(explorerFrameCount * 0.015) * 128 + 128 : 0;
  
  switch(colorPalette) {
    case 0: // Blanco y Negro
      int bright = (int)map(n, 0, maxIter, 0, 255);
      if (animated) {
        bright = (int)((bright + colorShift) % 256);
      }
      return color(bright);
      
    case 1: // Azul océano
      int r1 = (int)map(n, 0, maxIter, 0, 50);
      int g1 = (int)map(n, 0, maxIter, 0, 150);
      int b1 = (int)map(n, 0, maxIter, 100, 255);
      if (animated) {
        r1 = (int)((r1 + colorShift * 0.3) % 256);
        g1 = (int)((g1 + colorShift * 0.6) % 256);
        b1 = (int)((b1 + colorShift * 0.4) % 256);
      }
      return color(r1, g1, b1);
      
    case 2: // Fuego
      int r2 = 255;
      int g2 = (int)map(n, 0, maxIter, 255, 0);
      int b2 = 0;
      if (animated) {
        g2 = (int)((g2 + colorShift) % 256);
        b2 = (int)(sin(explorerFrameCount * 0.02 + n * 0.1) * 128 + 128);
      }
      return color(r2, g2, b2);
      
    case 3: // Matrix
      int r3 = 0;
      int g3 = (int)map(n, 0, maxIter, 50, 255);
      int b3 = 0;
      if (animated) {
        g3 = (int)((g3 + colorShift) % 256);
        r3 = (int)(sin(explorerFrameCount * 0.03) * 80);
      }
      return color(r3, g3, b3);
      
    case 4: // Púrpura místico
      int r4 = (int)map(n, 0, maxIter, 100, 255);
      int g4 = (int)map(n, 0, maxIter, 0, 100);
      int b4 = (int)map(n, 0, maxIter, 150, 255);
      if (animated) {
        r4 = (int)((r4 + colorShift * 0.8) % 256);
        b4 = (int)((b4 + colorShift * 0.5) % 256);
      }
      return color(r4, g4, b4);
      
    case 5: // Cian arcoíris
      float phase = t * 6.28318;
      if (animated) {
        phase += explorerFrameCount * 0.02;
      }
      int r5 = (int)(128 + 127 * sin(phase));
      int g5 = (int)(128 + 127 * sin(phase + 2.09));
      int b5 = (int)(128 + 127 * sin(phase + 4.18));
      return color(r5, g5, b5);
      
    default:
      return color(255);
  }
}

void displayInfo() {
  fill(255);
  stroke(0);
  strokeWeight(2);
  rect(0, 0, 340, 160);
  
  fill(0);
  noStroke();
  textAlign(LEFT);
  textSize(14);
  text("Click+Arrastrar: Mover vista", 10, 20);
  text("Rueda Mouse: Zoom hacia cursor", 10, 40);
  text("C: Cambiar paleta de colores", 10, 60);
  text("E: Modo Explorador " + (explorerMode ? "ON ✨" : "OFF"), 10, 80);
  text("R: Resetear vista", 10, 100);
  
  String[] paletteNames = {"B/N", "Azul", "Fuego", "Matrix", "Púrpura", "Cian"};
  text("Paleta: " + paletteNames[colorPalette], 10, 120);
  
  if (explorerMode) {
    text("Zoom: " + nf(explorerZoom, 0, 2) + "x | Iters: " + explorerIterations, 10, 140);
    text("Zona: " + (currentZone + 1) + "/" + explorerZones.length, 200, 140);
  } else {
    text("Zoom: " + nf(zoom, 0, 2) + "x | Iters: " + maxIterations, 10, 140);
  }
}

void mousePressed() {
  if (!explorerMode) {
    dragging = true;
    dragStartX = mouseX;
    dragStartY = mouseY;
    dragCenterX = centerX;
    dragCenterY = centerY;
  }
}

void mouseReleased() {
  dragging = false;
}

void mouseDragged() {
  if (dragging && !explorerMode) {
    float dx = mouseX - dragStartX;
    float dy = mouseY - dragStartY;
    
    float w = 4.0 / zoom;
    float h = (w * height) / width;
    
    float moveX = -dx * w / width;
    float moveY = -dy * h / height;
    
    centerX = dragCenterX + moveX;
    centerY = dragCenterY + moveY;
    
    redraw(); // Solo redibujar cuando hay cambio
  }
}

void mouseWheel(MouseEvent event) {
  if (!explorerMode) {
    float e = event.getCount();
    float zoomFactor = 1.2;
    
    float w = 4.0 / zoom;
    float h = (w * height) / width;
    float xmin = centerX - w / 2.0;
    float ymin = centerY - h / 2.0;
    
    float mouseComplexX = map(mouseX, 0, width, xmin, xmin + w);
    float mouseComplexY = map(mouseY, 0, height, ymin, ymin + h);
    
    if (e < 0) {
      float newZoom = zoom * zoomFactor;
      centerX = centerX + (mouseComplexX - centerX) * (1 - zoom / newZoom);
      centerY = centerY + (mouseComplexY - centerY) * (1 - zoom / newZoom);
      zoom = newZoom;
      maxIterations = min(maxIterations + 10, 500);
    } else {
      zoom = zoom / zoomFactor;
      if (zoom < 1) zoom = 1;
      if (zoom < 10) maxIterations = 100;
      else if (zoom < 50) maxIterations = 200;
    }
    
    redraw(); // Solo redibujar cuando hay cambio
  }
}

void keyPressed() {
  if (key == 'c' || key == 'C') {
    colorPalette = (colorPalette + 1) % 6;
    redraw();
  } else if (key == 'r' || key == 'R') {
    centerX = -0.5;
    centerY = 0;
    zoom = 1;
    maxIterations = 100;
    explorerMode = false;
    explorerZoom = 1;
    explorerIterations = 100;
    explorerFrameCount = 0;
    currentZone = 0;
    redraw();
  } else if (key == 'e' || key == 'E') {
    explorerMode = !explorerMode;
    if (explorerMode) {
      // ACTIVAR modo explorador
      println("=== MODO EXPLORADOR ACTIVADO ===");
      explorerZoom = 1;
      targetExplorerZoom = explorerZones[0][2];
      explorerIterations = 100;
      explorerCenterX = explorerZones[0][0];
      explorerCenterY = explorerZones[0][1];
      explorerFrameCount = 0;
      currentZone = 0;
      loop(); // Activar animación continua
    } else {
      // DESACTIVAR modo explorador
      println("=== MODO EXPLORADOR DESACTIVADO ===");
      noLoop(); // CRÍTICO: Detener animación
      centerX = -0.5;
      centerY = 0;
      zoom = 1;
      maxIterations = 100;
      redraw(); // Redibujar una última vez
    }
  }
}
