extends Actor3D
class_name Player3D

const MOUSE_SENSITIVITY = 0.002

@export var jump_velocity : float

@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready() -> void:
	Globales.player_3d = self
	_set_mouse_mode()

func _set_direction() -> void:
	sprinting = Input.is_action_pressed("ia_sprint")
	var input_dir := Input.get_vector("ia_left", "ia_right", "ia_up", "ia_down")
	direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if Input.is_action_just_pressed("ia_jump") and is_on_floor():
		velocity.y = jump_velocity

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		print(event)
		print(camera)
		head.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _set_mouse_mode() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
