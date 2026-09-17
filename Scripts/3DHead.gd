extends Node3D
class_name PlayerHead

const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

func _ready() -> void:
	initial_position = position

func _physics_process(delta: float) -> void:
	_headbob_physics(delta)

func _headbob_physics(delta: float) -> void:
	var velocity = Globales.player_3d.velocity
	t_bob += delta * velocity.length() * float(Globales.player_3d.is_on_floor())
	transform.origin = _headbob(t_bob)

var initial_position : Vector3
#Me da cuanto se tiene que mover la "cabeza" sobre el eje y y x 
func _headbob(time) -> Vector3:
	var pos = initial_position
	pos.y += sin(time * BOB_FREQ) * BOB_AMP
	pos.x += cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos


#Para que esto funcione. Solo te falta setear la nueva cabeza y camara
