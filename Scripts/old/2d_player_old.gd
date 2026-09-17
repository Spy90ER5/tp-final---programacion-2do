extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = 0.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if velocity.y < 0:
			$AnimatedSprite2D.play("Jump")
		else:
			$AnimatedSprite2D.play("Fall")

	# Handle jump.
	if Input.is_action_just_pressed("ia_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ia_left", "ia_right")
	
	if direction > 0:
		$AnimatedSprite2D.scale.x = 1
	elif direction < 0:
		$AnimatedSprite2D.scale.x = -1
	
	if direction:
		velocity.x = direction * SPEED
		if is_on_floor():
			$AnimatedSprite2D.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			$AnimatedSprite2D.play("Idle")

	move_and_slide()
