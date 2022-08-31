extends Control


@onready var inv: InventoryComponent = get_node("Inventory")
@onready var drag_icon: TextureRect = get_node("DragItemTextureRect")
@onready var inventory_grid: GridContainer = get_node("InventoryGrid")
@onready var equipment_control: Control = get_node("EquipmentControl")
@onready var item_info_panel: ItemInfoPanel = get_node("ItemInfoPanel")
@onready var equip_info_panel: ItemInfoPanel = get_node("EquipInfoPanel")
@onready var weapon_button: Button = get_node("TypesPanel/TypesHBox/WeaponButton")


const START_DRAG_OFFSET_SQ: float = 64.0
const GROUP_FILTERS: Array = [
	[Enums.EItemType.WEAPON],
	[Enums.EItemType.ARMOR, Enums.EItemType.HELM, Enums.EItemType.BOOTS],
	[Enums.EItemType.CONSUMABLE],
	[Enums.EItemType.AMULET],
	[Enums.EItemType.NOTE],
	[Enums.EItemType.ITEM],
]


var _inventory_slots: Array[InventoryItemSlotInfo]
var _selected_item_slot: ItemSlotUI = null
var _selected_equip_slot: EquipSlotUI = null

var _is_drag_start: bool = false
var _drag_time: float = 0
var _is_slot_interact_pressed: bool = false
var _slot_interact_mouse_pos: Vector2

var _current_filters: Array[Enums.EItemType]


func _ready():
	inv.connect("added_item", _on_added_item)
	inv.connect("equip_item_changed", _on_equip_item_changed)
	
	inv.set_items([
		ItemSlotInfo.new("res://Inventory/Data/Weapons/Dagger.tres", 1, Enums.EEquipmentSlot.R_HAND_1),
		ItemSlotInfo.new("res://Inventory/Data/Weapons/WoodSword.tres"),
		ItemSlotInfo.new("res://Inventory/Data/Weapons/FireDagger.tres"),
		ItemSlotInfo.new("res://Inventory/Data/Notes/CooksBook.tres"),
		ItemSlotInfo.new("res://Inventory/Data/Weapons/DoubleAxe.tres"),
		ItemSlotInfo.new("res://Inventory/Data/Weapons/WoodBow.tres"),
		ItemSlotInfo.new("res://Inventory/Data/Armors/TestArmor.tres", 1, Enums.EEquipmentSlot.ARMOR),
		ItemSlotInfo.new("res://Inventory/Data/Helms/TestHelm.tres", 1, Enums.EEquipmentSlot.HELM),
		ItemSlotInfo.new("res://Inventory/Data/Boots/TestBoots.tres"),
		ItemSlotInfo.new("res://Inventory/Data/Consumables/Lamp.tres", randi()%15+1),
		ItemSlotInfo.new("res://Inventory/Data/Consumables/Lifegem.tres", randi()%15+1),
		ItemSlotInfo.new("res://Inventory/Data/Consumables/Potion.tres", randi()%15+1),
		ItemSlotInfo.new("res://Inventory/Data/Notes/letterFromGrandfather.tres"),
		ItemSlotInfo.new("res://Inventory/Data/Notes/WorldMap.tres"),
		ItemSlotInfo.new("res://Inventory/Data/Other/Coins.tres", randi()%20000+1),
	], true)
	
	_update_bag_filter(0)
	weapon_button.button_group.connect("pressed", _filter_changed)

	
	for slot in inventory_grid.get_children() as Array[ItemSlotUI]:
		slot.connect("slot_mouse_entered", _on_item_slot_mouse_entered)
		slot.connect("slot_mouse_exited", _on_item_slot_mouse_exited)
	
	for slot in equipment_control.get_children() as Array[EquipSlotUI]:
		slot.connect("slot_mouse_entered", _on_equip_slot_mouse_entered)
		slot.connect("slot_mouse_exited", _on_equip_slot_mouse_exited)


func _process(delta: float)->void:
	if _is_slot_interact_pressed:
		if (_slot_interact_mouse_pos - get_global_mouse_position()).length_squared() > START_DRAG_OFFSET_SQ:
			_is_slot_interact_pressed = false
			
			if _selected_item_slot != null:
				_on_item_slot_drag_start(_selected_item_slot)
			elif _selected_equip_slot != null:
				_on_equip_slot_drag_start(_selected_equip_slot)
	
	if _is_drag_start:
		drag_icon.position = get_global_mouse_position() - drag_icon.size / 2.0
		_drag_time += delta
		drag_icon.rotation = sin(_drag_time * 6.5) * 0.15


func _input(event: InputEvent):
	if event.is_action_pressed("UIItemInteract"):
		if _selected_item_slot == null and _selected_equip_slot == null:
			return
		
		var mouse_event: InputEventMouseButton = (event as InputEventMouseButton)
		_is_slot_interact_pressed = true
		_slot_interact_mouse_pos = get_global_mouse_position()
		
		if mouse_event.double_click:
			_is_slot_interact_pressed = false
			if _selected_item_slot != null:
				var slot_info: InventoryItemSlotInfo = _selected_item_slot.get_item_slot_info()
				if (slot_info.get_item_info().get_item_type() != Enums.EItemType.ITEM
						and slot_info.equipment_slot_type == Enums.EEquipmentSlot.NONE):
					inv.set_equip_item(_selected_item_slot.get_item_slot_info())
			elif _selected_equip_slot != null:
				inv.clear_equip_slot(_selected_equip_slot.slot_type)
				equip_info_panel.hide_ui()
	
	elif event.is_action_released("UIItemInteract"):
		_is_slot_interact_pressed = false
		if _selected_item_slot != null:
			_on_item_slot_drag_end(_selected_item_slot)
		elif _selected_equip_slot != null:
			_on_equip_slot_drag_end(_selected_equip_slot)


func _unhandled_input(event):
	pass


func _on_added_item(slot: InventoryItemSlotInfo, item: Item, count: int):
	var slot_index: int = _inventory_slots.find(slot)
	if (slot_index == -1):
		_inventory_slots.append(slot)
		slot_index = _inventory_slots.size() - 1

	var slot_ui: ItemSlotUI = _get_inventory_item_slot_by_index(slot_index)
	slot_ui.update_ui(slot)


func _on_equip_item_changed(slot_type: Enums.EEquipmentSlot, from_item_slot: InventoryItemSlotInfo, to_item_slot: InventoryItemSlotInfo):
	var equip_slot_ui: EquipSlotUI = _get_inventory_equip_slot(slot_type)
	if (from_item_slot != null):
		var item_slot_ui: ItemSlotUI = _get_inventory_item_slot(from_item_slot)
		if (item_slot_ui != null):
			item_slot_ui.set_is_equip(false)
		if equip_slot_ui != null:
			equip_slot_ui.update_ui(null)
		
	if (to_item_slot != null):
		var item_slot_ui: ItemSlotUI = _get_inventory_item_slot(to_item_slot)
		if (item_slot_ui != null):
			item_slot_ui.set_is_equip(true)
		if equip_slot_ui != null:
			equip_slot_ui.update_ui(to_item_slot)


func _on_item_slot_mouse_entered(index: int)->void:
	var slot_ui: ItemSlotUI = _get_inventory_item_slot_by_index(index)
	if not _is_drag_start and not slot_ui.is_empty():
		_change_item_slot_selected(slot_ui, true)


func _on_item_slot_mouse_exited(index: int)->void:
	var slot_ui: ItemSlotUI = _get_inventory_item_slot_by_index(index)
	if not _is_drag_start and not slot_ui.is_empty():
		_change_item_slot_selected(slot_ui, false)


func _on_equip_slot_mouse_entered(index: int)->void:
	var slot_ui: EquipSlotUI = _get_equip_slot_by_index(index)
	if not _is_drag_start and not slot_ui.is_empty():
		_change_equip_slot_selected(slot_ui, true)


func _on_equip_slot_mouse_exited(index: int)->void:
	var slot_ui: EquipSlotUI = _get_equip_slot_by_index(index)
	if not _is_drag_start and not slot_ui.is_empty():
		_change_equip_slot_selected(slot_ui, false)


func _change_item_slot_selected(slot_ui: ItemSlotUI, is_selected: bool):
	if is_selected:
		_selected_item_slot = slot_ui
	else:
		_selected_item_slot = null
	
	if slot_ui != null:
		slot_ui.set_select(is_selected)
		if is_selected:
			item_info_panel.show_ui(slot_ui.get_item_slot_info())
		else:
			item_info_panel.hide_ui()


func _change_equip_slot_selected(slot_ui: EquipSlotUI, is_selected: bool):
	if is_selected:
		_selected_equip_slot = slot_ui
	else:
		_selected_equip_slot = null
	
	if slot_ui:
		slot_ui.set_select(is_selected)
		if is_selected:
			equip_info_panel.show_ui(slot_ui.get_item_slot_info())
		else:
			equip_info_panel.hide_ui()

# Drag and Drop
func _on_item_slot_drag_start(slot_ui: ItemSlotUI)->void:
	if slot_ui == null or _is_drag_start:
		return
	
	_change_equipment_slots_activity(
			slot_ui.get_item_slot_info().get_item_info().get_item_type(), true)
	_is_drag_start = true
	drag_icon.texture = slot_ui.item_icon.texture
	drag_icon.visible = true
	_drag_time = 0.0
	drag_icon.position = get_global_mouse_position() - drag_icon.size / 2.0
	slot_ui.start_drag()


func _on_item_slot_drag_end(slot_ui: ItemSlotUI)->void:
	if not _is_drag_start:
		return
	
	_change_equipment_slots_activity(
			slot_ui.get_item_slot_info().get_item_info().get_item_type(), false)
	_is_drag_start = false
	drag_icon.visible = false
	slot_ui.end_drag()
	
	if _selected_item_slot != null:
		_change_item_slot_selected(_selected_item_slot, false)
	
	var equip_slot_ui: EquipSlotUI = _get_equip_slot_under_cursor()
	if (equip_slot_ui != null 
			and slot_ui.get_item_slot_info() != equip_slot_ui.get_item_slot_info()
			and inv.get_item_type_by_slot_type(equip_slot_ui.slot_type) == 
					slot_ui.get_item_slot_info().get_item_info().get_item_type()):
		inv.set_equip_item_to_slot(slot_ui.get_item_slot_info(), equip_slot_ui.slot_type)
	
	_select_slot_under_cursor()


func _on_equip_slot_drag_start(equip_slot_ui: EquipSlotUI):
	if equip_slot_ui == null or _is_drag_start:
		return
	
	var equip_slot_type: Enums.EItemType = inv.get_item_type_by_slot_type(equip_slot_ui.slot_type)
	_change_equipment_slots_activity(equip_slot_type, true)
	
	_is_drag_start = true
	drag_icon.texture = equip_slot_ui.item_icon.texture
	drag_icon.visible = true
	_drag_time = 0.0
	equip_slot_ui.start_drag()


func _on_equip_slot_drag_end(equip_slot_ui: EquipSlotUI):
	if not _is_drag_start:
		return
	
	var equip_slot_type: Enums.EItemType = inv.get_item_type_by_slot_type(equip_slot_ui.slot_type)
	_change_equipment_slots_activity(equip_slot_type, false)
	
	_is_drag_start = false
	drag_icon.visible = false
	equip_slot_ui.end_drag()
	
	if _selected_equip_slot != null:
		_change_equip_slot_selected(_selected_equip_slot, false)
	
	var other_equip_slot_ui: EquipSlotUI = _get_equip_slot_under_cursor()
	if (other_equip_slot_ui != null and other_equip_slot_ui != equip_slot_ui 
			and inv.get_item_type_by_slot_type(other_equip_slot_ui.slot_type) == 
					equip_slot_type):
		inv.set_equip_item_to_slot(equip_slot_ui.get_item_slot_info(), other_equip_slot_ui.slot_type)

	if (_select_slot_under_cursor() as EquipSlotUI) == null:
		inv.clear_equip_slot(equip_slot_ui.slot_type)


func _get_equip_slot_under_cursor()->EquipSlotUI:
	if _check_mouse_under_control(equipment_control):
		for slot in equipment_control.get_children() as Array[EquipSlotUI]:
			if _check_mouse_under_control(slot):
				return slot
	return null


func _get_item_slot_under_cursor()->ItemSlotUI:
	if _check_mouse_under_control(inventory_grid):
		for slot in inventory_grid.get_children() as Array[ItemSlotUI]:
			if _check_mouse_under_control(slot):
				return slot
	return null


func _change_equipment_slots_activity(item_type: Enums.EItemType, is_active: bool):
	for slot in equipment_control.get_children() as Array[EquipSlotUI]:
		var check_type: Enums.EItemType = inv.get_item_type_by_slot_type(slot.slot_type)
		if check_type == item_type:
			slot.set_active(is_active)


func _check_mouse_under_control(in_control: Control)->bool:
	var m_x: float = get_global_mouse_position().x
	var m_y: float = get_global_mouse_position().y 
	return (m_x > in_control.global_position.x and m_y > in_control.global_position.y 
			and m_x < in_control.global_position.x + in_control.size.x
			and m_y < in_control.global_position.y + in_control.size.y)


func _select_slot_under_cursor()->BaseSlotUI:
	var item_slot_ui: ItemSlotUI = _get_item_slot_under_cursor()
	if item_slot_ui != null:
		if _selected_item_slot != null:
			_change_item_slot_selected(_selected_item_slot, false)
		if not item_slot_ui.is_empty():
			_change_item_slot_selected(item_slot_ui, true)
		return item_slot_ui
	
	var equip_slot_ui: EquipSlotUI = _get_equip_slot_under_cursor()
	if equip_slot_ui != null:
		if _selected_equip_slot != null:
			_change_equip_slot_selected(_selected_equip_slot, false)
		if not equip_slot_ui.is_empty():
			_change_equip_slot_selected(equip_slot_ui, true)
		return equip_slot_ui
	return null


# Вспомогательные функции ----------------------------------------

func _get_inventory_item_slot_by_index(index: int)->ItemSlotUI:
	return inventory_grid.get_child(index)


func _get_inventory_item_slot(slot: InventoryItemSlotInfo)->ItemSlotUI:
	var slot_index: int = _inventory_slots.find(slot)
	if slot_index == -1:
		return null
	return _get_inventory_item_slot_by_index(slot_index)


func _get_inventory_equip_slot(slot_type: Enums.EEquipmentSlot)->EquipSlotUI:
	for slot in equipment_control.get_children() as Array[EquipSlotUI]:
		if slot.slot_type == slot_type:
			return slot
	return null


func _get_equip_slot_by_index(index: int)->EquipSlotUI:
	return equipment_control.get_child(index)


# Filter category
func _filter_changed(button: Button)-> void:
	_update_bag_filter(button.get_index())
	
func _update_bag_filter(index: int):
	if _current_filters == GROUP_FILTERS[index]:
		return
	_current_filters = GROUP_FILTERS[index]
	
	for slot_ui in inventory_grid.get_children() as Array[ItemSlotUI]:
		slot_ui.update_ui(null)
	_inventory_slots.clear()
	
	for filter in _current_filters:
		var slots: Array[InventoryItemSlotInfo] = inv.get_inventory_items(filter)
		for slot in slots:
			_on_added_item(slot, slot.get_item_info(), slot.count)
