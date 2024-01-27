class_name CellComponent
extends Node

var is_revealed := false
var is_flagged := false
var is_mine_revealed := false
var neighbor_mine_count: int = 0
var cell_state: Enums.CellState = Enums.CellState.EMPTY
var pos: Vector3i

func _init(pos: Vector3i) -> void:
	self.pos = pos

func set_as_mine():
	cell_state = Enums.CellState.MINE

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
	is_revealed = true

func flag_cell():
	if is_revealed:
		return
	
	is_flagged = not is_flagged


func on_mine_reveal(_cell: CellComponent):
	is_mine_revealed = true

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if is_mine_revealed:
		return
		
	if event.is_action_pressed("select_cell"):
		click_cell()
	elif event.is_action_pressed("flag_cell"):
		flag_cell()
