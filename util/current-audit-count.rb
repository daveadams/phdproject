#!/home/da1/per/phd/script/runner

puts ExperimentalSession.active.participants.find_all_by_audited(true).count

