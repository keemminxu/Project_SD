extends Area2D

var speed = 150.0
var target_position: Vector2
var player: Node2D

signal enemy_hit_player

func _ready():
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		queue_free()
		return
	
	# Connect to the game manager for collision detection
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		enemy_hit_player.connect(game_manager._on_enemy_hit_player)

func _physics_process(delta):
	if player == null:
		queue_free()
		return
	
	# Move towards player
	var direction = (player.global_position - global_position).normalized()
	global_position += direction * speed * delta
	
	# Remove if too far from screen center
	if global_position.distance_to(Vector2(640, 360)) > 1000:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		enemy_hit_player.emit()
		queue_free()
