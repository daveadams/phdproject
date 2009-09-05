print "Locking down current session... ";STDOUT.flush
ExperimentalSession.active.lockdown if ExperimentalSession.active
puts "OK"


