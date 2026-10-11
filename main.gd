extends Node2D

const TEXTURES = preload("uid://ct3k8dk66wlpy")
const SELECT = preload("uid://ba45dlh38xlg0")
const TELEPORT = preload("res://teleport.tscn")
@onready var animated_sprite_2d: AnimatedSprite2D = $other/holder/AnimatedSprite2D
@onready var animated_sprite_2d_2: AnimatedSprite2D = $other/holder/AnimatedSprite2D2
@onready var whisper: AudioStreamPlayer2D = $other/holder/whisper
@onready var audio_stream_player_2d_3: AudioStreamPlayer2D = $other/holder/AudioStreamPlayer2D3
@onready var crowtimer: Timer = $other/holder/crowtimer
@onready var crow: AudioStreamPlayer2D = $other/holder/crow
const BOARDSIZE = 8
const TILESIZE = 81
const YADJUST = 620
const XADJUST = 225
var boardstate = false
var turn = true
var possiblemoves = []
var selected : Vector2
var summoning = false
var possiblesummons = []
const BISHOPRED = preload("res://pieces/bishopred.png")
const BISHOPYELLOW = preload("res://pieces/bishopyellow.png")
const KINGRED = preload("res://pieces/kingred.png")
const KINGYELLOW = preload("res://pieces/kingyellow.png")
const KNIGHTRED = preload("res://pieces/knightred.png")
const KNIGHTYELLOW = preload("res://pieces/knightyellow.png")
const PAWNRED = preload("res://pieces/pawnred.png")
const PAWNYELLOW = preload("res://pieces/pawnyellow.png")
const QUEENRED = preload("res://pieces/queenred.png")
const QUEENYELLOW = preload("res://pieces/queenyellow.png")
const ROOKRED = preload("res://pieces/rookred.png")
const ROOKYELLOW = preload("res://pieces/rookyellow.png")
@onready var selectables: Node2D = $selectables
@onready var pieces: Node2D = $pieces
@onready var tpeffect: Node2D = $tpeffect
@onready var holder: Node2D = $other

var board : Array
func _ready():
	board.append([4,3,2,5,6,2,3,4])
	board.append([1,1,1,1,1,1,1,1])
	board.append([0,0,0,0,0,0,0,0,])
	board.append([0,0,0,0,0,0,0,0,])
	board.append([0,0,0,0,0,0,0,0,])
	board.append([0,0,0,0,0,0,0,0,])
	board.append([-1,-1,-1,-1,-1,-1,-1,-1])
	board.append([-4,-3,-2,-5,-6,-2,-3,-4])
	holder.global_position.x = holder.global_position.x - TILESIZE
	display()
	
func display():
	
	for x in pieces.get_children():
		x.queue_free()
	for x in selectables.get_children():
		x.queue_free()
	for x in BOARDSIZE:
		for y in BOARDSIZE:
			var instance = TEXTURES.instantiate()
			pieces.add_child(instance)
			instance.global_position = Vector2(x * TILESIZE + (TILESIZE / 2)+XADJUST-TILESIZE+(TILESIZE), -y * TILESIZE - (TILESIZE / 2)+YADJUST)
			
			match board[y][x]:
				-6 : instance.texture = KINGRED
				-5: instance.texture = QUEENRED
				-4: instance.texture = ROOKRED
				-3: instance.texture = KNIGHTRED
				-2: instance.texture = BISHOPRED
				-1: instance.texture = PAWNRED
				0: instance.texture = null
				6: instance.texture = KINGYELLOW
				5: instance.texture = QUEENYELLOW
				4: instance.texture = ROOKYELLOW
				3: instance.texture = KNIGHTYELLOW
				2: instance.texture = BISHOPYELLOW
				1: instance.texture = PAWNYELLOW

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			if mouseoutofbounds():
				return
			else:
				var mousex = snapped(get_global_mouse_position().x - XADJUST , 0) / 88
				var mousey = abs(snapped(get_global_mouse_position().y - YADJUST , 0)) / 76
				if boardstate == false && (turn == true && (board[mousey][mousex] > 0 )):
					selected = Vector2(mousex,mousey)
					getoptions()
					displaypossibilities()
					boardstate = true
					return
				if boardstate == false && (turn == false && (board[mousey][mousex] < 0)):
					selected = Vector2(mousex,mousey)
					getoptions()
					displaypossibilities()
					boardstate = true
					return
				else:
					if boardstate == true:
						if summoning == true:
							summon(mousex,mousey)
							return
						move(mousex,mousey)
	if event is InputEventMouseButton && event.is_pressed():
		if event.button_index == MOUSE_BUTTON_MASK_RIGHT || KEY_SPACE:
			boardstate = false
			summoning = false
			possiblesummons = []
			display()
func getoptions():
	possiblemoves = getpossibilities()
	if possiblemoves == []:
		print(possiblemoves)
		boardstate = false
		return

func getpossibilities():
	var moves = []
	match abs(board[selected.y][selected.x]):
		1: moves = pawnmoves()
		2: moves = bishopmoves()
		3: moves = knightmoves()
		4: moves = rookmoves()
		5: moves = queenmoves()
		6: moves = kingmoves()
	return moves
	

func displaypossibilities():
	for x in possiblemoves:
		var instance = SELECT.instantiate()
		selectables.add_child(instance)
		instance.global_position = Vector2(x.x * TILESIZE +XADJUST-10+(TILESIZE), -x.y * TILESIZE +YADJUST-3)

func mouseoutofbounds():
	if get_global_mouse_position().x < 255 || get_global_mouse_position().x > 903:
		return true
	else:
		return false

func isvalid(checked : Vector2):
	if checked.x >= 0 && checked.x < BOARDSIZE && checked.y >= 0 && checked.y <BOARDSIZE:
		return true
	else:
		return false


func isempty(checked : Vector2):
	if board[checked.y][checked.x] == 0:
		return true
	else:
		return false

func isotherside(checked : Vector2):
	if turn == true && board[checked.y][checked.x] < 0 || turn == false && board[checked.y][checked.x] > 0:
		return true
		
	else:
		return false
		
func move(x,y):
	print(possiblemoves)
	for z in possiblemoves:
		if z.x == x && z.y == y:
			teleportalt()
			var instance = TELEPORT.instantiate()
			tpeffect.add_child(instance)
			instance.global_position = Vector2(z.x * TILESIZE +XADJUST-10+(TILESIZE), -z.y * TILESIZE +YADJUST-3)
			if board [y][x] != 0:
				audio_stream_player_2d_3.play()
			board [y][x] = board [selected.y] [selected.x]
			board [selected.y] [selected.x] = 0
			if turn == true:
				turn = false
				animated_sprite_2d.frame = 0
				animated_sprite_2d_2.play("default")
			else:
				turn = true
				animated_sprite_2d_2.frame = 0
				animated_sprite_2d.play("default")
			display()
			boardstate = false
			whisper.play()
			break

func teleportalt():
	var instance = TELEPORT.instantiate()
	tpeffect.add_child(instance)
	instance.global_position = Vector2(selected.x * TILESIZE +XADJUST-10+(TILESIZE), -selected.y * TILESIZE +YADJUST-3)

#and now, the mother of all wastes of time...

func rookmoves():
	var moves = []
	var bearings = [Vector2(0,1),Vector2(1,0),Vector2(0,-1),Vector2(-1,0)]
	for z in bearings:
		print (z)
		var snek = selected
		snek += z
		while isvalid(snek) == true:
			if isempty(snek) == true:
				moves.append(snek)
			else:
				if isotherside(snek) == true:
					moves.append(snek)
					break
				else:
					break
			snek += z
	return moves
	
func bishopmoves():
	var moves = []
	var bearings = [Vector2(1,1),Vector2(-1,1),Vector2(1,-1),Vector2(-1,-1)]
	for z in bearings:
		print (z)
		var snek = selected
		snek += z
		while isvalid(snek) == true:
			if isempty(snek) == true:
				moves.append(snek)
			else:
				if isotherside(snek) == true:
					moves.append(snek)
					break
				else:
					break
			snek += z
	return moves
	
func queenmoves():
	var moves = []
	var bearings = [Vector2(1,1),Vector2(-1,1),Vector2(1,-1),Vector2(-1,-1),Vector2(0,1),Vector2(1,0),Vector2(0,-1),Vector2(-1,0)]
	for z in bearings:
		print (z)
		var snek = selected
		snek += z
		while isvalid(snek) == true:
			if isempty(snek) == true:
				moves.append(snek)
			else:
				if isotherside(snek) == true:
					moves.append(snek)
					break
				else:
					break
			snek += z
	return moves
	
func kingmoves():
	var moves = []
	var bearings = [Vector2(1,1),Vector2(-1,1),Vector2(1,-1),Vector2(-1,-1),Vector2(0,1),Vector2(1,0),Vector2(0,-1),Vector2(-1,0)]
	for z in bearings:
		print (z)
		var snek = selected
		snek += z
		if isvalid(snek) == true:
			if isempty(snek) == true:
				moves.append(snek)
			else:
				if isotherside(snek) == true:
					moves.append(snek)
	return moves
	
func knightmoves():
	var moves = []
	var bearings = [Vector2(2,1),Vector2(2,-1),Vector2(-2,-1),Vector2(-2,1),Vector2(-1,2),Vector2(1,2),Vector2(1,-2),Vector2(-1,-2)]
	for z in bearings:
		print (z)
		var snek = selected
		snek += z
		if isvalid(snek) == true:
			if isempty(snek) == true:
				moves.append(snek)
			else:
				if isotherside(snek) == true:
					moves.append(snek)
	return moves
	
func pawnmoves():
	var moves = []
	var bearings : Vector2
	var start = false
	if turn == true:
		bearings = Vector2(0,1)
	else:
		bearings = Vector2(0,-1)
		
	if turn == true && selected.y == 1 || turn == false && selected.y == 6:
		start = true
	else:
		start = false
	var snek = selected + bearings
	if isempty(snek) == true:
		moves.append(snek)
	
	snek = selected + Vector2(1,bearings.y)
	if isvalid(snek) == true:
		if isotherside(snek) == true:
			moves.append(snek)
	snek = selected + Vector2(-1,bearings.y)
	if isvalid(snek) == true:
		if isotherside(snek) == true:
			moves.append(snek)
		
	snek = selected + bearings * 2
	if start == true && isempty(snek) && isempty(selected + bearings):
		moves.append(snek)
	return moves
	#I officially hate pawns.
	
	
func _on_crowtimer_timeout() -> void:
	crow.play()
	crowtimer.wait_time = randf_range(15,45)


func on_summon_white() -> void:
	if turn == false:
		return
	var moves = []
	var bearings = [Vector2(1,1),Vector2(-1,1),Vector2(1,-1),Vector2(-1,-1),Vector2(0,1),Vector2(1,0),Vector2(0,-1),Vector2(-1,0)]
	for z in bearings:
		for b in findbishops():
			var home = Vector2(b[0],b[1])
			var snek = home
			snek += z
			if isvalid(snek) == true:
				if isempty(snek) == true:
					moves.append(snek)
				else:
					if isotherside(snek) == true:
						moves.append(snek)
	possiblesummons = moves
	#tfw when you already have the code you need
	if possiblesummons == []:
		print("possiblesummonsempty")
		boardstate = false
		return
	for x in possiblesummons:
		var instance = SELECT.instantiate()
		selectables.add_child(instance)
		instance.global_position = Vector2(x.x * TILESIZE +XADJUST-10+TILESIZE, -x.y * TILESIZE +YADJUST-3)
		boardstate = true
		summoning = true

func findbishops():
	var output : Array
	for y in BOARDSIZE:
		for x in BOARDSIZE:
			if board[x][y] == 2:
				output.append([y,x])
	return output

func summon(x, y):
	for z in possiblesummons:
		if z.x == x && z.y == y:
			var instance = TELEPORT.instantiate()
			tpeffect.add_child(instance)
			instance.global_position = Vector2(z.x * TILESIZE +XADJUST-10+TILESIZE, -z.y * TILESIZE +YADJUST-3)
			if board [y][x] != 0:
				audio_stream_player_2d_3.play()
			if turn == true:
				board [y][x] = 1
			else:
				board [y][x] = -1
			if turn == true:
				turn = false
				animated_sprite_2d.frame = 0
				animated_sprite_2d_2.play("default")
			else:
				turn = true
				animated_sprite_2d_2.frame = 0
				animated_sprite_2d.play("default")
			display()
			boardstate = false
			summoning = false
			whisper.play()
			break
			



func onblacksummon() -> void:
	if turn == true:
		return
	var moves = []
	var bearings = [Vector2(1,1),Vector2(-1,1),Vector2(1,-1),Vector2(-1,-1),Vector2(0,1),Vector2(1,0),Vector2(0,-1),Vector2(-1,0)]
	for z in bearings:
		for b in findbishopsred():
			var home = Vector2(b[0],b[1])
			var snek = home
			snek += z
			if isvalid(snek) == true:
				if isempty(snek) == true:
					moves.append(snek)
				else:
					if isotherside(snek) == true:
						moves.append(snek)
	possiblesummons = moves
	#tfw when you already have the code you need
	if possiblesummons == []:
		print("possiblesummonsempty")
		boardstate = false
		return
	for x in possiblesummons:
		var instance = SELECT.instantiate()
		selectables.add_child(instance)
		instance.global_position = Vector2(x.x * TILESIZE +XADJUST-10+TILESIZE, -x.y * TILESIZE +YADJUST-3)
		boardstate = true
		summoning = true


func findbishopsred():
	var output : Array
	for y in BOARDSIZE:
		for x in BOARDSIZE:
			if board[x][y] == -2:
				output.append([y,x])
	return output
