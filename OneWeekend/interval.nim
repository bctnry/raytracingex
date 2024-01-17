import rtweekend

type
  Interval* = ref object
    min*: float
    max*: float

func contains*(i: Interval, x: float): bool = i.min <= x and x <= i.max
func surrounds*(i: Interval, x: float): bool = i.min < x and x < i.max
func clamp*(i: Interval, x: float): float =
  if x < i.min: i.min
  elif x > i.max: i.max
  else: x

let empty* = Interval(min: +infinity, max: -infinity)
let universe* = Interval(min: -infinity, max: +infinity)

    
