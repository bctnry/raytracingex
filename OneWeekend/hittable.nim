import vec3
import ray
import interval
from materialtype import Material

type
  HitRecord* = ref object
    p*: Point3
    normal*: Vec3
    t*: float
    frontFace*: bool
    mat*: Material

  Hittable* = ref object of RootObj

method hit*(h: Hittable, r: Ray, rayT: Interval, rec: HitRecord): bool {.base.} =
  return false

proc setFaceNormal*(rec: HitRecord, r: Ray, outwardNormal: Vec3): void =
  rec.frontFace = r.direction.dot(outwardNormal) < 0
  rec.normal = if rec.frontFace: outwardNormal else: -outwardNormal
    
