module ExperimentHelper
  def bank_balance
    sprintf("%0.2f", @participant.cash)
  end
end
