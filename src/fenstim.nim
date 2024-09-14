import os

const fensterHeader = currentSourcePath().parentDir() / "fensterb/src/fenster/fenster.h"

when defined(linux): {.passl: "-lX11".}
elif defined(windows): {.passl: "-lgdi32".}
elif defined(macosx): {.passl: "-framework Cocoa".}

{.passC: "-Ivendor".}

type
  FensterStruct = object
    title*: cstring
    width*: cint
    height*: cint
    buf*: ptr UncheckedArray[uint32]
    keys*: array[256, cint]
    modkey*: cint
    x*: cint
    y*: cint
    mclick: array[5, cint]
    mhold: array[3, cint]
  
  Fenster* = object
    raw: ptr FensterStruct
    targetFps*: int
    lastFrameTime: int64
    fps*: float

{.push importc, header: fensterHeader.}
proc fenster_open(fenster: ptr FensterStruct): cint
proc fenster_loop(fenster: ptr FensterStruct): cint
proc fenster_close(fenster: ptr FensterStruct)
proc fenster_sleep(ms: cint)
proc fenster_time(): int64
{.pop.}

proc close*(self: var Fenster) =
  fenster_close(self.raw)
  dealloc(self.raw.buf)
  dealloc(self.raw)
  self.raw = nil

proc `=destroy`(self: Fenster) =
  if self.raw != nil:
    fenster_close(self.raw)
    dealloc(self.raw.buf)
    dealloc(self.raw)

proc init*(_: type Fenster, title: string, width, height: int, fps: int = 60): Fenster =
  result = Fenster()
  
  result.raw = cast[ptr FensterStruct](alloc0(sizeof(FensterStruct)))
  result.raw.title = cstring(title)
  result.raw.width = cint(width)
  result.raw.height = cint(height)
  result.raw.buf =
    cast[ptr UncheckedArray[uint32]](alloc(width * height * sizeof(uint32)))
  
  result.targetFps = fps
  result.lastFrameTime = fenster_time()
  
  discard fenster_open(result.raw)

proc loop*(self: var Fenster): bool =
  let frameTime = 1000 div self.targetFps
  let currentTime = fenster_time()
  let elapsedTime = currentTime - self.lastFrameTime
  
  if elapsedTime < frameTime:
    fenster_sleep((frameTime - elapsedTime).cint)

  if elapsedTime > 0:
    self.fps = 1000.0 / elapsedTime.float
  
  self.lastFrameTime = fenster_time()
  result = fenster_loop(self.raw) == 0

template pixel*(self: Fenster, x, y: int): uint32 = self.raw.buf[y * self.raw.width + x]
template width*(self: Fenster): int = self.raw.width.int
template height*(self: Fenster): int = self.raw.height.int
template keys*(self: Fenster): array[256, cint] = self.raw.keys
template modkey*(self: Fenster): int = self.raw.modkey.int
template mouse*(self: Fenster): tuple[pos: tuple[x, y: int], mclick: array[5, cint], mhold: array[3, cint]] =
  (
    pos: (x: self.raw.x.int, y: self.raw.y.int),
    mclick: self.raw.mclick,
    mhold: self.raw.mhold
  )
proc sleep*(self: Fenster, ms: int) = fenster_sleep(ms.cint)
proc time*(self: Fenster): int64 = fenster_time()

#Below are functions that are not part of Fenster
template clear*(self: Fenster) = zeroMem(self.raw.buf, self.raw.width.int * self.raw.height.int * sizeof(uint32))
proc getFonts*(self: Fenster): seq[string] =
  let searchPatterns = when defined(linux):
    @[
      expandTilde("~/.local/share/fonts/**/*.ttf"),
      expandTilde("~/.fonts/**/*.ttf"),
      "/usr/*/fonts/**/*.ttf",
      "/usr/*/*/fonts/**/*.ttf",
      "/usr/*/*/*/fonts/**/*.ttf",
      "/usr/*/*/*/*/fonts/**/*.ttf"
    ]
  elif defined(macosx):
    @[
      expandTilde("~/Library/Fonts/**/*.ttf"),
      "/Library/Fonts/**/*.ttf",
      "/System/Library/Fonts/**/*.ttf",
      "/Network/Library/Fonts/**/*.ttf"
    ]
  elif defined(windows):
    @[
      getEnv("SYSTEMROOT") & r"\Fonts\*.ttf",
      getEnv("LOCALAPPDATA") & r"\Microsoft\Windows\Fonts\*.ttf"
    ]
  else:
    @[]

  result = newSeq[string]()
  for pattern in searchPatterns:
    for entry in walkPattern(pattern):
      result.add(entry)
