class CashTransaction < ActiveRecord::Base
  belongs_to :participant

  validates_associated :participant
  validates_presence_of :round
  validates_numericality_of(:amount,
                            :greater_than_or_equal_to => 0,
                            :if => Proc.new { |ct|
                              ct.transaction_type == "income"
                            })
  validates_numericality_of(:amount,
                            :less_than_or_equal_to => 0,
                            :if => Proc.new { |ct|
                              %w( tax backtax penalty ).include?(ct.transaction_type)
                            })
  validates_format_of :transaction_type, :with => /^(income|tax|backtax|penalty)$/
  validates_uniqueness_of :round, :scope => [:participant_id, :transaction_type]
end
