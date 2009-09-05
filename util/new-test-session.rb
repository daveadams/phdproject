participant_count = ARGV[0].to_i || 20
pnfile = ARGV[1] || "pn.txt"

def msgwrap(msg)
  print "#{msg}... "; STDOUT.flush
  result = yield
  puts "OK"
  return result
end

if ExperimentalSession.active
  msgwrap("Terminating current session") do
    ExperimentalSession.active.set_complete
  end
end

xs = msgwrap("Creating new session") do
  ExperimentalSession.create(:name => "Test Session #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}")
end

msgwrap("Creating participants") do
  groups = ExperimentalGroup.count
  partper = participant_count / groups
  partextra = participant_count % groups
  0.upto(groups - 1) do |i|
    xs.create_participants(((i < partextra) ? partper + 1 : partper),
                           ExperimentalGroup.all[i].id)
  end
  xs.reload
end

puts "Created #{xs.participants.count} participants!"

msgwrap("Writing participant numbers out to #{pnfile}") do
  File.open(pnfile, "w") do |f|
    xs.participants.each do |p|
      f.puts p.participant_number
    end
  end
end

msgwrap("Activating session") do
  xs.set_active
end
