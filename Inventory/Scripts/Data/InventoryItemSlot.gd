extends Object

class_name InventoryItemSlot

var ResUID: int = -1
var Count: int = 1
var EquipmentSlotType: Enums.EEquipmentSlot = Enums.EEquipmentSlot.None

func GetItemInfo()->Item:
	return load(ResourceUID.id_to_text(ResUID))
