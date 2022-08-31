class_name BaseSlotUI
extends Panel


signal slot_mouse_entered(slot_index: int)
signal slot_mouse_exited(slot_index: int)

@onready var content: Control = get_node("Content")
@onready var count_label: Label = get_node("Content/CountLabel")
@onready var item_icon: TextureRect = get_node("Content/ItemTextureRect")
@onready var selector_icon: TextureRect = get_node("Content/SelectorTextureRect")

var _slot_info: InventoryItemSlotInfo = null 

func _ready()->void:
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)


func start_drag():
	item_icon.modulate = Color(0.0, 0.0, 0.0, 0.5)
	set_select(true)


func end_drag():
	item_icon.modulate = Color(1.0, 1.0, 1.0, 1.0)
	set_select(false)


func set_select(value: bool):
	selector_icon.visible = value


func update_ui(slot: InventoryItemSlotInfo)->void:
	if (slot == null):
		_slot_info = null
		content.visible = false
		selector_icon.visible = false
		return
	
	_slot_info = slot
	content.visible = true
	
	var item_info: Item = _slot_info.get_item_info()
	item_icon.texture = item_info.icon
	
	if (item_info.is_stackable()):
		count_label.visible = true
		count_label.text = str(_slot_info.count)
	else:
		count_label.visible = false


func get_item_slot_info()->InventoryItemSlotInfo:
	return _slot_info


func is_empty()->bool:
	return _slot_info == null


func _on_mouse_entered():
	emit_signal("slot_mouse_entered", get_index())


func _on_mouse_exited():
	emit_signal("slot_mouse_exited", get_index())
