elm = document.querySelector "svg"
root = SVG.create "g", elm

# Keep the SVG origin point at the center of the window
resize = ()-> SVG.attrs root,
  x: window.innerWidth/2
  y: window.innerHeight/2
window.addEventListener "resize", resize
resize()

# Make a bunch of random circles
for i in [0..10]
  SVG.create "circle", root,
    fill: "hsl(#{Math.random()*360}, 50%, 50%)"
    r: 50 + Math.random() * 50
    x: Math.random() * 500 - 250
    y: Math.random() * 500 - 250
