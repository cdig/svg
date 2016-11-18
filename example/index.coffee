elm = document.querySelector "svg"
root = SVG.create "g", elm
circles = []
lastTime = 0

# Keep the SVG origin point at the center of the window
resize = ()-> SVG.attrs root,
  x: window.innerWidth/2
  y: window.innerHeight/2
window.addEventListener "resize", resize
resize()

# Count how many circles we're animating
counter = SVG.create "text", root,
  textAnchor: "middle"
  fill: "white"
  fontFamily: "Helvetica"

updateCounter = (fps)->
  SVG.attr counter, "textContent", "#{circles.length} Circles — #{fps|0}FPS"

spawnCircles = ()->
  for i in [0..10]
    circles.push circle =
      phase: 0
      rate: Math.random()
      elm: SVG.create "circle", root,
        fill: "hsl(#{Math.random()*360}, 50%, 50%)"

animateCircles = (dt)->
  for circle in circles
    circle.phase += dt * circle.rate
    SVG.attrs circle.elm,
      x: 300 * Math.cos circle.phase / 3
      y: 300 * Math.sin circle.phase / 7
      r: 50 + 50 * Math.cos circle.phase / 11

tick = (time)->
  requestAnimationFrame tick
  dt = (time - lastTime)/1000
  fps = 1000/(time - lastTime)
  lastTime = time
  return if fps < 10 # Cap to a minimum of 10FPS, to avoid jumping when tab switching
  spawnCircles() if fps > 50 # Spawn circles until we barely maintain 50fps
  animateCircles dt
  updateCounter fps

requestAnimationFrame tick
