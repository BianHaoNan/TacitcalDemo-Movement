class_name 范围类
extends TileMapLayer

func 绘制移动范围(移动范围格子集: Array) -> void:
	clear()
	for 格子坐标 in 移动范围格子集:
		# 在“格子坐标”位置，将tile set中源为0，图集坐标Vector2i(0, 0)图块绘制出来
		set_cell(格子坐标, 0, Vector2i(0, 0))

func 绘制攻击范围(攻击范围格子集: Array) -> void:
	for 格子坐标 in 攻击范围格子集:
		# 在“格子坐标”位置，将tile set中源为0，图集坐标Vector2i(0, 0)图块绘制出来
		set_cell(格子坐标, 1, Vector2i(0, 0))
