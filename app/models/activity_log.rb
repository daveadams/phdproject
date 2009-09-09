class ActivityLog < ActiveRecord::Base
  belongs_to :participant

  PAGE_LOADED = "pageload"
  ERROR = "error"
  OUT_OF_SEQUENCE = "seqerror"
  WARNING = "warning"
  LOGIN = "login"
  CRITICAL = "critical"
  CASH_TRANSACTION = "cashtrans"
  AUDIT = "audit"
  REPORT = "report"
  ESTIMATE = "estimate"
end
