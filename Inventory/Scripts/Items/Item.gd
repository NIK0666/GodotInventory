extends Resource

class_name Item

@export var ItemName: String = ""
@export var Weight: float = 0
@export var Icon: Texture2D
@export var DetailsTitle: String = ""
@export var DetailsDescription: String = ""

func IsConsumable()->bool:
	return false
	
func GetItemType():
	return Enums.EItemType.Item
