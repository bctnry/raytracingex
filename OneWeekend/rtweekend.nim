import std/math
import std/random

# NOTE: this is technically not IEEE float infinity, but it's the biggest number
#       of Nim's float. this might *just* be enough for our use...
const infinity*: float = 1/MinFloatNormal
const pi*: float = PI

func degreesToRadians*(degrees: float): float = degrees * pi / 180.0

var randomInitialized: bool = false
# NOTE: this is not "system random", but let's hope this is good enough...
proc randomDouble*(): float =
  if not randomInitialized:
    randomize()
    randomInitialized = true
  return rand(1.0)

proc randomDouble*(minval: float, maxval: float): float =
  return minval + randomDouble()*(maxval-minval)
  
