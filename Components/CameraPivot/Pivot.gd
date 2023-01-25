extends SpringArm

export var y_sens : float = 0.5
export var x_sens : float = 0.3
export var deadzone: float = 0.2
export var y_joy_sens : float = 1.5
export var x_joy_sens : float = 1
export var clamp_amount_min : int = -45
export var clamp_amount_max : int = 60

func _input(event) -> void:
	if event is InputEventJoypadMotion:
		rotation_degrees.y -= Input.get_joy_axis(0, JOY_ANALOG_RX) * int(Input.get_joy_axis(0, JOY_ANALOG_RX)>deadzone or Input.get_joy_axis(0, JOY_ANALOG_RX)<-deadzone)*y_joy_sens
		rotation_degrees.x -= Input.get_joy_axis(0, JOY_ANALOG_RY) * int(Input.get_joy_axis(0, JOY_ANALOG_RY)>deadzone or Input.get_joy_axis(0, JOY_ANALOG_RY)<-deadzone)*x_joy_sens
	elif event is InputEventMouseMotion:
		rotation_degrees.x -= event.relative.y * y_sens
		rotation_degrees.y -= event.relative.x * x_sens
	
	rotation_degrees.x = clamp(rotation_degrees.x, clamp_amount_min, clamp_amount_max)
