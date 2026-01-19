extends Node

# This signal send the specific monster data (Resource) to the game
# We tell Godot to ignore the warning because the Player emits this, not the Bus!
@warning_ignore('unused_signal')
signal encounter_started(enemy_data)
