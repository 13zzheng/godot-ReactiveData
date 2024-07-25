extends RefCounted
class_name Dep

static var sid = 0
static var target_stack: Array = []
static var target

static func push_target(tar):
	Dep.target_stack.push_back(tar)
	Dep.target = tar
	
static func pop_target():
	Dep.target_stack.pop_back()
	if target_stack.size() > 0:
		Dep.target = target_stack[target_stack.size() - 1]
	else:
		Dep.target = null
		
		
var id: int
var subs = []
		
func _init() -> void:
	id = Dep.sid
	Dep.sid += 1
	
func depend():
	if Dep.target:
		if not subs.has(Dep.target):
			add_sub(Dep.target)

func add_sub(sub):
	if not sub:
		return
	subs.append(sub)
	sub.add_dep(self)
	pass
	
func remove_watcher():
	pass
	
func notify():
	for sub in subs:
		sub.update()
	pass
