extends TileMapLayer

@export var floor : TileMapLayer

#func _ready() -> void:
	#set_floor_weights()

#func set_floor_weights():
	#for tile in get_used_cells():
		#for surrounding_tile in get_surrounding_cells(tile):
			#if floor.get_cell_tile_data(surrounding_tile) != null:
				#floor.set_cell(surrounding_tile, 1, Vector2(0,0), 1)
