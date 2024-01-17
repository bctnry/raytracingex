import std/math
import vec3
import ray
import hittable
import interval
import materialtype

type
  Sphere* = ref object of Hittable
    center*: Point3
    radius*: float
    mat*: Material

method hit*(s: Sphere, r: Ray, rayT: Interval, rec: HitRecord): bool =
  let oc = r.origin - s.center
  let a = r.direction.lengthSquared()
  let halfB = oc.dot(r.direction)
  let c = oc.lengthSquared() - s.radius*s.radius

  let discriminant = halfB*halfB - a*c
  if discriminant < 0: return false
  let sqrtd = discriminant.sqrt()

  var root = (-halfB - sqrtd) / a
  if not rayT.surrounds(root):
    root = (-halfB + sqrtd) / a
    if not rayT.surrounds(root):
      return false

  rec.t = root
  rec.p = r.at(rec.t)
  let outwardNormal = (rec.p - s.center) / s.radius
  rec.setFaceNormal(r, outwardNormal)
  rec.mat = s.mat

  return true

