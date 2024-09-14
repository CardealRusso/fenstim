import fenstim, fenstim_audio

var 
  app = init(Fenster, "Audio Example", 320, 240, 60)
  app_audio = init(FensterAudio)
  t, u = 0

proc generateAudio(n: int): seq[float32] =
  result = newSeq[float32](n)
  for i in 0..<n:
    u.inc
    let x = (u * 80 div 441).int
    result[i] = float32(((((x shr 10) and 42) * x) and 0xff)) / 256.0

while app.loop and app.keys[27] == 0:
  t.inc

  let n = app_audio.available
  if n > 0:
    let audio = generateAudio(n)
    app_audio.write(audio)

  for i in 0..<app.width:
    for j in 0..<app.height:
      app.pixel(i, j) = (i * j * t).uint32