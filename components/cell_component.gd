extends Node
class_name CellComponent


var is_revealed := false
var is_flagged := false
var neighbor_mine_count := 0
var state := Enums.CellState.EMPTY
var pos: Vector3i

func _init(cell_pos: Vector3i) -> void:
	self.pos = cell_pos


func select():
	if is_flagged:
		return
	reveal()



func reveal():
	if is_revealed:
		return

	is_revealed = true
	EventBus.cell_revealed.emit(self)
	if state == Enums.CellState.MINE:
		EventBus.mine_revealed.emit(self)

func flag():
	if is_revealed:
		return
	is_flagged = not is_flagged
	EventBus.cell_flagged.emit(self)
