class ActivityLog < ActiveRecord::Base
  PAGE_LOADED = "pageload"
  ERROR = "error"
  OUT_OF_SEQUENCE = "seqerror"
  WARNING = "warning"
  LOGIN = "login"
end
