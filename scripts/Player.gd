extends CharacterBody2D

const SPEED = 300.0

func _ready():
	add_to_group("player")

func _physics_process(delta):
	var direction = Vector2.ZERO
	
	# Get input direction
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	
	# Normalize diagonal movement
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	
	# Move the player
	velocity = direction * SPEED
	move_and_slide()
