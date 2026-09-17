extends Camera3D
class_name PlayerCamera

const FOV_BASE = 65.0
const FOV_CHANGE = 1.5

func _physics_process(delta: float) -> void:
	_fov_physics(delta)

func _fov_physics(delta: float) -> void:
	var velocity = Globales.player_3d.velocity
	var velocity_clamped = clamp(velocity.length(), 0.5, Globales.player_3d.get_speed() * 2)
	var target_fov = FOV_BASE + FOV_CHANGE * velocity_clamped
	fov = lerp(fov, target_fov, delta * 8.0)
