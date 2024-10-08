import os

when defined(windows):
  import winim/inc/mmsystem

const fensterAudioHeader = currentSourcePath().parentDir() / "fenster/fenster_audio.h"

when defined(linux):
  {.passL: "-lasound".}
elif defined(windows):
  {.passL: "-lwinmm".}
elif defined(macosx):
  {.passL: "-framework AudioToolbox".}

{.passC: "-Ivendor".}

const FENSTER_AUDIO_BUFSZ = 8192

type
  FensterAudioStruct = object
    when defined(macosx):
      queue: pointer
      pos: csize_t
      buf: array[FENSTER_AUDIO_BUFSZ, float32]
      drained: pointer
      full: pointer
    elif defined(windows):
      header: WAVEHDR
      wo: HWAVEOUT
      hdr: array[2, WAVEHDR]
      buf: array[2, array[FENSTER_AUDIO_BUFSZ, int16]]
    elif defined(linux):
      pcm: pointer
      buf: array[FENSTER_AUDIO_BUFSZ, float32]
      pos: csize_t

  FensterAudio* = object
    raw: ptr FensterAudioStruct

{.push importc, header: fensterAudioHeader.}
proc fenster_audio_open(fa: ptr FensterAudioStruct): cint
proc fenster_audio_available(fa: ptr FensterAudioStruct): cint
proc fenster_audio_write(fa: ptr FensterAudioStruct, buf: ptr float32, n: csize_t)
proc fenster_audio_close(fa: ptr FensterAudioStruct)
{.pop.}

proc `=destroy`(self: FensterAudio) =
  if self.raw != nil:
    fenster_audio_close(self.raw)
    dealloc(self.raw)

proc init*(_: type FensterAudio): FensterAudio =
  result = FensterAudio()
  result.raw = cast[ptr FensterAudioStruct](alloc0(sizeof(FensterAudioStruct)))
  if fenster_audio_open(result.raw) != 0:
    raise newException(IOError, "Failed to open audio")

proc available*(self: FensterAudio): int =
  fenster_audio_available(self.raw).int

proc write*(self: FensterAudio, buf: openArray[float32]) =
  fenster_audio_write(self.raw, unsafeAddr buf[0], buf.len.csize_t)