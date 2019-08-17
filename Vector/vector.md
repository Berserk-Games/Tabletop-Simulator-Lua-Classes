**Vector:**

Constructors:
 Vector(num, num, num)  --> return a vector with specified (x, y, z) components
 Vector(table)          --> return a vector with x/y/z or 1/2/3 conponents from source table (x/y/z first)
 Vector.new(...)        --> same as Vector(...)
 
 Vector.max(vec1, vec2)     --> return a vector with max components between vec1 and vec2
 Vector.min(vec1, vec2)     --> return a vector with min components between vec1 and vec2
 Vector.between(vec1, vec2)	--> return a vector pointing from vec1 to vec2
 vec:copy()			        --> copy self into a new vector and retur it
 
Component access:
 vec.x, vec.y, vec.z         --> read/write component
 v[1], v[2], v[3]            --> read/write component
 vec:get() => num, num, num  --> returns x, y, z components of self
 

Methods modifying self and returning self:
 vec:setAt(key, num)    --> same as "vec[key] = num"
 vec:set(num, num, num) --> set x, y, z components to passed values
 vec:add(otherVec)      --> adds components of otherVec to self
 vec:sub(otherVec)      --> subtracts components of otherVec from self
 vec:scale(otherVec)    --> multiplies self components by corresponding compnents from otherVec
 vec:scale(num) 		--> multiplies self components by a numeric factor
 vec:clamp(num)			--> if self magnitude is higher than provided limit, scale self down to match it
 vec:normalize()		--> scale self to magnitude of 1
 vec:project(otherVec)  --> make self into projection on another vector
 vec:reflect(otherVec)  --> reflect self over a plane defined through a normal vector arg
 vec:inverse()			--> multiply self components by -1
 vec:moveTowards(otherVec, num)	  --> move self towards another vector, but only up to a provided distance limit
 vec:rotateTowards(otherVec, num) --> rotate self towards another vector, but only up to a provided angle limit
 vec:projectOnPlane(otherVec)     --> project self on a plane defined through a normal vector arg
 vec:rotateOver(axisStr, angle)   --> rotate vector for some angle in degrees over given axis ('x', 'y' or 'z')
 
Methods not modifying self:
 vec:dot(otherVec) 		   --> return a dot product of self with otherVec
 vec:magnitude()    	   --> return self magnitude (length)
 vec:sqrMagnitude() 	   --> return self magnitude (length) squared
 vec:distance(otherVec)    --> returns distance between self and otherVec
 vec:sqrDistance(otherVec) --> returns squared distance between self and otherVec
 vec:equals(otherVec, num) --> returns true if otherVec same as self (optional numeric tolerance param), false otherwise
 vec:string(str)	       --> return string describing self, optional string prefix
 vec:angle(otherVec)	   --> return an angle between self and otherVec, in degrees [0, 180]
 vec:cross(otherVec)	   --> return a cross-product vector of self and otherVec
 vec:lerp(otherVec, num)   --> return a vector some part of the way between self and otherVec, numeric arg [0, 1] is the fraction
 vec:normalized()          --> return a new vector that is normalized (length 1) version of self
 vec:orthoNormalize()	       --> return three normalized vectors perpendicular to each other, first one being in the same dir as self
 vec:orthoNormalize(otherVec)  --> same as vec:orthoNormalize(), but second vector is guranteed to be on a self-otherVec plane
 vec:heading(axisStr)          --> return signed angle of vector projection over given axis ('x', 'y' or 'z'), in degrees
 vec:heading()                 --> return three angles, vec:heading('x'), vec:heading('y'), vec:heading('z')
 
Operators:
 vecOne + vecTwo  --> return a new vector with added components of vecOne and vecTwo
 vecOne - vecTwo  --> return a new vector with subtracted components of vecTwo from vecOne
 vecOne * vecTwo  --> return a new vector with multiplied components of vecOne and vecTwo, NOT a dot product (!)
 vec * number     --> return a new vector with all components from vec scaled by a numeric factor
 number * vec 	  --> same as "vec * number"
 vecOne == vecTwo --> return true if both vectors identical or within a small margin of each other, false otherwise
 tostring(vec)    --> return a string description of a vector
 
SOME NOTES:
 RotateTowards is a mess, fairly inefficient. Rotation matrix -> quat -> rotation matrix is not fun.
 Tests aren't comprehensive, more like to filter obvious mistakes.
 "Static properties" from Unity Vector3 are omitted since we have getTransformUp() etc but could be added.
 Arguments and their types are NOT checked (for performance) - misuse may give cryptic errors.
 Some methods may be clearer for people if documented like e.g. "Vector.between(vec1, vec2)" instead of "vec1:between(vec2)" (its equivalent in lua).
 Some stuff in the "constructors" section is just normal methods, see above point.