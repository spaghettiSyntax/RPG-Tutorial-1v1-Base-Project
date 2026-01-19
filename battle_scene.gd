extends Control

# IMPORTANT: Check your scene tree! Names must match!
@onready var enemy_texture = $MainLayout/BattleArea/EnemySide/VBoxContainer/TextureRect
@onready var player_health_bar = $MainLayout/BattleArea/PlayerSide/VBoxContainer/PlayerHealthBar
@onready var enemy_health_bar = $MainLayout/BattleArea/EnemySide/VBoxContainer/EnemyHealthBar
@onready var text_label = $MainLayout/PanelContainer/Label
@onready var attack_button = $MainLayout/AttackButton
@onready var run_button = $MainLayout/RunButton

var current_enemy_health : int = 0
var enemy_damage : int = 0
var player : CharacterBody2D # Look, a slot to hold the real player!

func initialize(enemy_data: EnemyData, player_ref: CharacterBody2D):
	player = player_ref # Store the reference
	current_enemy_health = enemy_data.health
	enemy_damage = enemy_data.damage # Remember how hard this monster hits
	
	# Setup Health Bars
	enemy_health_bar.max_value = enemy_data.health
	enemy_health_bar.value = current_enemy_health
	
	player_health_bar.max_value = player.max_health
	player_health_bar.value = player.current_health # Use REAL health
	
	# Setup Texture and Text
	enemy_texture.texture = enemy_data.texture
	text_label.text = "A wild " + enemy_data.name + " appears!"

func _on_run_button_pressed():
	# 1. Unpause the game (Essential!)
	get_tree().paused = false
	
	# 2. Destroy this battle scene instance
	queue_free()

func _on_attack_button_pressed():
	# 1. Lock buttons so we can't spam
	attack_button.disabled = true
	run_button.disabled = true
	
	# 2. Deal fake damage (we'll add player stats later)
	var rng = RandomNumberGenerator.new()
	var current_attack_damage = rng.randi_range(10, 15)
	current_enemy_health -= current_attack_damage
	enemy_health_bar.value = current_enemy_health
	text_label.text = "You hit the monster for " + str(current_attack_damage) + " damage!"
	
	# 3. THE MAGIC WORD: Wait 1 second
	await get_tree().create_timer(1.0).timeout
	
	# 4. Check results
	if current_enemy_health <= 0:
		win_battle()
	else:
		enemy_turn()
		
func enemy_turn():
	text_label.text = "The monster attacks!"
	await get_tree().create_timer(1.0).timeout
	
	# 1. Modify the REAL player script directly
	player.current_health -= enemy_damage
	player_health_bar.value = player.current_health
	
	text_label.text = "You took " + str(enemy_damage) + " damage!"
	await get_tree().create_timer(1.0).timeout
	
	# 2. Check for Game Over
	if player.current_health <= 0:
		text_label.text = "You were defeated..."
		await get_tree().create_timer(2.0).timeout
		
		# Restart the game
		get_tree().paused = false
		get_tree().reload_current_scene()
	else:
		# 3. Give control back
		attack_button.disabled = false
		run_button.disabled = false
		text_label.text = "What will you do?"
	
func win_battle():
	text_label.text = "You won!"
	await get_tree().create_timer(1.0).timeout
	
	get_tree().paused = false
	queue_free()
