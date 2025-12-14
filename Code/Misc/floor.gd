extends TileMapLayer

@export var alternative_tile = [0, Vector2(0,0), 1]

#Sets the tiles around walls and obsticles to have bigger weights, discouraging agents from sliding
#against them
func set_floor_weights():
	for obstacle in get_tree().get_nodes_in_group("Obstacle"):
		if obstacle is TileMapLayer:
			for tile in obstacle.get_used_cells():
				for surrounding_tile in get_surrounding_cells(tile):
					if get_cell_tile_data(surrounding_tile) != null:
						set_cell(surrounding_tile, alternative_tile[0], alternative_tile[1], alternative_tile[2])
