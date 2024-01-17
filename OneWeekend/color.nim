import std/strformat
import std/math
import vec3
import interval

type Color* = Vec3

proc makeColor*(r: float, g: float, b: float): Color = return Vec3(x: r, y: g, z: b)

proc colorToString*(x: Color): string =
  return $(255.999 * x.x).int & " " & $(255.999 * x.y).int & " " & $(255.999 * x.z).int & "\n"

func linearToGamma(linearComponent: float): float {.noSideEffect.} = linearComponent.sqrt()

proc colorToString*(x: Color, samplesPerPixel: int): string =
  let scale = 1.0 / samplesPerPixel.float
  let r = (x.x*scale).linearToGamma()
  let g = (x.y*scale).linearToGamma()
  let b = (x.z*scale).linearToGamma()

  let intensity = Interval(min: 0.000, max: 0.999)
  let xr = (256.float * intensity.clamp(r)).int
  let xg = (256.float * intensity.clamp(g)).int
  let xb = (256.float * intensity.clamp(b)).int

  var res = ""
  res.add(xr.chr)
  res.add(xg.chr)
  res.add(xb.chr)
  # return &"{xr} {xg} {xb}\n"
  return res

