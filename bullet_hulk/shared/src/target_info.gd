extends Node
class_name TargetInfo

var t:Transform3D = Transform3D.IDENTITY
var headT:Transform3D = Transform3D.IDENTITY
var age:int = 0
var lastGroundPos:Vector3 = Vector3()
var velocity:Vector3 = Vector3()
var isCrouching:bool = false
var isSprinting:bool = false
