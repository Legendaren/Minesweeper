extends Node
class_name CellComponent


var is_revealed := false
var is_flagged := false
var neighbor_mine_count := 0
var cell_state := Enums.CellState.EMPTY
var pos: Vector3i

func _init(cell_pos: Vector3i) -> void:
	self.pos = cell_pos


func select():
	#print("Cell selected")
	#print("Cell neighbor mines: ", neighbor_mine_count)
	#print("Cell has state ", Enums.CellState.keys()[cell_state])
	reveal()
	EventBus.cell_revealed.emit(self)

func reveal():
	is_revealed = true

func flag():
	if is_revealed:
		return
	is_flagged = not is_flagged
