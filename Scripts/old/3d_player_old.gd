extends CharacterBody3D



# --- Linterna / dínamo ---
@export var battery_max: float = 100.0
@export var battery_drain_rate: float = 8.0      # consumo por segundo con RMB
@export var dynamo_charge_rate: float = 22.0     # carga por segundo con E
@export var light_energy_max: float = 3.0
 
var battery_level: float = 100.0
var is_charging: bool = false
 
@onready var flashlight: SpotLight3D = $Head/Camera3D/SpotLight3D
 
# --- Guía / señal ---
@export var target_goal_pos: Vector3 = Vector3.ZERO   # centro del laberinto de la capa
 
@onready var signal_ui: Control     = $UI/SignalGuide     # contenedor, arranca invisible
@onready var signal_label: Label    = $UI/SignalGuide/Labe1  # el valor en metros
@onready var signal_arrow: Control  = $UI/SignalGuide/Arrow  # flechita (pivot centrado)

#va al Actor3D
const WALK_SPEED = 2.4
const SPRINT_SPEED = 8.0

#Eliminamos la funcion salto. Para que el jugador se sienta mas pesado!
const JUMP_VELOCITY = 0.0

var speed
const MOUSE_SENSITIVITY = 0.002

#bob variables. Pasan a Head
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

#fov variables. Pasan a la Camara
const FOV_BASE = 65.0
const FOV_CHANGE = 1.5


@onready var head = $Head
@onready var camera = $Head/Camera3D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	_recharge_dynamo(delta)     # primero: define is_charging
	_flashlight(delta)
	_signal_distance(delta)
	if Input.is_action_pressed("ia_sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
		# manivelar y usar la guía te frenan (te dejan vulnerable)
	if is_charging:
		speed *= 0.35
	elif Input.is_action_pressed("ia_signal"):
		speed *= 0.6
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump. xxx
	if Input.is_action_just_pressed("ia_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle Sprint.
	if Input.is_action_pressed("ia_sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	var input_dir := Input.get_vector("ia_left", "ia_right", "ia_up", "ia_down")
	var direction: Vector3 = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if  is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 1.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 1.0)
	
	#Headbob_physics
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	#FOV_physics
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = FOV_BASE + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func _flashlight(delta: float) -> void:
	# No podés alumbrar y manivelar al mismo tiempo (como en Amnesia).
	var wants_light: bool = Input.is_action_pressed("ia_flashlight") and not is_charging
	var is_on: bool = wants_light and battery_level > 0.0
 
	if is_on:
		battery_level = max(battery_level - battery_drain_rate * delta, 0.0)
 
	# La intensidad cae con la batería, y cae más rápido en el tramo final.
	var t: float = battery_level / battery_max
	var target_energy: float = light_energy_max * pow(t, 1.8) if is_on else 0.0
 
	# Agonía: cuando queda poca batería, parpadea.
	if is_on and t < 0.15:
		target_energy *= 0.55 + 0.45 * sin(Time.get_ticks_msec() * 0.02)
 
	flashlight.light_energy = lerp(flashlight.light_energy, target_energy, delta * 8.0)
	flashlight.visible = flashlight.light_energy > 0.01
 
func _recharge_dynamo(delta: float) -> void:
	# Mantener E para cargar. Ilimitado, pero lento y te deja a oscuras mientras lo hacés.
	is_charging = Input.is_action_pressed("ia_interact") and battery_level < battery_max
 
	if is_charging:
		battery_level = min(battery_level + dynamo_charge_rate * delta, battery_max)
 
func _signal_distance(delta: float) -> void:
	# Mantener LMB: sale la guía con la distancia al centro y una flecha que lo apunta.
	var active: bool = Input.is_action_pressed("ia_signal")
	signal_ui.visible = active
	if not active:
		return
 
	var to_target: Vector3 = target_goal_pos - global_position
	signal_label.text = "%.1f m" % to_target.length()
 
	# Flecha: ángulo entre hacia dónde mirás y dónde está el centro (sólo plano XZ).
	var flat: Vector3 = Vector3(to_target.x, 0.0, to_target.z)
	if flat.length() > 0.05:
		var forward: Vector3 = -head.global_transform.basis.z
		forward.y = 0.0
		var angle: float = forward.signed_angle_to(flat, Vector3.UP)
		signal_arrow.rotation = lerp_angle(signal_arrow.rotation, -angle, delta * 10.0)
