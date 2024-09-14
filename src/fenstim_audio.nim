import os

const fensterAudioHeader = currentSourcePath().parentDir() / "fensterb/src/fenster_audio/fenster_audio.h"

when defined(linux): {.passL: "-lasound".}
elif defined(windows): {.passL: "-lwinmm".}
elif defined(macosx): {.passL: "-framework AudioToolbox".}

{.passC: "-Ivendor".}

const FENSTER_AUDIO_BUFSZ = 8192

type
  FensterAudioStruct  = object
    audio_data: pointer
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

proc close*(self: var FensterAudio) =
  fenster_audio_close(self.raw)
  dealloc(self.raw)
  self.raw = nil

proc `=destroy`(self: FensterAudio) =
  if self.raw != nil:
    fenster_audio_close(self.raw)
    dealloc(self.raw)

proc init*(_: type FensterAudio): FensterAudio =
  result = FensterAudio()
  result.raw = cast[ptr FensterAudioStruct](alloc0(sizeof(FensterAudioStruct)))
  discard fenster_audio_open(result.raw)

proc available*(self: FensterAudio): int = fenster_audio_available(self.raw).int

proc write*(self: FensterAudio, buf: openArray[float32]) = fenster_audio_write(self.raw, unsafeAddr buf[0], buf.len.csize_t)
