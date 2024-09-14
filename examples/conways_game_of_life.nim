import fenstim, random

const 
  WIDTH = 400
  HEIGHT = 300
  CELL_SIZE = 2

var 
  app = init(Fenster, "Conway's Game of Life", WIDTH * CELL_SIZE, HEIGHT * CELL_SIZE, 30)
  grid: array[WIDTH, array[HEIGHT, bool]]
  newGrid: array[WIDTH, array[HEIGHT, bool]]

randomize()

for x in 0..<WIDTH:
  for y in 0..<HEIGHT:
    grid[x][y] = rand(1.0) < 0.2

proc countNeighbors(x, y: int): int =
  for dx in -1..1:
    for dy in -1..1:
      if dx == 0 and dy == 0: continue
      let
        nx = (x + dx + WIDTH) mod WIDTH
        ny = (y + dy + HEIGHT) mod HEIGHT
      if grid[nx][ny]: result += 1

while app.loop and app.keys[27] == 0:
  for x in 0..<WIDTH:
    for y in 0..<HEIGHT:
      let neighbors = countNeighbors(x, y)
      if grid[x][y]:
        newGrid[x][y] = neighbors == 2 or neighbors == 3
      else:
        newGrid[x][y] = neighbors == 3
  
  for x in 0..<WIDTH:
    for y in 0..<HEIGHT:
      grid[x][y] = newGrid[x][y]
      let color = if grid[x][y]: 0xFFFFFF else: 0x000000
      for dx in 0..<CELL_SIZE:
        for dy in 0..<CELL_SIZE:
          app.pixel(x * CELL_SIZE + dx, y * CELL_SIZE + dy) = color.uint32

  if app.keys[ord('R')] == 1:
    for x in 0..<WIDTH:
      for y in 0..<HEIGHT:
        grid[x][y] = rand(1.0) < 0.2