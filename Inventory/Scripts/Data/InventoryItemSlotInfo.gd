class_name InventoryItemSlotInfo
extends Object


var res_uid: int = -1
var count: int = 1
var durability: float = 1.0
var equipment_slot_type: Enums.EEquipmentSlot = Enums.EEquipmentSlot.NONE

func get_item_info()->Item:
	return load(ResourceUID.id_to_text(res_uid))
