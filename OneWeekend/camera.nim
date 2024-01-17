import std/strformat
import std/math
import vec3
import ray
import hittable
import interval
import color
import rtweekend
import hittable_collection
import materialtype
import material

type
  Camera* = ref object
    aspectRatio*: float
    imageWidth*: int
    samplesPerPixel*: int
    maxDepth*: int
    vfov*: float  # in degrees
    lookfrom*: Point3
    lookat*: Point3
    vup*: Vec3
    defocusAngle*: float
    focusDist*: float
    imageHeight: int
    center: Point3
    pixel00Loc: Point3
    pixelDeltaU: Vec3
    pixelDeltaV: Vec3
    u: Vec3
    v: Vec3
    w: Vec3
    defocusDiskU: Vec3
    defocusDiskV: Vec3

proc makeCamera*(): Camera =
  return Camera(aspectRatio: 1.0,
                imageWidth: 100,
                samplesPerPixel: 10,
                maxDepth: 10,
                vfov: 90,
                lookfrom: Vec3(x: 0, y: 0, z: -1),
                lookat: Vec3(x: 0, y: 0, z: 0),
                vup: Vec3(x: 0, y: 1, z: 0),
                defocusAngle: 0,
                focusDist: 10,
                # these would be updated when initialize is called.
                imageHeight: 0,
                center: nil,
                pixel00Loc: nil,
                pixelDeltaU: nil,
                pixelDeltaV: nil)

proc initialize(c: Camera): void =
  c.imageHeight = (c.imageWidth.float / c.aspectRatio).int
  if c.imageHeight < 1: c.imageHeight = 1

  c.center = c.lookfrom

  let theta = c.vfov.degreesToRadians()
  let h = (theta/2).tan()
  let viewportHeight = 2.0 * h * c.focusDist
  let viewportWidth = viewportHeight * (c.imageWidth.float / c.imageHeight.float)
  
  c.w = (c.lookfrom - c.lookat).unitVector()
  c.u = c.vup.cross(c.w).unitVector()
  c.v = c.w.cross(c.u)
  
  let viewportU = viewportWidth * c.u
  let viewportV = viewportHeight * -c.v

  c.pixelDeltaU = viewportU / c.imageWidth.float
  c.pixelDeltaV = viewportV / c.imageHeight.float

  # let viewportUpperLeft = c.center - (focalLength * c.w) - viewportU/2.0 - viewportV/2.0
  let viewportUpperLeft = c.center - (c.focusDist * c.w) - viewportU/2.0 - viewportV/2.0
  c.pixel00Loc = viewportUpperLeft + 0.5 * (c.pixelDeltaU + c.pixelDeltaV)

  let defocusRadius = c.focusDist * (c.defocusAngle/2.0).degreesToRadians().tan()
  c.defocusDiskU = defocusRadius * c.u
  c.defocusDiskV = defocusRadius * c.v

proc pixelSampleSquare(c: Camera): Vec3 =
  let px = -0.5+randomDouble()
  let py = -0.5+randomDouble()
  return (px*c.pixelDeltaU) + (py*c.pixelDeltaV)

proc defocusDiskSample(c: Camera): Point3 =
  let p = randomInUnitDisk()
  return c.center + (p.x*c.defocusDiskU) + (p.y*c.defocusDiskV)
  
proc getRay(c: Camera, i: int, j: int): Ray =
  let pixelCenter = c.pixel00Loc + (i.float * c.pixelDeltaU) + (j.float * c.pixelDeltaV)
  let pixelSample = pixelCenter + c.pixelSampleSquare()
  let rayOrigin = if c.defocusAngle <= 0: c.center else: c.defocusDiskSample()
  let rayDirection = pixelSample - rayOrigin
  let r = Ray(origin: rayOrigin, direction: rayDirection)
  return r
  
# NOTE: in the book it's a hittable_list being used as a const hittable&
#       intent-wise rayColor should check for the whole world.
proc rayColor(r: Ray, depth: int, world: HittableList): Color =
  if depth <= 0: return makeColor(0, 0, 0)
  var rec = HitRecord(p: nil, normal: nil, t: 0.0, frontFace: false)
  if world.hit(r, Interval(min: 0.001, max: infinity), rec):
    var scattered = Ray(origin: nil, direction: nil)
    var attenuation = makeColor(0, 0, 0)
    if rec.mat.scatter(r, rec, attenuation, scattered):
      return attenuation * scattered.rayColor(depth-1, world)
    return makeColor(0, 0, 0)
    
  let unitDirection = r.direction.unitVector()
  let a = 0.5 * (unitDirection.y + 1.0)
  return (1.0-a)*makeColor(1, 1, 1) + a*makeColor(0.5, 0.7, 1)

proc render*(c: Camera, world: HittableList): string =
  c.initialize()
  var res = &"P6\n{c.imageWidth} {c.imageHeight}\n255\n"
  for j in 0..<c.imageHeight:
    echo "Scanlines remaining: ", (c.imageHeight - j)
    for i in 0..<c.imageWidth:
      var pixelColor = makeColor(0, 0, 0)
      
      for sample in 0..<c.samplesPerPixel:
        let r = c.getRay(i, j)
        pixelColor = pixelColor + r.rayColor(c.maxDepth, world)
      res &= pixelColor.colorToString(c.samplesPerPixel)
  echo "Done."
  return res

    
    
