extends Object

class_name InventoryItemSlot

var ResourcePath: String = ""
var Count: int = 1
var EquipmentSlotType: Enums.EEquipmentSlot = Enums.EEquipmentSlot.None

func GetItemInfo()->Item:
	return load(ResourcePath)
