extends KinematicBody

# move to separate class
# https://godotengine.org/qa/40827/how-to-declare-a-global-named-enum
enum ItemType {
	None,
	Shotgun,
	SuperShotgun
}
export(ItemType) var type = ItemType.None
export(int) var quantity:int = 1
export(int) var respawnTime:int = 0
# export(String) var targetName:String = ""

