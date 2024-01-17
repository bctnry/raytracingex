import std/math
import ray
from hittable import HitRecord
import color
import materialtype
import vec3
import rtweekend

method scatter*(m: Material, rIn: Ray, rec: HitRecord, attenuation: var Color, scattered: var Ray): bool {.base.} =
  return false
  
type
  Lambertian* = ref object of Material
    albedo: Color

proc makeLambertian*(a: Color): Lambertian = return Lambertian(albedo: a)

method scatter*(m: Lambertian, rIn: Ray, rec: HitRecord, attenuation: var Color, scattered: var Ray): bool =
  var scatterDirection = rec.normal + randomUnitVector()
  if scatterDirection.nearZero():
    scatterDirection = rec.normal
  scattered.shallowCopyFrom(Ray(origin: rec.p, direction: scatterDirection))
  attenuation.shallowCopyFrom(m.albedo)
  return true
  
type
  Metal* = ref object of Material
    albedo: Color
    fuzz: float

proc makeMetal*(a: Color, f: float): Metal = return Metal(albedo: a, fuzz: f)

method scatter*(m: Metal, rIn: Ray, rec: HitRecord, attenuation: var Color, scattered: var Ray): bool =
  let reflected = rIn.direction.unitVector.reflect(rec.normal)
  scattered.shallowCopyFrom(Ray(origin: rec.p, direction: reflected + m.fuzz*randomUnitVector()))
  attenuation.shallowCopyFrom(m.albedo)
  return scattered.direction.dot(rec.normal) > 0
  
type
  Dielectric* = ref object of Material
    ir: float

proc makeDielectric*(ir: float): Dielectric = return Dielectric(ir: ir)


# Schlick's approximation for reflectance.
proc reflectance(cosine: float, refIdx: float): float {.noSideEffect.} =
  var r0 = (1-refIdx) / (1+refIdx)
  r0 = r0 * r0
  return r0 + (1-r0)*((1-cosine)^5)

method scatter*(m: Dielectric, rIn: Ray, rec: HitRecord, attenuation: var Color, scattered: var Ray): bool =
  attenuation.shallowCopyFrom(Vec3(x: 1.0, y: 1.0, z: 1.0))
  let refractionRatio = if rec.frontFace: (1.0/m.ir) else: m.ir
  let unitDirection = rIn.direction.unitVector()
  let cosTheta = min(-unitDirection.dot(rec.normal), 1.0)
  let sinTheta = (1.0 - cosTheta*cosTheta).sqrt()
  let cannotRefract = refractionRatio * sinTheta > 1.0
  let direction = if cannotRefract or cosTheta.reflectance(refractionRatio) > randomDouble():
                    unitDirection.reflect(rec.normal)
                  else:
                    unitDirection.refract(rec.normal, refractionRatio)
  scattered.origin = rec.p
  scattered.direction = direction
  return true

  
