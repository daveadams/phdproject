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
  has_and_belongs_to_many(:tutorial_corrections, :uniq => true,
                          :class_name => "Correction",
                          :join_table => :tutorial_corrections)

  validates_presence_of :participant_number
  validates_uniqueness_of :participant_number
  validates_presence_of :experimental_session_id
  validates_presence_of :experimental_group_id

  serialize :reported_earnings
  serialize :all_ips

  def before_validation
    self.reported_earnings ||= []
    self.all_ips ||= []
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
    self.add_transaction("income", amount.abs)
  end

  def pay_tax(amount)
    self.add_transaction("tax", -amount.abs)
  end

  def pay_backtax(amount)
    self.add_transaction("backtax", -amount.abs)
  end

  def pay_penalty(amount)
    self.add_transaction("penalty", -amount.abs)
  end

  def report_earnings(amount)
    if self.reported_earnings[self.round]
      raise OutOfSequence.new
    end

    ActivityLog.create(:event => ActivityLog::REPORT,
                       :participant_id => self.id,
                       :round => self.round,
                       :details => sprintf("Reported earnings of $%0.2f", amount))
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
      self.work_load_time = nil
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

  def perform_audit?
    logger.info("ALOG audit check performed")
    audit_rate = self.experimental_group.audit_rate
    if self.income_for_current_round != self.reported_earnings_for_current_round
      logger.info("ALOG noncompliant")
      audit_rate = self.experimental_group.noncompliance_audit_rate
    else
      logger.info("ALOG compliant")
    end

    rand((1/audit_rate).to_i) == 0
  end

  def choices
    [self.gamble0, self.gamble1, self.gamble2, self.gamble3, self.gamble4,
     self.gamble5, self.gamble6, self.gamble7, self.gamble8, self.gamble9]
  end

  def choices_made?
    not self.choices.include? nil
  end

  def station_number
    # hardcoded for simplicity
    case self.last_ip
      when "128.173.185.6" then "1"
      when "128.173.185.7" then "2"
      when "128.173.185.8" then "3"
      when "128.173.185.9" then "4"
      when "128.173.185.10" then "5"
      when "128.173.185.11" then "6"
      when "128.173.185.12" then "7"
      when "128.173.185.13" then "8"
      when "128.173.185.14" then "9"
      when "128.173.185.15" then "10"
      when "128.173.185.16" then "11"
      when "128.173.185.17" then "12"
      else nil
    end
  end

  def station
    if self.station_number.nil?
      self.last_ip
    else
      "Station #{self.station_number}"
    end
  end

  def report_csv
    timefmt = "%Y-%m-%d %H:%M:%S"
    [
     self.participant_number,
     self.experimental_group.name,
     self.first_login? ? self.first_login.strftime(timefmt) : "",
     self.last_access? ? self.last_access.strftime(timefmt) : "",
     self.paid_at? ? self.paid_at.strftime(timefmt) : "",
     sprintf("%0.2f", self.cash),
     (0..(self.experimental_group.rounds - 1)).collect do |i|
       [
        self.earnings_history[i].nil? ? "" : sprintf("%0.2f", self.earnings_history[i].amount),
        self.reporting_history[i].nil? ? "" : self.reporting_history[i],
        self.tax_paid_history[i].nil? ? "" : sprintf("%0.2f", self.tax_paid_history[i].amount),
        # correct tax
        if self.earnings_history[i]
          sprintf("%0.2f", -(self.earnings_history[i].amount *
                             self.experimental_group.tax_rate / 100))
        else
          ""
        end,
        self.backtax_history[i].nil? ? "" : sprintf("%0.2f", self.backtax_history[i].amount),
        self.penalty_history[i].nil? ? "" : sprintf("%0.2f", self.penalty_history[i].amount),
        # audited?
        if self.reporting_history[i]
          self.audit_history[i] ? "Y" : "N"
        else
          ""
        end,
        # percent reported
        if self.earnings_history[i] and self.reporting_history[i]
          if self.earnings_history[i].amount == 0.0
            ""
          else
            sprintf("%0.2f", (self.reporting_history[i] /
                              self.earnings_history[i].amount))
          end
        else
          ""
        end,
        # compliant?
        if self.earnings_history[i] and self.reporting_history[i]
          if self.reporting_history[i] < self.earnings_history[i].amount
            "N"
          else
            "Y"
          end
        else
          ""
        end
        # TODO time spent on work (in seconds)
        # TODO time spent on message (in seconds)
        # TODO number of estimates
       ]
     end,
     # gamble choices
     self.gamble0,
     self.gamble1,
     self.gamble2,
     self.gamble3,
     self.gamble4,
     self.gamble5,
     self.gamble6,
     self.gamble7,
     self.gamble8,
     self.gamble9,
     # TODO:survey answers
     Question.find(:all, :order => :id).collect do |q|
       answer = self.answers.find_by_question_id(q.id)
       if answer.nil?
         ""
       else
         '"' + answer.answer + '"'
       end
     end
    ].flatten.join(",")
  end

  # stats section

  def earnings_history
    @earnings_history ||=
    (1..self.experimental_group.rounds).collect do |round|
      self.cash_transactions.find_by_transaction_type_and_round("income", round)
    end
  end

  def reporting_history
    @reporting_history ||=
    (1..self.experimental_group.rounds).collect do |round|
      self.reported_earnings[round]
    end
  end

  def tax_paid_history
    @tax_paid_history ||=
    (1..self.experimental_group.rounds).collect do |round|
      self.cash_transactions.find_by_transaction_type_and_round("tax", round)
    end
  end

  def backtax_history
    @backtax_history ||=
    (1..self.experimental_group.rounds).collect do |round|
      self.cash_transactions.find_by_transaction_type_and_round("backtax", round)
    end
  end

  def penalty_history
    @penalty_history ||=
    (1..self.experimental_group.rounds).collect do |round|
      self.cash_transactions.find_by_transaction_type_and_round("penalty", round)
    end
  end

  def audit_history
    bth = self.backtax_history
    ph = self.penalty_history

    @audit_history ||=
    (0..(self.experimental_group.rounds - 1)).collect do |i|
      not (bth[i].nil? and ph[i].nil?)
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

    log_details = case transaction_type
                    when "income": sprintf("Earned income of $%0.2f", amount)
                    when "tax": sprintf("Paid taxes of $%0.2f", amount)
                    when "backtax": sprintf("Paid back taxes of $%0.2f", amount)
                    when "penalty": sprintf("Paid penalty of $%0.2f", amount)
                    else
                      sprintf("Transaction type '#{transaction_type}' of $%0.2f", amount)
                  end
    ActivityLog.create(:event => ActivityLog::CASH_TRANSACTION,
                       :participant_id => self.id,
                       :round => self.round,
                       :details => log_details)
    self.reload

    # don't let the balance go below zero
    if self.cash < 0.0
      ActivityLog.create(:event => ActivityLog::WARNING,
                         :participant_id => self.id,
                         :round => self.round,
                         :details => "Balance below zero, adding an adjustment back to zero")

      ct = CashTransaction.new do |ct|
        ct.participant = self
        ct.amount = -(self.cash)
        ct.transaction_type = "autoadjust"
        ct.round = self.round
      end
      ct.save!

      ActivityLog.create(:event => ActivityLog::CASH_TRANSACTION,
                         :participant_id => self.id,
                         :round => self.round,
                         :details => sprintf("Auto-generated adjustment of $%0.2f", ct.amount))
      self.reload
    end
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
