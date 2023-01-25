extends Node

func minus_versa_plus(value: bool) -> int:
	return 1 if value else -1
	
func always_positive(value:float) -> float:
	return value*-1 if value<0 else value

func change_collision_activation(body:PhysicsBody, layer_to_change:Array=[], mask_to_change:Array=[], layer:bool=true, mask:bool=true) -> void:
	for layer_i in len(layer_to_change):
		body.set_collision_layer_bit(layer_to_change[layer_i], layer)
	for mask_i in len(mask_to_change):
		body.set_collision_mask_bit(mask_to_change[mask_i], mask)
		
func get_collision_layer_bits(body:PhysicsBody, with_value:bool=false, from:int=0, to:int=16) -> Array:
	var all_bits: Array = []
	var value: bool
	for index in range(from,to):
		value = body.get_collision_layer_bit(from+index)
		all_bits.append(from+index) if value == with_value else null
	return all_bits
		
func get_collision_mask_bits(body:PhysicsBody, with_value:bool=false, from:int=0, to:int=16) -> Array:
	var all_bits: Array = []
	var value: bool
	for index in range(from,to):
		value = body.get_collision_mask_bit(from+index)
		all_bits.append(from+index) if value == with_value else null
	return all_bits

func check_if_many_is_equal(aone : Array, atwo: Array, minimal_eq: int=1) -> bool:
	for one in aone:
		for two in atwo:
			minimal_eq -= 1 if always_positive(one) == two else 0
	return true if minimal_eq <= 0 else false
