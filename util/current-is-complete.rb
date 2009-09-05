exit 1 if ExperimentalSession.active.participants.find_all_by_all_complete(false).count > 0

