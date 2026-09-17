extends CharacterBody2D

#Como carajos almaceno los AnimatedSprites que uso en 2DPlayer???
var SPEED
var DIRECTION
var JUMP_VELOCITY = 0

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	pass
	#Como mierdo meto las funciones heredadas de abajo?
	move_and_slide()
