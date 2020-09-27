extends KinematicBody
class_name Player

export var mouse_sensitivity := 0.5
export var move_accel := 3.0
export var max_speed := 10.0
export var jump_force := 20.0
export var gravity := 60.0
export var ignore_rotation := false

onready var camera := $Camera

var drag := 0.0
var pressed_jump := false
var move_vec := Vector3.ZERO
var velocity := Vector3.ZERO
var snap_vec := Vector3.ZERO
var frozen = false


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	drag = move_accel / max_speed
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		
	move_vec = Vector3()
	if Input.is_action_pressed("move_forward"):
		move_vec += Vector3.FORWARD
	if Input.is_action_pressed("move_backward"):
		move_vec += Vector3.BACK
	if Input.is_action_pressed("move_left"):
		move_vec += Vector3.LEFT
	if Input.is_action_pressed("move_right"):
		move_vec += Vector3.RIGHT
		
	if Input.is_action_just_pressed("jump"):
		pressed_jump = true

func _physics_process(delta: float) -> void:		
	var current_move_vec = move_vec
	if not ignore_rotation:
		current_move_vec = current_move_vec.rotated(Vector3.UP, rotation.y)
	
	velocity += move_accel * current_move_vec - velocity * Vector3(drag, 0, drag) + gravity * Vector3.DOWN * delta
	velocity = move_and_slide_with_snap(velocity, snap_vec, Vector3.UP)
	
	var grounded = is_on_floor()
	if grounded:
		velocity.y = -0.01
		
	if grounded and pressed_jump:
		velocity.y = jump_force
		snap_vec = Vector3.ZERO
	else:
		snap_vec = Vector3.DOWN
		
	pressed_jump = false
	
	emit_signal("movement_info", velocity, grounded)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_degrees.y -= mouse_sensitivity * event.relative.x
		camera.rotation_degrees.x -= mouse_sensitivity * event.relative.y
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
		
