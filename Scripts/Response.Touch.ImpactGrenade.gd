extends 'res://Scripts/Response.gd'


func _on_stimulate(stim, data):
	
	if stim == 'Touch':
		
		var shooter = owner._get_tag('Shooter') if owner._has_tag('Shooter') else owner
		
		Meta.AddActor('Projectiles/Explosions/Explosion1', owner.translation, owner.rotation, null, { 'Shooter': shooter })
		
		Meta.DestroyActor(owner)
