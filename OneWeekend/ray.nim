import vec3

type
  Ray* = ref object
    origin*: Point3
    direction*: Vec3

proc at*(r: Ray, t: float): Point3 =
  return r.origin + t*r.direction

proc shallowCopyFrom*(r: Ray, r1: Ray): void =
  r.origin = r1.origin
  r.direction = r1.direction
  
