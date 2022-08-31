class_name ItemSlotUI
extends BaseSlotUI


@onready var equipped_icon: TextureRect = get_node("Content/IsEquippedTextureRect")


func update_ui(slot: InventoryItemSlotInfo)->void:
	super.update_ui(slot)
	if (slot == null):
		item_icon.texture = null
		return
	
	set_is_equip(slot.equipment_slot_type != Enums.EEquipmentSlot.NONE)


func set_is_equip(value: bool):
	equipped_icon.visible = value
