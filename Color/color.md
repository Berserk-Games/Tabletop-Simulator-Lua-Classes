**Color:**

Constructors:
 Color(num, num, num)       --> return a color with specified (r, g, b) components
 Color(num, num, num, num)  --> return a color with specified (r, g, b, a) components
 Color(table)               --> return a color with r/g/b/a or 1/2/3/4 components from source table (letter keys prioritized)
 Color.new(...)             --> same as Color(...)
 
 Color.fromString(colorStr) --> return a color from a color string ('Red', 'Green' etc), capitalization ignored
 Color.fromHex(hexStr)      --> return a color from a hex representation string (e.g. '#ff112233'), hash sign and alpha are optional
 col:copy()			        --> copy self into a new color and return it
 
 Color.Purple [etc]         --> shorthand for Color.fromString('Purple'), works for all player and added colors, capitalization ignored
 
Component access:
 col.r, col.g, col.b, col.a      --> read/write component
 col[1], col[2], col[3], col[4]  --> read/write component
 col:get() => num, num, num, num --> returns r, g, b, a components of self
 
 col:toHex(includeAlpha)         --> returns a hex string for self, boolean parameter
 col:toString(num)               --> returns a color string if matching this instance, nil otherwise, optional numeric tolerance param

Methods modifying self and returning self:
 col:setAt(key, num)         --> same as "col[key] = num"
 col:set(num, num, num, num) --> set r, g, b, a components to passed values

Methods not modifying self:
 col:equals(otherCol, num) --> returns true if otherCol same as self, false otherwise, optional numeric tolerance param
 col:lerp(otherCol, num)   --> return a color some part of the way between self and otherCol, numeric arg [0, 1] is the fraction
 
Operators:
 colOne == colTwo --> return true if both colors identical or within a small margin of each other, false otherwise
 tostring(col)    --> return a string description of a color
 
Other:
 Color.list                  --> table of all color strings
 Color.Add(name, yourColor)  --> add your own color definition to the class (string name, Color instance yourColor)