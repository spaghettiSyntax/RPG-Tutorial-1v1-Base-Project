extends Node2D

# 1. The Blueprint: We want to spawn the Battle Scene, so we export a PackedScene variable.
@export var battle_scene : PackedScene

# 2. The Container: We need to know where to put it.
@onready var ui_layer = $UILayer

@onready var player = $Player

func _ready():
	# We connect the signal to a function we are about to write called 'start_battle'
	SignalBus.encounter_started.connect(start_battle)

func start_battle(enemy_data):
	# 1. Pause the game so the player can't move
	get_tree().paused = true
	
	# 2. Create the Battle Scene (Instantiate it)
	var battle_instance = battle_scene.instantiate()
	
	# 3. Add it to the screen (Inside the CanvasLayer)
	ui_layer.add_child(battle_instance)
	
	# 4. Pass the enemy and player data to the battle scene
	battle_instance.initialize(enemy_data, player)
