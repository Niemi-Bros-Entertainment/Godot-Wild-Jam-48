'OneShotParticle'
extends CPUParticles

export(float) var timer :float = 2.0


func _ready():
	emitting = true


func _physics_process(delta):
	if timer <= 0:
		queue_free()
	timer -= delta
