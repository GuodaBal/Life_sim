extends TileMapLayer

func set_floor_weights():
	for obstacle in get_tree().get_nodes_in_group("Obstacle"):
		if obstacle is TileMapLayer:
			for tile in obstacle.get_used_cells():
				for surrounding_tile in get_surrounding_cells(tile):
					if get_cell_tile_data(surrounding_tile) != null:
						set_cell(surrounding_tile, 0, Vector2(0,0), 1)
