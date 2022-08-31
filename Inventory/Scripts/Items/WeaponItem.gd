class_name WeaponItem
extends BaseUndurableItem

@export var level: int = 1
@export var weapon_type: Enums.EWeaponSubtype = Enums.EWeaponSubtype.SWORD
@export var damage_type: Enums.EDamageType = Enums.EDamageType.PIERCE
@export var stamina_cost: float = 1.0

@export_category(Damage)
@export var physical_damage: float
@export var magic_damage: float
@export var fire_damage: float
@export var ice_damage: float

@export_category(Scaling)
@export var str_scaling: Enums.EScalingValue
@export var dex_scaling: Enums.EScalingValue
@export var int_scaling: Enums.EScalingValue

@export_category(Requireds)
@export var str_required: int
@export var dex_required: int
@export var int_required: int



func get_item_type():
	return Enums.EItemType.WEAPON

func get_type_text()->String:
	match self.weapon_type:
		Enums.EWeaponSubtype.AXE:
			return "Axe"
		Enums.EWeaponSubtype.BOW:
			return "Bow"
		Enums.EWeaponSubtype.CROSSBOW:
			return "Crossbow"
		Enums.EWeaponSubtype.SWORD:
			return "Sword"
	
	return "Weapon"

func get_common_properties()->Array: #[ItemProperty]:
	var props: Array[ItemProperty]
	if physical_damage > 0.0:
		var prop: ItemProperty = ItemProperty.new()
		prop.description = "physical damage"
		prop.value = physical_damage
		props.append(prop)
	if magic_damage > 0.0:
		var prop: ItemProperty = ItemProperty.new()
		prop.description = "magic damage"
		prop.value = magic_damage
		props.append(prop)
	if fire_damage > 0.0:
		var prop: ItemProperty = ItemProperty.new()
		prop.description = "fire damage"
		prop.value = fire_damage
		props.append(prop)
	if ice_damage > 0.0:
		var prop: ItemProperty = ItemProperty.new()
		prop.description = "ice damage"
		prop.value = ice_damage
		props.append(prop)
	return props



