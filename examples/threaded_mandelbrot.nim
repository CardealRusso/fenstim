import fenstim, math, random, parsecfg, atomics, parseutils, strutils, os

randomize()

const CONFIG_FILE = "config.ini"
const DEFAULT_CONFIG = """
width=800
height=600
targetFps=60
threadcount=2
"""

proc createDefaultConfig() =
  writeFile(CONFIG_FILE, DEFAULT_CONFIG)

if not fileExists(CONFIG_FILE):
  createDefaultConfig()

let dict = loadConfig(CONFIG_FILE)

proc getConfigValue(key: string, default: int): int =
  let value = dict.getSectionValue("", key)
  if value == "": default else: parseInt(value)

var 
  WIDTH = getConfigValue("width", 800)
  HEIGHT = getConfigValue("height", 600)
  THREAD_COUNT = getConfigValue("threadcount", 2)
  TARGETFPS = getConfigValue("targetFps", 60)

type
  ThreadArg = tuple[startY, endY: int]

echo "Threads: ", THREAD_COUNT, " ", WIDTH, "x", HEIGHT
var 
  app = init(Fenster, "Multi-threaded Edge-focusing Mandelbrot Set", WIDTH, HEIGHT, TARGETFPS)
  centerX, centerY: float64 = 0.0
  zoom: float64 = 1.0
  maxIterations: Atomic[int]
  zoomSpeed: float64 = 1.02
  targetX, targetY: float64 = 0.0

var buffer: seq[uint32]
buffer.setLen(WIDTH * HEIGHT)

maxIterations.store(100)

proc mandelbrot(cx, cy: float64, maxIter: int): int {.inline.} =
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
      iterations = mandelbrot(x, y, maxIterations.load)
    
    if iterations > 10 and iterations < maxIterations.load-10:
      let score = maxIterations.load - abs(iterations - maxIterations.load div 2)
      if score > bestScore:
        bestScore = score
        bestX = x
        bestY = y

  if bestScore == 0:
    let angle = rand(0.0..2*PI)
    bestX = currX + cos(angle) * (0.1 / currZoom)
    bestY = currY + sin(angle) * (0.1 / currZoom)

  return (bestX, bestY)

proc drawSection(arg: ThreadArg) {.thread.} =
  let (startY, endY) = arg
  let maxIter = maxIterations.load

  {.cast(gcsafe).}:
    for py in startY..<endY:
      for px in 0..<WIDTH:
        let 
          x = (px.float64 - WIDTH.float64/2) / (0.25*zoom*WIDTH.float64) + centerX
          y = (py.float64 - HEIGHT.float64/2) / (0.25*zoom*HEIGHT.float64) + centerY
          c = mandelbrot(x, y, maxIter)
          r = uint8((sin(c.float64 * 0.1) + 1) * 127)
          g = uint8((sin(c.float64 * 0.13 + 1) + 1) * 127)
          b = uint8((sin(c.float64 * 0.17 + 2) + 1) * 127)

        buffer[py * WIDTH + px] = (r.uint32 shl 16) or (g.uint32 shl 8) or b.uint32

proc draw() =
  var threads: seq[Thread[ThreadArg]]
  
  threads.setLen(THREAD_COUNT)
  let sectionHeight = HEIGHT div THREAD_COUNT

  for i in 0..<THREAD_COUNT:
    let startY = i * sectionHeight
    let endY = if i == THREAD_COUNT - 1: HEIGHT else: (i + 1) * sectionHeight
    createThread(threads[i], drawSection, (startY: startY, endY: endY))

  joinThreads(threads)

  for y in 0..<HEIGHT:
    for x in 0..<WIDTH:
      app.pixel(x, y) = buffer[y * WIDTH + x]

var frameCount: uint32 = 0

while app.loop and app.keys[27] == 0:
  draw()

  zoom *= zoomSpeed
  centerX += (targetX - centerX) * 0.05
  centerY += (targetY - centerY) * 0.05

  frameCount += 1
  if frameCount mod 30 == 0:
    (targetX, targetY) = findInterestingArea(centerX, centerY, zoom)
    echo "Frame: ", frameCount, " FPS: ", app.fps.int

  maxIterations.store(int(100.0 * log10(zoom + 1)))
