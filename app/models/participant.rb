class ParticipantAlreadyActive < ActiveRecord::ActiveRecordError; end
class ParticipantNotActive < ActiveRecord::ActiveRecordError; end
class OutOfSequence < ActiveRecord::ActiveRecordError; end

class Participant < ActiveRecord::Base
  belongs_to :experimental_session
  belongs_to :experimental_group
  has_many :activity_logs
  has_many :cash_transactions
  has_many :correct_corrections
  has_and_belongs_to_many :answers, :uniq => true

  validates_presence_of :participant_number
  validates_uniqueness_of :participant_number
  validates_presence_of :experimental_session_id
  validates_presence_of :experimental_group_id

  serialize :reported_earnings

  def before_validation
    self.reported_earnings ||= []
  end

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

  def report_earnings(amount)
    if self.reported_earnings[self.round]
      raise OutOfSequence.new
    end

    ActivityLog.create(:event => ActivityLog::REPORT,
                       :participant_id => self.id,
                       :details => "Reported earnings of $#{amount}")
    self.reported_earnings[self.round] = amount
    self.save
  end

  def audit
    if not self.work_complete_for_current_round? or
        not self.taxes_paid_for_current_round? or
        not self.audit_pending_for_current_round?
      raise OutOfSequence.new
    end

    if self.income_for_current_round > self.reported_earnings_for_current_round
      correct_tax = -(self.income_for_current_round *
                      (self.experimental_group.tax_rate.to_f/100))
      backtax_due = correct_tax - self.tax_for_current_round
      penalty_due = backtax_due * self.experimental_group.penalty_rate
      self.pay_backtax(backtax_due)
      self.pay_penalty(penalty_due)
    else
      self.pay_backtax(0.0)
      self.pay_penalty(0.0)
    end

    self.audit_completed = true
    self.audited = true
    self.save
  end

  def cash
    self.cash_transactions.collect { |ct| ct.amount }.inject { |sum, amt| sum += amt } || 0.0
  end

  def checked_for_current_round?
    self.last_check == self.round
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

  def reported_earnings_for_current_round
    self.reported_earnings[self.round]
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

  def work_complete_for_current_round?
    !self.cash_transactions.find_by_round_and_transaction_type(self.round, "income").nil?
  end

  def taxes_paid_for_current_round?
    !self.cash_transactions.find_by_round_and_transaction_type(self.round, "tax").nil?
  end

  def audit_pending_for_current_round?
    self.to_be_audited && !self.audit_completed
  end

  def advance_round
    if self.work_complete_for_current_round? and
        self.taxes_paid_for_current_round? and
        not self.audit_pending_for_current_round?

      self.to_be_audited = false
      self.audit_completed = false
      self.round += 1
      self.save
    else
      raise OutOfSequence.new
    end
  end

  def next_survey_page
    my_questions = self.answers.collect { |a| a.question }
    self.experimental_group.survey.pages.detect do |survey_page|
      (not (survey_page.questions - my_questions).empty?) and
        not (survey_page.depends_on_answer and
             not self.answers.include? survey_page.depends_on_answer)
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
