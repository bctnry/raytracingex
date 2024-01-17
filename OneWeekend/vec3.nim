import std/math
import rtweekend

type
  Vec3* = ref object
    x*: float
    y*: float
    z*: float

proc `-`*(x: Vec3): Vec3 =
  return Vec3(x: -x.x, y: -x.y, z: -x.z)
  

proc `+=`*(x: Vec3, y: Vec3): Vec3 =
  x.x += y.x
  x.y += y.y
  x.z += y.z
  return x

proc `*=`*(x: Vec3, y: float): Vec3 =
  x.x *= y
  x.y *= y
  x.z *= y
  return x

proc `/=`*(x: Vec3, y: float): Vec3 =
  x.x /= y
  x.y /= y
  x.z /= y
  return x

func lengthSquared*(x: Vec3): float {.noSideEffect.} =
  return x.x*x.x+x.y*x.y+x.z*x.z

func length*(x: Vec3): float {.noSideEffect.} =
  return x.lengthSquared().sqrt()

func nearZero*(x: Vec3): bool {.noSideEffect.} =
  let s = 1e-8
  return (abs(x.x) < s) and (abs(x.y) < s) and (abs(x.z) < s)


proc `[]`*(x: Vec3, i: int): float =
  return case i:
           of 0: x.x
           of 1: x.y
           of 2: x.z
           else: raise newException(FieldDefect, "Cannot index bigger than 2")

type Point3* = Vec3

proc `$`*(x: Vec3): string =
  return "<" & $x.x & "," & $x.y & "," & $x.z & ">"

proc `+`*(x: Vec3, y: Vec3): Vec3 =
  return Vec3(x: x.x + y.x, y: x.y + y.y, z: x.z + y.z)

proc `-`*(x: Vec3, y: Vec3): Vec3 =
  return Vec3(x: x.x - y.x, y: x.y - y.y, z: x.z - y.z)

proc `*`*(x: Vec3, y: Vec3): Vec3 =
  return Vec3(x: x.x * y.x, y: x.y * y.y, z: x.z * y.z)

proc `*`*(x: float, y: Vec3): Vec3 =
  return Vec3(x: x*y.x, y: x*y.y, z: x*y.z)

proc `/`*(x: Vec3, y: float): Vec3 =
  return Vec3(x: x.x/y, y: x.y/y, z: x.z/y)

proc dot*(x: Vec3, y: Vec3): float =
  return x.x*y.x + x.y*y.y + x.z*y.z

proc cross*(x: Vec3, y: Vec3): Vec3 =
  return Vec3(x: x.y*y.z - x.z*y.y,
              y: x.z*y.x - x.x*y.z,
              z: x.x*y.y - x.y*y.x)

func unitVector*(x: Vec3): Vec3 {.noSideEffect.} =
  return x / x.length()
  
proc randomVec3*(): Vec3 =
  return Vec3(x: randomDouble(), y: randomDouble(), z: randomDouble())

proc randomVec3*(min: float, max: float): Vec3 =
  return Vec3(x: randomDouble(min, max), y: randomDouble(min, max), z: randomDouble(min, max))

# NOTE: if you're confused about why is there a randomInunitsphere and a
#       separate randomUnitvector: randomInunitsphere generates a vector
#       *inside* the unit sphere but not necessarily points to the *surface*
#       of the sphere; the latter guarantees a vector that points to the
#       *surface*.
proc randomInUnitSphere*(): Vec3 =
  while true:
    let p = randomVec3(-1, 1)
    if p.lengthSquared() < 1: return p

proc randomUnitVector*(): Vec3 =
  return randomInUnitSphere().unitVector()

proc randomOnHemisphere*(normal: Vec3): Vec3 =
  let onUnitSphere = randomUnitVector()
  if onUnitSphere.dot(normal) > 0.0: return onUnitSphere
  else: return -onUnitSphere

proc randomInUnitDisk*(): Vec3 =
  while true:
    let p = Vec3(x: randomDouble(-1, 1), y: randomDouble(-1, 1), z: 0)
    if p.lengthSquared() < 1: return p
  
proc reflect*(v: Vec3, n: Vec3): Vec3 =
  return v - 2*(v.dot(n))*n

proc refract*(uv: Vec3, n: Vec3, etaIOverEtaT: float): Vec3 =
  let cosTheta = min(-uv.dot(n), 1.0)
  let rOutPerp = etaIOverEtaT * (uv + cosTheta*n)
  let rOutParallel = -(abs(1.0-rOutPerp.lengthSquared())).sqrt * n
  return rOutPerp + rOutParallel
  
proc shallowCopyFrom*(x: Vec3, y: Vec3) =
  x.x = y.x
  x.y = y.y
  x.z = y.z
  
