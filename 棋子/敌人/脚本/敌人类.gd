@tool
extends 棋子类
class_name 敌人类

func _ready() -> void:
	super()
	add_to_group("敌人阵营")
