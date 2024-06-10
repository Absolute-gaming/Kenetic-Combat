extends RigidBody3D

@export var gravity : float
@export var speed : float = 10.0
@export var knockback_force : float  = 10.0

var force_direction

# Called when the node enters the scene tree for the first time.
func _ready():
	force_direction = -transform.basis.z
	gravity_scale = gravity
	apply_impulse(force_direction * speed)
	pass # Replace with function body.

var time_alive = 0
#TODO use a timer node instead. This just frees the projectile after a while
func _process(delta):
	if time_alive > 10:
		queue_free()
	time_alive += delta
