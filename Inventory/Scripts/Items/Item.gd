class_name Item
extends Resource


@export var item_name: String = ""
@export var icon: Texture2D
@export var description: String = ""

@export var effects: Array[Enums.EItemEffectType]

@export var weight: float = 0.0
@export var base_cost: float = 0.0

func is_stackable()->bool:
	return false


func get_item_type()->int: #Enums.EItemType:
	return Enums.EItemType.ITEM

func get_type_text()->String:
	return "Item"

func get_common_properties()->Array: #[ItemProperty]:
	return []

func get_effect_props()->Array:
	if effects.size() == 0:
		return []
	
	var props: Array[ItemProperty]
	for effect in effects:
		match effect:
			Enums.EItemEffectType.MAX_EQUIP_LOAD:
				var prop: ItemProperty = ItemProperty.new()
				prop.description = "max weight"
				prop.value = 10
				props.append(prop)
			Enums.EItemEffectType.MAX_FP:
				var prop: ItemProperty = ItemProperty.new()
				prop.description = "max FP"
				prop.value = 5
				props.append(prop)
			Enums.EItemEffectType.MAX_HP:
				var prop: ItemProperty = ItemProperty.new()
				prop.description = "max health points"
				prop.value = 15
				props.append(prop)
			Enums.EItemEffectType.REGEN_HP:
				var prop: ItemProperty = ItemProperty.new()
				prop.description = "health regeneration/sec"
				prop.value = 1
				props.append(prop)
	return props
