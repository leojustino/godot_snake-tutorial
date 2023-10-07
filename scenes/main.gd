extends Node2D

@export var snake_scene: PackedScene

#constants
const UP = Vector2(0, -1)
const DOWN = Vector2(0, 1)
const LEFT = Vector2(-1, 0)
const RIGHT = Vector2(1, 0)
const CELLS: int = 20
const CELL_SIZE: int = 50
const START_POS = Vector2(9, 9)

#game variables
var score: int
var game_started: bool = false
#food variables
var food_pos : Vector2
var regen_food : bool = true
#snake variables
var old_data: Array
var snake_data: Array
var snake: Array
#movement variables
var move_direction: Vector2
var can_move: bool

func update_score():
	$Hud.get_node("ScoreLabel").text = "Score: " + str(score)


func new_game():
	get_tree().paused = false
	get_tree().call_group('segments', 'queue_free')
	score = 0
	move_direction = UP
	can_move = true
	$GameOverMenu.hide()
	update_score()
	generate_snake()
	move_food()
	
func generate_snake():
	old_data.clear()
	snake_data.clear()
	snake.clear()
	for i in range(3):
		add_segment(START_POS + Vector2(0, i))
		
func add_segment(pos):
	snake_data.append(pos)
	var SnakeSegment = snake_scene.instantiate()
	SnakeSegment.position = (pos * CELL_SIZE) + Vector2(0, CELL_SIZE)
	add_child(SnakeSegment)
	snake.append(SnakeSegment)
	
func start_game():
	game_started = true
	$MoveTimer.start()
	
func set_move_direction(direction):
	move_direction = direction
	can_move = false
	if not game_started:
		start_game()
		
func move_snake():
	if can_move:
		if Input.is_action_just_pressed("move_down") and move_direction != UP:
			set_move_direction(DOWN)
		if Input.is_action_just_pressed("move_up") and move_direction != DOWN:
			set_move_direction(UP)
		if Input.is_action_just_pressed("move_left") and move_direction != RIGHT:
			set_move_direction(LEFT)
		if Input.is_action_just_pressed("move_right") and move_direction != LEFT:
			set_move_direction(RIGHT)
			
func check_out_of_bounds():
	if snake_data[0].x < 0 or snake_data[0].x > CELLS - 1 or snake_data[0].y < 0 or snake_data[0].y > CELLS - 1:
		end_game()
		
func check_self_eaten():
	for i in range(1, len(snake_data)):
		if snake_data[0] == snake_data[i]:
			end_game()
			
func check_food_eaten():
	#if snake eats the food, add a segment and move the food
	if snake_data[0] == food_pos:
		score += 1
		update_score()
		add_segment(old_data[-1])
		move_food()
		
func move_food():
	while regen_food:
		regen_food = false
		food_pos = Vector2(randi_range(0, CELLS - 1), randi_range(0, CELLS - 1))
		for i in snake_data:
			if food_pos == i:
				regen_food = true
	$Food.position = (food_pos * CELL_SIZE)+ Vector2(0, CELL_SIZE)
	regen_food = true
	
func end_game():
	$GameOverMenu.show()
	$MoveTimer.stop()
	game_started = false
	get_tree().paused = true

func _ready():
	new_game()
	
func _process(_delta):
	move_snake()
	
func _on_move_timer_timeout():
	#allow snake movement
	can_move = true
	#use the snake's previous position to move the segments
	old_data = [] + snake_data
	snake_data[0] += move_direction
	for i in range(len(snake_data)):
		#move all the segments along by one
		if i > 0:
			snake_data[i] = old_data[i-1]
		snake[i].position = (snake_data[i] * CELL_SIZE) + Vector2(0, CELL_SIZE)
	check_out_of_bounds()
	check_self_eaten()
	check_food_eaten()
	
func _on_game_over_menu_restart():
	new_game()
