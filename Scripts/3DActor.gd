extends CharacterBody3D
class_name Actor3D

#Como uso esto con la herencia???
@export var walk_speed: float
@export var sprint_speed: float

var sprinting : bool = false

func get_speed() -> float:
	if sprinting:
		return sprint_speed
	return walk_speed

func _ready() -> void:
	pass


var direction : Vector3
func _physics_process(delta: float) -> void:
	_set_direction()		
	if  is_on_floor():
		if direction:
			velocity.x = direction.x * get_speed()
			velocity.z = direction.z * get_speed()
		else:
			velocity.x = lerp(velocity.x, direction.x * get_speed(), delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * get_speed(), delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * get_speed(), delta * 1.0)
		velocity.z = lerp(velocity.z, direction.z * get_speed(), delta * 1.0)
		velocity += get_gravity() * delta
	move_and_slide()

func _set_direction() -> void:
	pass
