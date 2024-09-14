import fenstim, math

var 
  app = init(Fenster, "Interactive Julia Set", 800, 600, 60)
  cx, cy: float32 = 0
  oldpos = (801, 601)

proc julia(x, y, cx, cy: float32, maxIter: int): int =
  var 
    zx = x
    zy = y

  for i in 1..maxIter:
    let
      zx2 = zx*zx
      zy2 = zy*zy

    if zx2 + zy2 > 4: return i

    zy = 2*zx*zy + cy
    zx = zx2 - zy2 + cx

  return 0

while app.loop and app.keys[27] == 0:
  let (mouseX, mouseY) = app.mouse.pos
  if (mouseX, mouseY) != oldpos:
    oldpos = (mouseX, mouseY)
    cx = mouseX.float32 / app.width.float32 * 4 - 2
    cy = mouseY.float32 / app.height.float32 * 4 - 2

    for px in 0..<app.width:
      for py in 0..<app.height:
        let 
          x = px.float32 / app.width.float32 * 4 - 2
          y = py.float32 / app.height.float32 * 4 - 2
          c = julia(x, y, cx, cy, 100)
          r = uint8((sin(c.float32 * 0.1) + 1) * 127)
          g = uint8((sin(c.float32 * 0.13 + 1) + 1) * 127)
          b = uint8((sin(c.float32 * 0.17 + 2) + 1) * 127)

        app.pixel(px, py) = (r.uint32 shl 16) or (g.uint32 shl 8) or b.uint32