class_name CellComponent
extends Control

const EMPTY_REVEALED_REGION := Rect2(Vector2(4, 4), Vector2(16, 16))
const ONE_REGION := Rect2(Vector2(20, 4), Vector2(16, 16))
const TWO_REGION := Rect2(Vector2(36, 4), Vector2(16, 16))
const THREE_REGION := Rect2(Vector2(52, 4), Vector2(16, 16))
const FOUR_REGION := Rect2(Vector2(4, 20), Vector2(16, 16))
const FIVE_REGION := Rect2(Vector2(20, 20), Vector2(16, 16))
const SIX_REGION := Rect2(Vector2(36, 20), Vector2(16, 16))
const SEVEN_REGION := Rect2(Vector2(52, 20), Vector2(16, 16))
const EIGHT_REGION := Rect2(Vector2(68, 20), Vector2(16, 16))
const EMPTY_HIDDEN_REGION := Rect2(Vector2(20, 36), Vector2(16, 16))
const FLAG_REGION := Rect2(Vector2(36, 36), Vector2(16, 16))
const MINE_REGION := Rect2(Vector2(4, 52), Vector2(16, 16))

const neighbor_mines_to_region := {
	1: ONE_REGION,
	2: TWO_REGION,
	3: THREE_REGION,
	4: FOUR_REGION,
	5: FIVE_REGION,
	6: SIX_REGION,
	7: SEVEN_REGION,
	8: EIGHT_REGION
}

@onready var sprite: Sprite2D = $Area2D/Sprite2D

var is_revealed := false
var is_flagged := false
var is_mine_revealed := false
var neighbor_mine_count: int = 0
var cell_state: Enums.CellState = Enums.CellState.EMPTY
var actual_cell_region : Rect2 = EMPTY_HIDDEN_REGION
	
func _ready():
	EventBus.mine_revealed.connect(on_mine_reveal)
	sprite.region_rect = EMPTY_HIDDEN_REGION
	
func init_cell():
	if cell_state == Enums.CellState.MINE:
		actual_cell_region = MINE_REGION	
	elif neighbor_mine_count == 0:
		actual_cell_region = EMPTY_REVEALED_REGION
	else:
		print("Has neighbor mines")
		actual_cell_region = region_from_neighbor_mine_count(neighbor_mine_count)

func set_as_mine():
	cell_state = Enums.CellState.MINE
	actual_cell_region = MINE_REGION

func region_from_neighbor_mine_count(neighbor_mines: int):
	assert(neighbor_mines_to_region.has(neighbor_mines))
	var region = neighbor_mines_to_region.get(neighbor_mines)
	print("Region: ", region)
	return neighbor_mines_to_region.get(neighbor_mines)

func click_cell():
	print("Cell selected")
	print("Cell neighbor mines: ", neighbor_mine_count)
	print("Cell has state ", Enums.CellState.keys()[cell_state])
	reveal_cell()
	if cell_state == Enums.CellState.MINE:
		EventBus.mine_revealed.emit(self)
	elif cell_state == Enums.CellState.EMPTY:
		EventBus.empty_cell_revealed.emit(self)

func reveal_cell():
	sprite.region_rect = actual_cell_region
	is_revealed = true
	EventBus.cell_left_click.emit(self)

func flag_cell():
	if is_revealed:
		return
	
	if is_flagged:
		sprite.region_rect = EMPTY_HIDDEN_REGION
	else:
		sprite.region_rect = FLAG_REGION
	is_flagged = not is_flagged
	print("Cell flagged")
	print("Flagged cell has state ", Enums.CellState.keys()[cell_state])
	EventBus.cell_right_click.emit(self)


func on_mine_reveal(_cell: CellComponent):
	is_mine_revealed = true

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if is_mine_revealed:
		return
		
	if event.is_action_pressed("select_cell"):
		click_cell()
	elif event.is_action_pressed("flag_cell"):
		flag_cell()
