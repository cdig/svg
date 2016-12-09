@SVG =
  svgNS: "http://www.w3.org/2000/svg"
  xlinkNS: "http://www.w3.org/1999/xlink"
  
  # This is used to cache normalized keys, and to provide defaults for keys that shouldn't be normalized
  attrNames:
    gradientUnits: "gradientUnits"
    startOffset: "startOffset"
    viewBox: "viewBox"
    # additional attr names should be listed here as needed
  
  # This is used to distinguish properties from attributes, so we can set both with SVG.attr
  propNames:
    textContent: true
    # additional property names should be listed here as needed

  # This is used to distinguish transforms from regular attributes, so we don't have to use transform strings
  # The handling of transforms is (unfortunately) opinionated and quite limited. Eg: uniform scale only
  tranNames:
    rotate: true
    scale: true
    x: true
    y: true
  
  
  create: (type, parent, attrs)->
    elm = document.createElementNS SVG.svgNS, type
    SVG.attrs elm, attrs if attrs?
    SVG.append parent, elm if parent?
    return elm
  
  clone: (source, parent, attrs)->
    throw new Error "Clone source is undefined in SVG.clone(source, parent, attrs)" unless source?
    elm = document.createElementNS SVG.svgNS, "g"
    SVG.attr elm, attr.name, attr.value for attr in source.attributes
    SVG.attrs elm, id: null
    SVG.attrs elm, attrs if attrs?
    SVG.append elm, child.cloneNode true for child in source.childNodes
    SVG.append parent, elm if parent?
    return elm
  
  append: (parent, child)->
    parent.appendChild child
    return child
  
  prepend: (parent, child)->
    if parent.hasChildNodes()
      parent.insertBefore child, parent.firstChild
    else
      parent.appendChild child
    return child

  remove: (parent, child)->
    parent.removeChild child
    return child
  
  removeAllChildren: (parent)->
    while parent.children.length > 0
      parent.removeChild parent.firstChild
  
  attrs: (elm, attrs)->
    unless elm then throw new Error "SVG.attrs was called with a null element"
    unless typeof attrs is "object" then console.log attrs; throw new Error "SVG.attrs requires an object as the second argument, got ^"
    for k, v of attrs
      SVG.attr elm, k, v
    return elm
  
  attr: (elm, k, v)->
    unless elm then throw new Error "SVG.attr was called with a null element"
    unless typeof k is "string" then console.log k; throw new Error "SVG.attr requires a string as the second argument, got ^^^"
    
    # Initialize the caches
    elm._SVG_attr ?= {}
    elm._SVG_prop ?= {}
    elm._SVG_tran ?= x:0, y:0, rotate:0, scale:1
    
    # Determine whether this is a read or a write
    isRead = v is undefined
    
    # For properties, we just do a cached read or write and then bail
    if SVG.propNames[k]?
      cache = elm._SVG_prop
      isCached = cache[k] is v
      return cache[k] ?= elm[k] if isRead or isCached
      return elm[k] = cache[k] = v
    
    # For transforms, we do a cached read and bail, or build a new attribute value and fall through
    if SVG.tranNames[k]?
      cache = elm._SVG_tran
      isCached = cache[k] is v
      return cache[k] if isRead or isCached
      cache[k] = v
      v = "translate(#{cache.x},#{cache.y}) rotate(#{cache.rotate}) scale(#{cache.scale})"
      k = "transform"
    
    # For attributes, we do a cached read and bail, or do a lot of nonsense and then write
    cache = elm._SVG_attr
    isCached = cache[k] is v
    return cache[k] ?= v if isRead or isCached
    cache[k] = v
    ns = if k is "xlink:href" then SVG.xlinkNS else null # Grab the namespace if needed
    k = SVG.attrNames[k] ?= k.replace(/([A-Z])/g,"-$1").toLowerCase() # Normalize camelCase into kebab-case
    if v?
      elm.setAttributeNS ns, k, v # set DOM attribute
    else # v is explicitly set to null (not undefined)
      elm.removeAttributeNS ns, k # remove DOM attribute
    return v
  
  styles: (elm, styles)->
    unless elm then throw new Error "SVG.styles was called with a null element"
    unless typeof styles is "object" then console.log styles; throw new Error "SVG.styles requires an object as the second argument, got ^"
    SVG.style elm, k, v for k, v of styles
    return elm
  
  style: (elm, k, v)->
    unless elm then throw new Error "SVG.style was called with a null element"
    unless typeof k is "string" then console.log k; throw new Error "SVG.style requires a string as the second argument, got ^"
    elm._SVG_style ?= {}
    return elm._SVG_style[k] ?= elm.style[k] if v is undefined
    if elm._SVG_style[k] isnt v
      elm.style[k] = elm._SVG_style[k] = v
    return v
