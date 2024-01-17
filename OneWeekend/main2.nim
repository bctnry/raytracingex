import std/syncio
import std/math
import hittable_collection
import sphere
import camera
import vec3
import materialtype
import material
import color
import rtweekend

let materialGround = makeLambertian(makeColor(0.5, 0.5, 0.5))
var world: HittableList = @[]
world.add(Sphere(center: Vec3(x: 0.0, y: -1000.0, z: 0.0), radius: 1000.0, mat: materialGround))
for a in -11..<11:
  for b in -11..<11:
    let chooseMat = randomDouble()
    let center = Vec3(x: a.float + 0.9*randomDouble(), y: 0.2, z: b.float + 0.9*randomDouble())
    if (center - Vec3(x: 4, y: 0.2, z: -1.0)).length() > 0.9:
      if chooseMat < 0.8:
        let albedo = randomVec3()*randomVec3()
        let material = makeLambertian(albedo)
        world.add(Sphere(center: center, radius: 0.2, mat: material))
      elif chooseMat < 0.95:
        let albedo = randomVec3(0.5, 1)
        let fuzz = randomDouble(0, 0.5)
        let material = makeMetal(albedo, fuzz)
        world.add(Sphere(center: center, radius: 0.2, mat: material))
      else:
        let material = makeDielectric(1.5)
        world.add(Sphere(center: center, radius: 0.2, mat: material))

let material1 = makeDielectric(1.5)
world.add(Sphere(center: Vec3(x: 0.0, y: 1.0, z: 0.0), radius: 1.0, mat: material1))
let material2 = makeLambertian(makeColor(0.4, 0.2, 0.1))
world.add(Sphere(center: Vec3(x: -4.0, y: 1.0, z: 0.0), radius: 1.0, mat: material2))
let material3 = makeMetal(makeColor(0.7, 0.6, 0.5), 0.0)
world.add(Sphere(center: Vec3(x: 4.0, y: 1.0, z: 0.0), radius: 1.0, mat: material3))

var cam = makeCamera()
cam.aspectRatio = 16.0 / 9.0
cam.imageWidth = 1200
cam.samplesPerPixel = 500
cam.maxDepth = 50
cam.vfov = 20
cam.lookfrom = Vec3(x: 13.0, y: 2.0, z: 3.0)
cam.lookat = Vec3(x: 0.0, y: 0.0, z: 0.0)
cam.vup = Vec3(x: 0.0, y: 1.0, z: 0.0)
cam.defocusAngle = 0.6
cam.focusDist = 10.0

let renderRes = cam.render(world)

let f = open("image.ppm", fmWrite)
f.write(renderRes)
f.flushFile()
f.close()

