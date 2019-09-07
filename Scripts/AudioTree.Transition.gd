extends AnimationNodeStateMachineTransition

export(String) var tags
export(String) var property
export(String) var target

var parent


func init(_parent):
	
	parent = _parent
	
	parent.connect('on_process', self, 'process')


func process():
	
	pass#disabled = false#not trigger