extends Item

class_name WeaponItem

@export var StaminaCost: float

func GetItemType():
	return Enums.EItemType.Weapon
