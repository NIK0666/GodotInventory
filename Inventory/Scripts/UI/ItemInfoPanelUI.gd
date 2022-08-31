class_name ItemInfoPanel
extends PanelContainer


@onready var name_label: Label = get_node("ItemInfoVBox/CommonVBox/NameLabel")
@onready var item_type_label: Label = get_node("ItemInfoVBox/CommonVBox/ItemTypeMargin/ItemTypeLabel")

@onready var weight_label: Label = get_node("ItemInfoVBox/FooterVBox/Control/WeightHBox/WeightLabel")
@onready var cost_label: Label = get_node("ItemInfoVBox/FooterVBox/Control/CostHBox/CostLabel")
@onready var durability_hbox: HBoxContainer = get_node("ItemInfoVBox/FooterVBox/Control/DurabilityHBox")
@onready var durability_label: Label = get_node("ItemInfoVBox/FooterVBox/Control/DurabilityHBox/DurabilityLabel")

@onready var desc_vbox: VBoxContainer = get_node("ItemInfoVBox/DescriptionVBox")
@onready var description_label: Label = get_node("ItemInfoVBox/DescriptionVBox/DescriptionMargin/DescriptionLabel")

@onready var common_props_hbox: HBoxContainer = get_node("ItemInfoVBox/CommonVBox/PropertiesHBox")
@onready var common_prop_values_vbox: VBoxContainer = get_node("ItemInfoVBox/CommonVBox/PropertiesHBox/ValuesVBox")
@onready var common_prop_texts_vbox: VBoxContainer = get_node("ItemInfoVBox/CommonVBox/PropertiesHBox/TextsVBox")

@onready var effect_requireds_vbox: VBoxContainer = get_node("ItemInfoVBox/EffectsAndRequiredsVBox")
@onready var effect_requireds_separator: MarginContainer = get_node("ItemInfoVBox/EffectsAndRequiredsVBox/EffectsAndRequiredSeparator")

@onready var effect_props_hbox: HBoxContainer = get_node("ItemInfoVBox/EffectsAndRequiredsVBox/PropertiesHBox")
@onready var effect_prop_values_vbox: VBoxContainer = get_node("ItemInfoVBox/EffectsAndRequiredsVBox/PropertiesHBox/ValuesVBox")
@onready var effect_prop_texts_vbox: VBoxContainer = get_node("ItemInfoVBox/EffectsAndRequiredsVBox/PropertiesHBox/TextsVBox")

@onready var requireds_vbox: VBoxContainer = get_node("ItemInfoVBox/EffectsAndRequiredsVBox/RequiredsVBox")
@onready var requireds_values_vbox: VBoxContainer = get_node("ItemInfoVBox/EffectsAndRequiredsVBox/RequiredsVBox/RequiredsHBox/ValuesVBox")
@onready var requireds_texts_vbox: VBoxContainer = get_node("ItemInfoVBox/EffectsAndRequiredsVBox/RequiredsVBox/RequiredsHBox/TextsVBox")

@onready var anim_player: AnimationPlayer = get_node("AnimationPlayer")

func _ready():
	visible = false


func show_ui(slot: InventoryItemSlotInfo):
	visible = true
	anim_player.play("RESET")
	var item_info: Item = slot.get_item_info()
	var item_type: Enums.EItemType = item_info.get_item_type()
	
	# Common section
	name_label.text = item_info.item_name
	item_type_label.text = item_info.get_type_text()
	
	var common_props: Array[ItemProperty] = item_info.get_common_properties()
	if common_props.size() > 0:
		common_props_hbox.visible = true
		for i in range(0, 4, 1):
			if i < common_props.size():
				(common_prop_texts_vbox.get_child(i) as Label).visible = true
				(common_prop_texts_vbox.get_child(i) as Label).text = common_props[i].description
				(common_prop_values_vbox.get_child(i) as Label).visible = true
				(common_prop_values_vbox.get_child(i) as Label).text = str(common_props[i].value)
			else:
				(common_prop_texts_vbox.get_child(i) as Label).visible = false
				(common_prop_values_vbox.get_child(i) as Label).visible = false
	else:
		common_props_hbox.visible = false
	
	# Effects section
	var effect_props: Array[ItemProperty] = item_info.get_effect_props()
	if effect_props.size() > 0:
		effect_props_hbox.visible = true
		for i in range(0, 4, 1):
			if i < effect_props.size():
				(effect_prop_texts_vbox.get_child(i) as Label).visible = true
				(effect_prop_texts_vbox.get_child(i) as Label).text = effect_props[i].description
				(effect_prop_values_vbox.get_child(i) as Label).visible = true
				(effect_prop_values_vbox.get_child(i) as Label).text = str(effect_props[i].value)
			else:
				(effect_prop_texts_vbox.get_child(i) as Label).visible = false
				(effect_prop_values_vbox.get_child(i) as Label).visible = false
	else:
		effect_props_hbox.visible = false
	
	# Requirments section
	if item_type == Enums.EItemType.WEAPON:
		var weapon: WeaponItem = item_info as WeaponItem
		var index: int = -1
		if weapon.str_required > 0:
			index += 1
			(requireds_texts_vbox.get_child(index) as Label).visible = true
			(requireds_texts_vbox.get_child(index) as Label).text = "strength"
			(requireds_values_vbox.get_child(index) as Label).visible = true
			(requireds_values_vbox.get_child(index) as Label).text = str(weapon.str_required)
		if weapon.dex_required > 0:
			index += 1
			(requireds_texts_vbox.get_child(index) as Label).visible = true
			(requireds_texts_vbox.get_child(index) as Label).text = "dexterity"
			(requireds_values_vbox.get_child(index) as Label).visible = true
			(requireds_values_vbox.get_child(index) as Label).text = str(weapon.dex_required)
		if weapon.int_required > 0:
			index += 1
			(requireds_texts_vbox.get_child(index) as Label).visible = true
			(requireds_texts_vbox.get_child(index) as Label).text = "intelligence"
			(requireds_values_vbox.get_child(index) as Label).visible = true
			(requireds_values_vbox.get_child(index) as Label).text = str(weapon.int_required)
		for i in range(index + 1, 3, 1):
			(requireds_texts_vbox.get_child(i) as Label).visible = false
			(requireds_values_vbox.get_child(i) as Label).visible = false
		requireds_vbox.visible = (index >= 0) 
	else:
		requireds_vbox.visible = false
	
	effect_requireds_vbox.visible = effect_props_hbox.visible or requireds_vbox.visible
	effect_requireds_separator.visible = effect_props_hbox.visible and requireds_vbox.visible
	
	# Footer section
	weight_label.text = str(item_info.weight * slot.count)
	cost_label.text = str(item_info.base_cost * slot.count)
	if item_info.get("max_durability") != null:
		durability_hbox.visible = true
		durability_label.text = str(int(item_info.max_durability / slot.durability * 100))
	else:
		durability_hbox.visible = false
	
	# Description section
	if item_info.description.is_empty():
		desc_vbox.visible = false
	else:
		desc_vbox.visible = true
		description_label.text = item_info.description
	
	size.y = 0 # For resize Y


func hide_ui():
	anim_player.play("HideAnim")
