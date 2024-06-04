extends CharacterBody3D

#Player Nodes
@onready var head = $Head
@onready var camera_3d = $Head/Camera3D
@onready var player_collider = $"Player Collider"
@onready var crouching_collider = $"Crouching Collider"
@onready var on_floor_cast = $OnFloorCast
@onready var head_crouch_cast = $HeadCrouchCast
@onready var shoot_cd = $ShootCD

@onready var tip = $Head/Weapon/Tip
@onready var weapon_ray_cast_3d = $Head/Weapon/Tip/WeaponRayCast3D
var projectile = load("res://Scenes/projectile.tscn")
var instance


#Speed Vars
var current_speed = 5.0
@export var walking_speed = 5.0
@export var sprinting_speed = 8.0
@export var crouching_speed = 3.0

#Movement Vars
const jump_velocity = 4.5
var crouching_depth = 0.25
var lerp_speed = 20

#Input Vars
var direction = Vector3.ZERO
var mouse_sens = 0.2

#Combat Vars
var can_shoot = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	#Lock mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#Multiplayer cam handling
	camera_3d.current = is_multiplayer_authority()

func _input(event):
	#Handle side to side look
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89.9), deg_to_rad(89.9))
	
	#Handle Combat
	

func _physics_process(delta):
	if !is_multiplayer_authority():
		return
	
	#Handle Movement States
	if Input.is_action_pressed("Crouch"):
		current_speed = crouching_speed
		head.position.y = lerp(head.position.y, 0.5 - crouching_depth, delta * lerp_speed)
		player_collider.disabled = true
		crouching_collider.disabled = false
	elif !head_crouch_cast.is_colliding():
		head.position.y = lerp(head.position.y, 0.5 + crouching_depth, delta * lerp_speed)
		crouching_collider.disabled = true
		player_collider.disabled = false
		

	if Input.is_action_pressed("Sprint"):
		current_speed = sprinting_speed
	else:
		current_speed = walking_speed
	
	# Add the gravity.
	if !on_floor_cast.is_colliding():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and on_floor_cast.is_colliding():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta * lerp_speed)
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()


func _on_shoot_cd_timeout():
	can_shoot = true
	print("Can Shoot")
