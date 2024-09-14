import fenstim

const 
  WIDTH = 800
  HEIGHT = 600
  FPS = 60

var 
  app = init(Fenster, "Walkable Carpet Pattern", WIDTH, HEIGHT, FPS)
  offsetX, offsetY = 0
  lastMouseCords = (app.mouse.pos.x, app.mouse.pos.y)

proc movingCarpetPattern(x, y: int, mouseX, mouseY: float32): uint32 =
  let
    smoothOffsetX = (mouseX / WIDTH.float32 * 20).int
    smoothOffsetY = (mouseY / HEIGHT.float32 * 20).int
    
    adjustedX = (x + smoothOffsetX + offsetX) div 20
    adjustedY = (y + smoothOffsetY + offsetY) div 20
    
    isEvenSquare = (adjustedX + adjustedY) mod 2 == 0
    color = if isEvenSquare: 0xD2691E else: 0x8B4513

  return color.uint32

proc updateOffset() =
  const MOVE_SPEED = 5
  if app.keys[ord('W')] == 1: offsetY -= MOVE_SPEED
  if app.keys[ord('S')] == 1: offsetY += MOVE_SPEED
  if app.keys[ord('A')] == 1: offsetX -= MOVE_SPEED
  if app.keys[ord('D')] == 1: offsetX += MOVE_SPEED

while app.loop and app.keys[27] == 0:
  let mouseMoved = lastMouseCords != (app.mouse.pos.x, app.mouse.pos.y)
  let movementKeysPressed = app.keys[ord('W')] == 1 or app.keys[ord('A')] == 1 or app.keys[ord('S')] == 1 or app.keys[ord('D')] == 1

  if mouseMoved or movementKeysPressed:
    lastMouseCords = (app.mouse.pos.x, app.mouse.pos.y)

    updateOffset()
  
    for x in 0 ..< WIDTH:
      for y in 0 ..< HEIGHT:
        app.pixel(x, y) = movingCarpetPattern(x, y, app.mouse.pos.x.float32, app.mouse.pos.y.float32)
