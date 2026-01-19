extends CharacterBody2D

@export var move_speed : float = 100.0
@export var ground_layer : TileMapLayer
@export var encounter_rate : float = 0.1 # 10% chance
# To hold our list of monsters. 
# An Array if you’re not familiar is just basically a box to throw all our monsters in.
@export var monsters : Array[EnemyData]
@export var max_health : int = 100

var current_health : int
var distance_traveled : float = 0.0
const ENCOUNTER_THRESHOLD : float = 50.0 # Check every 50 pixels

func _ready():
	# Initialize health when the game starts
	current_health = max_health

func _physics_process(delta):

	# We use the custom actions we just defined!
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	velocity = input_direction * move_speed
	
	move_and_slide()
	
	# 1. Track distance
	if velocity.length() > 0:
		# We MUST use delta here.
		distance_traveled += velocity.length() * delta
		
	if distance_traveled > ENCOUNTER_THRESHOLD: # Reset the distance traveled
		distance_traveled = 0.0
		check_for_encounter()
		
func check_for_encounter():
	# 2. Get the tile we are standing on
	var map_pos = ground_layer.local_to_map(global_position)
	
	var tile_data = ground_layer.get_cell_tile_data(map_pos)
	
	# 3. Check the "Invisible Paint"
	if tile_data and tile_data.get_custom_data("is_encounter_zone"): # Show back where we just created this
		print("Stepped on Monster Stones!")
		
		# 4. Roll the Dice
		if randf() < encounter_rate:
			print("BATTLE STARTED!")
			# Pick a random monster
			var random_monster = monsters.pick_random()
			print("A wild " + random_monster.name + " appears!")
			SignalBus.encounter_started.emit(random_monster)
