import fenstim, math, random

randomize()

var 
  app = init(Fenster, "Efficient Edge-focusing single threaded Mandelbrot Set", 800, 600, 60)
  centerX, centerY: float64 = 0.0
  zoom: float64 = 1.0
  maxIterations = 100
  zoomSpeed: float64 = 1.02
  targetX, targetY: float64 = 0.0

proc mandelbrot(cx, cy: float64, maxIter: int): int =
  var 
    zx, zy, zx2, zy2: float64 = 0.0
    x = cx
    y = cy

  for i in 1..maxIter:
    if zx2 + zy2 > 4.0: return i
    zy = 2.0 * zx * zy + y
    zx = zx2 - zy2 + x
    zx2 = zx * zx
    zy2 = zy * zy

  return maxIter

proc findInterestingArea(currX, currY, currZoom: float64): tuple[x, y: float64] =
  const searchRadius = 2.0
  const samples = 10
  var bestX: float64 = currX
  var bestY: float64 = currY
  var bestScore = 0

  for _ in 0..<samples:
    let
      angle = rand(0.0..2*PI)
      distance = rand(0.0..searchRadius) / currZoom
      x = currX + cos(angle) * distance
      y = currY + sin(angle) * distance
      iterations = mandelbrot(x, y, maxIterations)
    
    # Consider points with iterations between 10 and maxIterations-10 as interesting
    if iterations > 10 and iterations < maxIterations-10:
      let score = maxIterations - abs(iterations - maxIterations div 2)
      if score > bestScore:
        bestScore = score
        bestX = x
        bestY = y

  if bestScore == 0:
    # If no interesting point found, slightly move in a random direction
    let angle = rand(0.0..2*PI)
    bestX = currX + cos(angle) * (0.1 / currZoom)
    bestY = currY + sin(angle) * (0.1 / currZoom)

  return (bestX, bestY)

proc draw() =
  for px in 0..<app.width:
    for py in 0..<app.height:
      let 
        x = (px.float64 - app.width.float64/2) / (0.25*zoom*app.width.float64) + centerX
        y = (py.float64 - app.height.float64/2) / (0.25*zoom*app.height.float64) + centerY
        c = mandelbrot(x, y, maxIterations)
        r = uint8((sin(c.float64 * 0.1) + 1) * 127)
        g = uint8((sin(c.float64 * 0.13 + 1) + 1) * 127)
        b = uint8((sin(c.float64 * 0.17 + 2) + 1) * 127)

      app.pixel(px, py) = (r.uint32 shl 16) or (g.uint32 shl 8) or b.uint32

var frameCount: uint32 = 0

while app.loop and app.keys[27] == 0:
  draw()

  # Continuous zoom
  zoom *= zoomSpeed
  
  # Move towards target
  centerX += (targetX - centerX) * 0.05
  centerY += (targetY - centerY) * 0.05

  frameCount += 1
  if frameCount mod 30 == 0:
    (targetX, targetY) = findInterestingArea(centerX, centerY, zoom)

  maxIterations = int(100.0 * log10(zoom + 1))