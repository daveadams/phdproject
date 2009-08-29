class Question < ActiveRecord::Base
  has_many :possible_answers, :order => "sequence"
end
