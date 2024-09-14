import fenstim, fenstim_audio, math

var 
  app = init(Fenster, "Bytebeats. Switch with Left Click.", 800, 600, 60)
  app_audio = init(FensterAudio)
  t, u, currentBeat = 0

let byteBeats = [
  proc(x: int): float32 = float32(((((x shr 10) and 42) * x) and 0xff)) / 256.0,
  proc(x: int): float32 = float32((x * ((x shr 12 or x shr 8) and 63 and x shr 4)) and 0xff) / 256.0,
  proc(x: int): float32 = float32(((not (x shr 2)) * ((127 and x * (7 and x shr 10)) < (245 and x * (2 + (5 and x shr 14)))).int) and 0xff) / 256.0,
  proc(x: int): float32 = float32((((x shr 10 xor x shr 11) mod 5 * ((x shr 14 and 3 xor x shr 15 and 1) + 1) * x mod 99 + ((3 + (x shr 14 and 3) - (x shr 16 and 1)) div 3 * x mod 99 and 64))) and 0xff) / 256.0
]

let arts = [
  proc(x, y, t: int): uint32 = (x * y * t).uint32,
  proc(x, y, t: int): uint32 = ((x xor y xor t) * 65793).uint32,
  proc(x, y, t: int): uint32 = (((x * x + y * y + t) and 255) * 0x010101).uint32,
  proc(x, y, t: int): uint32 = 
  (
    let freqX = 0.04 + app.mouse.pos.x / app.width * 0.1
    let freqY = 0.03 + app.mouse.pos.y / app.height * 0.1

    let plasma = sin(x.float * freqX + 0.1 * t.float) + 
             sin(y.float * freqY) + 
             sin((x.float + y.float) * 0.02 + 0.1 * t.float)
    
    let color = uint32((plasma + 3) * 85)
  
    result = color shl 16 or (color shl 1) shl 8 or color shl 2
  ),
]

proc generateAudio(n: int): seq[float32] =
  result = newSeq[float32](n)
  for i in 0..<n:
    u.inc
    result[i] = byteBeats[currentBeat]((u * 80 div 441).int)

while app.loop and app.keys[27] == 0:
  t.inc
  if app.mouse.mclick[0] == 1 or app.mouse.mclick[1] == 1:
    currentBeat = (currentBeat + (if app.mouse.mclick[0] == 1: 1 else: -1) + byteBeats.len) mod byteBeats.len
    echo "Switched to ByteBeat ", currentBeat + 1
  
  if app_audio.available > 0:
    app_audio.write(generateAudio(app_audio.available))
  
  for i in 0..<app.width:
    for j in 0..<app.height:
      app.pixel(i, j) = arts[currentBeat](i, j, t)
