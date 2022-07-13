extends Item

class_name BaseConsumableItem


@export var MaxCount: int = 1
@export var MaxStoredCount: int = 600

func IsConsumable()->bool:
	return true
