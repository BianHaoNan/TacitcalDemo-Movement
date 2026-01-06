class_name 棋子管理员类
extends Node2D

const 天意四向诀 = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]

@export var _网格类: Resource = preload("res://自定义资源/网格类.tres")
## 棋子管理员节点下的阵营节点
@export var _阵营集: Array[Node2D]

## 存在单位的格子，格子坐标：格子内单位=》Vector2i：棋子类
var _棋子坐标字典 := {}
## 阵营成员：阵营名=》String：棋子类
var _棋子阵营字典 := {}
## 当前正在行动的棋子
var _行动棋子: 棋子类
## 格子内通过成本，只有地形，格子坐标：消耗值=》Vector2i:int
var _格子内移动力消耗值字典 := {}
# 备用
var _地形障碍位置: Array[Vector2i] = []

@onready var _地图类: 地图类 = $"../地图"
@onready var _范围类: 范围类 = $"../范围"
@onready var _路径类: 路径类 = $"../路径"

const 障碍地形消耗值 := 999

# 移动范围
## {"实际移动范围":_实际移动范围, "范围内友方棋子位置":_范围内友方棋子位置}
var _填充结果字典 := {}
var _实际移动范围 : Array[Vector2i] = []
var _绘制用移动范围 : Array[Vector2i] = []
# 移动范围
var _实际攻击范围: Array[Vector2i] = []
var _绘制用攻击范围: Array[Vector2i] = []

func _ready() -> void:
	_格子内移动力消耗值字典 = _地图类.格子坐标_扩散消耗值.duplicate()
	初始化()

func 初始化() -> void:
	_棋子坐标字典.clear()
	for i in _阵营集:
		for j in i.get_children():
			var 棋子:= j as 棋子类
			if not 棋子:
				continue
			_棋子坐标字典[棋子.棋子的格子坐标] = 棋子
			_棋子阵营字典[棋子] = str(i.name)
	#print_debug("_棋子坐标字典 : ", _棋子坐标字典)
	#print_debug("_棋子阵营字典 : ", _棋子阵营字典)

func _on_光标_点击事件信号(_格子坐标_: Variant) -> void:
	# 未选中单位，在鼠标点击位置cell执行选中
	if not _行动棋子:
		选中棋子(_格子坐标_)
	# 已选中单位，向鼠标点击位置cell执行移动
	elif _行动棋子.被选中:
		移动棋子(_路径类.范围内路径终点)

func _on_光标_鼠标移动信号(_格子坐标_: Variant) -> void:
	# 有选中的单位时，绘制路径
	if _行动棋子 and _行动棋子.被选中:
		_路径类.绘制移动路径(_行动棋子.棋子的格子坐标, _格子坐标_, _绘制用移动范围)

## 取消按键事件
func _unhandled_input(event: InputEvent) -> void:
	if _行动棋子 and event.is_action_pressed("ui_cancel"):
		取消选中棋子()
		重置被选单位()

func 选中棋子(_光标所在位置_: Vector2i) -> void:
	if not _棋子坐标字典.has(_光标所在位置_):
		return
	_行动棋子 = _棋子坐标字典[_光标所在位置_]
	_行动棋子.被选中 = true
	
	_填充结果字典 = 获取填充结果(_行动棋子.棋子的格子坐标, _行动棋子.移动范围)
	## 移动范围的副本
	var x:Dictionary = _填充结果字典.duplicate(true)
	_实际移动范围 = 获取实际移动范围(x.duplicate(true))
	_绘制用移动范围 = 获取绘制用移动范围(x.duplicate(true)) 
	#print_debug("实际移动范围 : ", _实际移动范围)
	#print_debug("绘制用移动范围 : ", _绘制用移动范围)
	_范围类.绘制移动范围(_绘制用移动范围)
	
	_实际攻击范围 = 获取完整攻击范围(_行动棋子, _实际移动范围.duplicate())
	var y:Array = _实际攻击范围.duplicate()
	_绘制用攻击范围 = 获取绘制用攻击范围(_绘制用移动范围.duplicate(), y.duplicate())
	_范围类.绘制攻击范围(_绘制用攻击范围.duplicate())
	#print_debug("实际攻击范围 ： ", _实际攻击范围)
	#print_debug("绘制用攻击范围 ： ", _绘制用攻击范围)
	
	_路径类.初始化AStarGrid2D(_绘制用移动范围, _地形障碍位置, _绘制用攻击范围)

func 移动棋子(_目标位置_: Vector2i) -> void:
	# 被占用、移动范围外的位置不能移入
	if 判断位置是否被占用(_目标位置_) or not _目标位置_ in _实际移动范围:
		return
	# 从_chessmen中移除被移动棋子
	_棋子坐标字典.erase(_行动棋子.棋子的格子坐标)
	# 使用被移动棋子的新位置，再次将被移动棋子加入到_chessmen中
	_棋子坐标字典[_目标位置_] = _行动棋子
	取消选中棋子()
	_行动棋子.沿路径移动(_路径类.范围内路径)
	# 等待移动完成信号
	await _行动棋子.完成移动信号
	重置被选单位()

func 获取实际移动范围(_填充结果字典_: Dictionary) -> Array[Vector2i]:
	return _填充结果字典_["实际移动范围"]
func 获取绘制用移动范围(_填充结果字典_: Dictionary) -> Array[Vector2i]:
	var 坐标集:Array[Vector2i] = _填充结果字典_["实际移动范围"]
	坐标集.append_array(_填充结果字典_["范围内友方棋子位置"])
	return 坐标集
func 获取绘制用攻击范围(_绘制用移动范围_:Array[Vector2i], _实际攻击范围_:Array[Vector2i]) -> Array[Vector2i]:
	for i in _绘制用移动范围_:
		if i in _实际攻击范围_:
			_实际攻击范围_.erase(i)
	return _实际攻击范围_

## 获取实际移动范围、范围内友方棋子位置
func 获取填充结果(_起点_: Vector2i, _移动距离_: int) -> Dictionary:
	## 可抵达的格子
	var 实际移动范围 :Array[Vector2i] = []
	## Vector2:int
	var 起点至格子最小累计移动力消耗 := {}
	## [[累计消耗, 格子位置]]
	var 优先队列 := []
	var 范围内友方棋子位置 :Array[Vector2i] = []
	起点至格子最小累计移动力消耗[_起点_] = 0
	优先队列.append([0, _起点_])
	
	while not 优先队列.is_empty():
		# 升序排序，消耗少的先计算
		优先队列.sort_custom(func(a, b): return a[0] < b[0])
		var 当前格子信息 = 优先队列.pop_front()
		var 当前格子移动力消耗: int = 当前格子信息[0]
		var 当前格子位置: Vector2i = 当前格子信息[1]
		# 跳过消耗更大的
		if 当前格子移动力消耗 > 起点至格子最小累计移动力消耗.get(当前格子位置, 障碍地形消耗值):
			continue
		# 消耗已超过最大移动力，跳过
		if 当前格子移动力消耗 > _移动距离_:
			continue
		if 实际移动范围.has(当前格子位置):
			continue
		# 不在矩阵范围内，跳过
		if not _网格类.判断格子是否在网格地图内(当前格子位置):
			continue
		# 友方棋子所在位置不可停留，所以不加入“实际移动范围”队列，但可以穿越，所以让其继续在这个点上扩散
		if 判断位置是否被占用(当前格子位置, "友方"):
			#print_debug("棋子？ 当前格子位置 : ", 当前格子位置)
			范围内友方棋子位置.append(当前格子位置)
			pass
		else :
			实际移动范围.append(当前格子位置)
		for 方向 in 天意四向诀:
				var 临近点坐标: Vector2i = 当前格子位置 + 方向
				# 非友方棋子设为被占用
				if 判断位置是否被占用(临近点坐标, "非友方") :
					continue
				var 临近点内移动力消耗: int = _格子内移动力消耗值字典.get(临近点坐标, 障碍地形消耗值)
				if 临近点内移动力消耗 == 障碍地形消耗值:
					continue
				var 至临近点的旧路径累计消耗 : int = 当前格子移动力消耗 + 临近点内移动力消耗 
				## 如果新路径消耗更少，或首次到达，则更新并加入队列
				var 至临近点的新路径累计消耗 : int = 起点至格子最小累计移动力消耗.get(临近点坐标, 障碍地形消耗值)
				if 至临近点的旧路径累计消耗 < 至临近点的新路径累计消耗 and 至临近点的旧路径累计消耗 <= _移动距离_:
					起点至格子最小累计移动力消耗[临近点坐标] = 至临近点的旧路径累计消耗
					优先队列.append([至临近点的旧路径累计消耗, 临近点坐标])
	实际移动范围.append(_起点_)
	return {"实际移动范围" : 实际移动范围, "范围内友方棋子位置": 范围内友方棋子位置}

## 获取完整的攻击范围
func 获取完整攻击范围(_棋子类_: 棋子类, _实际移动范围_: Array[Vector2i]) -> Array[Vector2i]:
	var 最小攻击距离: int = _棋子类_.最小攻击距离
	var 最大攻击距离: int = _棋子类_.最大攻击距离
	## 去重用，Vector2i：bool
	var 中转:= {}
	for i in _实际移动范围_:
		# 遍历攻击范围内的所有位置
		for x in range(-最大攻击距离, 最大攻击距离 + 1):
			for y in range(-最大攻击距离, 最大攻击距离 + 1):
				var 偏移量: Vector2i = Vector2i(x, y)
				var 位置: Vector2i = i + 偏移量
				var 曼哈顿距离: int = abs(x) + abs(y)
				if not _网格类.判断格子是否在网格地图内(位置):
					continue
				if 曼哈顿距离 >= 最小攻击距离 and 曼哈顿距离 <= 最大攻击距离 and 曼哈顿距离 > 0:
					# 用存入字典的方式去重
					中转[位置] = true
	var 实际攻击范围: Array[Vector2i]
	for i in 中转.keys():
		实际攻击范围.append(Vector2i(i))
	return 实际攻击范围
	
func 判断位置是否被占用(_目标位置_: Vector2i, _type: String = "") -> bool:
	var out: bool
	match _type:
		"非友方":
			if _棋子坐标字典.has(_目标位置_):
				if not _棋子阵营字典[_棋子坐标字典[_目标位置_]] == _棋子阵营字典[_行动棋子]:
					out = true
				else: 
					out = false
		"友方":
			if _棋子坐标字典.has(_目标位置_):
				if _棋子阵营字典[_棋子坐标字典[_目标位置_]] == _棋子阵营字典[_行动棋子]:
					out = true
				else: 
					out = false
		_:
			if _棋子坐标字典.has(_目标位置_):
				out = true
			else: 
				out = false
	return out

## 取消选中状态，清空范围显示，移除寻路路径
func 取消选中棋子() -> void:
	_行动棋子.被选中 = false
	_范围类.clear()
	_路径类.stop()

## 重置被选单位
func 重置被选单位() -> void:
	_行动棋子 = null
