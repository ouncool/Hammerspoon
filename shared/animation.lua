local Animation = {}

function Animation.easeOutExpo(t)
  if t == 1 then
    return 1
  end
  return 1 - math.pow(2, -10 * t)
end

return Animation
