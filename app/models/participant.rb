class ParticipantAlreadyActive < ActiveRecord::ActiveRecordError; end
class ParticipantNotActive < ActiveRecord::ActiveRecordError; end

class Participant < ActiveRecord::Base
  belongs_to :experimental_session
  belongs_to :experimental_group
  has_many :activity_logs
  has_many :cash_transactions
  has_many :correct_corrections

  validates_presence_of :participant_number
  validates_uniqueness_of :participant_number
  validates_presence_of :experimental_session_id
  validates_presence_of :experimental_group_id

  def self.find_active(partnum)
    result = self.find(:first, :conditions => ["participant_number = ?", partnum])
    unless result.nil? or not result.experimental_session.is_active
      return result
    else
      return nil
    end
  end

  def initialize(fields = nil)
    fields ||= {}
    fields[:participant_number] = Participant.generate_participant_number
    fields[:is_active] = false
    super(fields)
  end

  def login
    raise ParticipantAlreadyActive if self.is_active

    self.first_login ||= Time.now
    self.last_access = self.first_login
    self.is_active = true
    self.save
  end

  def earn_income(amount)
    self.add_transaction("income", amount)
  end

  def pay_tax(amount)
    self.add_transaction("tax", amount)
  end

  def pay_backtax(amount)
    self.add_transaction("backtax", amount)
  end

  def pay_penalty(amount)
    self.add_transaction("penalty", amount)
  end

  def cash
    self.cash_transactions.collect { |ct| ct.amount }.inject { |sum, amt| sum += amt } || 0.0
  end

  def correct_corrections_for_current_round
    self.correct_corrections.find_all_by_round(self.round)
  end

  def income_for_current_round
    begin
      self.cash_transactions.find_by_round_and_transaction_type(self.round, "income").amount
    rescue
      0.0
    end
  end

  def tax_for_current_round
    begin
      self.cash_transactions.find_by_round_and_transaction_type(self.round, "tax").amount
    rescue
      0.0
    end
  end

  def backtax_for_current_round
    begin
      self.cash_transactions.find_by_round_and_transaction_type(self.round, "backtax").amount
    rescue
      0.0
    end
  end

  def penalty_for_current_round
    begin
      self.cash_transactions.find_by_round_and_transaction_type(self.round, "penalty").amount
    rescue
      0.0
    end
  end

 protected
  def add_transaction(transaction_type, amount)
    ct = CashTransaction.new do |ct|
      ct.participant = self
      ct.amount = amount
      ct.transaction_type = transaction_type
      ct.round = self.round
    end
    ct.save!

    ActivityLog.create(:event => ActivityLog::CASH_TRANSACTION,
                       :participant_id => self.id,
                       :details => "'#{transaction_type}' #{amount}")
    self.reload
  end

  def self.generate_potential_participant_number
    alphaset = ("A".."Z").to_a
    ppn = ""
    2.times { ppn << alphaset[rand(alphaset.length - 1)] }
    4.times { ppn << rand(9).to_s }
    return ppn
  end

  def self.generate_participant_number
    pn = generate_potential_participant_number
    while Participant.find_by_participant_number(pn) != nil
      pn = generate_potential_participant_number
    end
    return pn
  end
end
