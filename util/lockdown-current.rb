#!/home/da1/per/phd/script/runner

print "Locking down current session... ";STDOUT.flush
ExperimentalSession.active.lockdown if ExperimentalSession.active
puts "OK"


