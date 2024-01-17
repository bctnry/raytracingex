# NOTE: since hittable_list is essentially just a list of hittables we'll
import ray
import hittable
import interval

type HittableList* = seq[Hittable]

proc hit*(self: HittableList, r: Ray, rayT: Interval, rec: HitRecord): bool =
  var tempRec = HitRecord(p: nil, normal: nil, t: 0.0, frontFace: false)
  var hitAnything = false
  var closestSoFar = rayT.max
  for h in self:
    if h.hit(r, Interval(min: rayT.min, max: closestSoFar), tempRec):
      hitAnything = true
      closestSoFar = tempRec.t
      rec.t = tempRec.t
      rec.p = tempRec.p
      rec.normal = tempRec.normal
      rec.frontFace = tempRec.frontFace
      rec.mat = tempRec.mat

  return hitAnything
  
