extends Node2D

@export var enemy_scene: PackedScene
@onready var spawn_timer: Timer = $SpawnTimer
@onready var ui: Control = $UI
@onready var score_label: Label = $UI/ScoreLabel
@onready var game_over_ui: Control = $UI/GameOverUI
@onready var final_score_label: Label = $UI/GameOverUI/VBoxContainer/FinalScoreLabel
@onready var restart_button: Button = $UI/GameOverUI/VBoxContainer/RestartButton

var game_started = false
var game_over = false
var survival_time = 0.0
var spawn_rate = 2.0  # Start spawning every 2 seconds
var min_spawn_rate = 0.3  # Minimum time between spawns
var spawn_rate_decrease = 0.02  # How much to decrease spawn rate each second

var screen_size: Vector2
var spawn_distance = 800.0

func _ready():
	add_to_group("game_manager")
	screen_size = get_viewport().get_visible_rect().size
	
	# Load enemy scene
	enemy_scene = preload("res://scenes/Enemy.tscn")
	
	# Setup timer
	spawn_timer.wait_time = spawn_rate
	spawn_timer.timeout.connect(_spawn_enemy)
	spawn_timer.start()
	
	# Setup UI
	game_over_ui.visible = false
	restart_button.pressed.connect(_restart_game)
	
	game_started = true

func _process(delta):
	if not game_started or game_over:
		return
	
	# Update survival time
	survival_time += delta
	
	# Update spawn rate (enemies spawn faster over time)
	spawn_rate = max(min_spawn_rate, spawn_rate - spawn_rate_decrease * delta)
	spawn_timer.wait_time = spawn_rate
	
	# Update score display
	score_label.text = "Score: " + str(int(survival_time))

func _spawn_enemy():
	if game_over:
		return
	
	var enemy = enemy_scene.instantiate()
	
	# Get random spawn position around screen edges
	var spawn_pos = _get_random_spawn_position()
	enemy.global_position = spawn_pos
	
	add_child(enemy)

func _get_random_spawn_position() -> Vector2:
	var center = Vector2(640, 360)
	var angle = randf() * 2 * PI
	return center + Vector2(cos(angle), sin(angle)) * spawn_distance

func _on_enemy_hit_player():
	if game_over:
		return
	
	game_over = true
	spawn_timer.stop()
	
	# Show game over UI
	final_score_label.text = "Final Score: " + str(int(survival_time))
	game_over_ui.visible = true
	
	# Pause the game
	get_tree().paused = true

func _restart_game():
	get_tree().paused = false
	get_tree().reload_current_scene()
