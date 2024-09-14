# Fenstim
Fenstim is a Nim wrapper for [Fenster](https://github.com/zserge/fenster), the most minimal cross-platform GUI with 2D canvas library. It provides a simple and efficient way to create graphical applications in Nim.

# Implementation status
- [x] Minimal 24-bit RGB framebuffer.
- [x] Application lifecycle and system events are all handled automatically.
- [x] Simple polling API without a need for callbacks or multithreading (like Arduino/Processing).
- [x] Cross-platform keyboard events (keycodes).
- [x] Cross-platform mouse events (X/Y + mouse click).
- [x] Cross-platform timers to have a stable FPS rate. (builtin)
- [x] Cross-platform audio playback (WinMM, CoreAudio, ALSA).

# Credits
Project done in collaboration with @ElegantBeef and @morturo at https://forum.nim-lang.org/t/12504

# Examples
Basic usage
```nim
import fenstim, colors

var app = init(Fenster, "My Window", 800, 600, 60)

if app.loop:
  echo "Window target FPS: ", app.targetFps, ", Resolution: ", app.width, "x", app.height

while app.loop:
  # Set pixel color
  app.pixel(400, 300) = 16711680  # Decimal red
  app.pixel(420, 300) = 0x0000FF  # Hex blue
  pixel(app, 410, 300) = 0x00ff00 # Hex green

  # With colors module
  app.pixel(390, 300) = rgb(255, 0, 0).uint32        # Red
  app.pixel(380, 300) = parseColor("#00FF00").uint32 # Green
  app.pixel(370, 300) = colAliceBlue.uint32          # Alice Blue
  app.pixel(360, 300) = parseColor("silver").uint32  # Silver

  # Get pixel color
  let color = app.pixel(420, 300) # Decimal

  # Check key press if A key is pressed
  if app.keys[ord('A')] == 1:
    echo "A key is pressed"

  # Check if scape key is pressed
  if keys(app)[27] == 1:
    app.close
    break

  # Get mouse position and click state
  if app.mouse.mclick[0] == 1:
    echo "Clicked at: ", app.mouse.pos.x, "x", app.mouse.pos.y

  # Adjust FPS
  app.targetFps = 30
```

Opens a 60fps 800x600 window, draws a red square and exits when pressing the Escape key:

```nim
# examples/red_square.nim
import fenstim

var app = init(Fenster, "Red square with fenstim", 800, 600, 60)

while app.loop and app.keys[27] == 0:
  for x in 350 .. 450:
    for y in 250 .. 350:
      app.pixel(x, y) = 0xFF0000
```

# API usage
### Initialization
```nim
init*(_: type Fenster, title: string, width, height: int, fps: int = 60): Fenster
```  
Creates a new Fenster window with the specified title, dimensions, and target FPS.

### Main Loop
```nim
loop*(self: var Fenster): bool
```
Handles events and updates the display. Returns false when the window should close.

### Pixel Manipulation
```nim
pixel*(self: Fenster, x, y: int): uint32
```
Get or set a uint32 pixel color at (x, y).

### Window Properties
```nim
width*(self: Fenster): int
height*(self: Fenster): int
targetFps*(self: Fenster): int
close*(self: var Fenster)
clear*(self: Fenster)
```

### Input Handling
```nim
keys*(self: Fenster): array[256, cint]
mouse*(self: Fenster): tuple[pos: tuple[x, y: int], mclick: array[5, cint], mhold: array[3, cint]]
modkey*(self: Fenster): int
```
keys = Array of key states. Index corresponds to ASCII value (0-255), but arrows are 17..20.  
mouse = Get mouse position (x, y), clicked (left, right, middle, scroll up, scroll down) and holding buttons (left, right, middle)  
modkey = 4 bits mask, ctrl=1, shift=2, alt=4, meta=8

# Examples
### Galery
![lca1](https://github.com/user-attachments/assets/4da9fa7f-e201-4f18-a262-d53fcbdb0380)  
![lca2](https://github.com/user-attachments/assets/9a8654af-e5fc-4b1e-9c3f-2eeaf2bf2016)  
![lca3](https://github.com/user-attachments/assets/c2fe1c8f-b138-491f-be7b-0baa1f553259)  
![lca5](https://github.com/user-attachments/assets/73e1280f-a988-4190-bf6e-1f94fee1d8d9)  
![lca4](https://github.com/user-attachments/assets/93b30453-de4e-4952-8729-87f149b02a13)  
[interactive_julia_set.nim](examples/interactive_julia_set.nim)  
![ezgif-2-1a773886a7](https://github.com/user-attachments/assets/95116b60-cdf0-4308-9f90-593e97bd60d0)  
[mandelbrot.nim](examples/mandelbrot.nim)  
[threaded_mandelbrot.nim](examples/threaded_mandelbrot.nim)  
