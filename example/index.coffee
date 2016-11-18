# In this example, you'll see idiomatic usage of various library functions:
# SVG.create, for spawning new SVG elements
# SVG.attr, for setting a single attribute by name
# SVG.attrs, for setting a bunch of attributes using an object
# SVG.append, for creating a parent-child relationship (used here for sorting)


# Grab the <svg> element from the HTML
elm = document.querySelector "svg"

# Create a root group, which let's us center things in the window
# SVG.create takes an element type ("g" becomes a <g>, which is an SVG group element),
# and an optional parent element
root = SVG.create "g", elm

# Create a text element inside our root group, which we'll use to display some debug info
# This time, we provide an optional third argument: an object of attributes to set on the newly created element
counter = SVG.create "text", root,
  textAnchor: "middle" # textAnchor is normalized into "text-anchor", and does basically the same thing as the CSS "text-align" property
  fill: "white" # this sets the text color
  fontFamily: "Helvetica" # you get the idea

# An array of circles to animate
circles = []

# The timestamp for the most recent frame, used for FPS / dt (delta time) calculations
lastTime = 0


# Keep the SVG origin point at the center of the window
resize = ()->
  # This is an idiomatic example of the SVG.attrs function,
  # used here to set the x and y attributes of the root element.
  # This is a bit of a trick example, since x and y are desugared into a transform string,
  # which is then applied to the transform attribute. Hakuna matata.
  SVG.attrs root,
    x: window.innerWidth/2
    y: window.innerHeight/2

# Run resize() now, and every time the window is resized
resize()
window.addEventListener "resize", resize


# We'll call this function every frame to update our counter element with some helpful debug info
updateCounter = (fps)->
  SVG.attr counter, "textContent", "#{circles.length} Circles — #{fps|0}FPS"
  # We're using SVG.attr here, but we could have also written:
  ## SVG.attrs counter, textContent: "#{circles.length} Circles — #{fps|0}FPS"
  # The choice for one or the other is largely a matter of taste, but SVG.attr is slightly faster


# This function spawns a bunch of new circles, and then re-appends the counter to the root,
# which has the effect of sorting it on top of the circles in the display hierarchy
spawnCircles = ()->
  for i in [0...10]
    # Each "circle" in the array is an object with 3 properties: A phase value, a rate value, and an SVG element
    circles.push circle =
      phase: 0
      rate: Math.random()
      elm: SVG.create "circle", root, fill: "hsl(#{Math.random()*360}, 50%, 50%)"
  SVG.append root, counter


# Move the circles around
animateCircles = (dt)->
  for circle in circles
    
    # Each circle advances at a slightly different rate
    circle.phase += dt * circle.rate
    
    # Animate the position and radius of the circle
    SVG.attrs circle.elm,
      x: 300 * Math.cos circle.phase / 3
      y: 300 * Math.sin circle.phase / 7
      r: 50 + 50 * Math.cos circle.phase / 11


# Here's our main tick function, which runs every frame and advances the state of the animation
tick = (time)->
  
  # Re-run tick on the next frame
  requestAnimationFrame tick
  
  # Keep track of the passage of time
  dt = (time - lastTime)/1000
  fps = 1000/(time - lastTime)
  lastTime = time
  
  # Cap to a minimum of 10FPS, to avoid jumping when tab switching
  return if fps < 10
  
  # Spawn circles until we barely maintain 50fps
  spawnCircles() if fps > 50
  
  animateCircles dt
  updateCounter fps

# Start ticking
requestAnimationFrame tick
