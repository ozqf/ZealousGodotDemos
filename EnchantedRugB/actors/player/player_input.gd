extends Node
class_name PlayerInput

var inputDir:Vector3 = Vector3()
var pushDir:Vector3 = Vector3()
var camera:Transform3D = Transform3D()
var aimPoint:Vector3 = Vector3()
var yaw:float = 0.0
var attack1:bool = false
var attack2:bool = false
var grab:bool = false
var dash:bool = false
var style:bool = false

var isGrounded:bool = true
var hookState:int = 0
var hookPosition:Vector3 = Vector3()
