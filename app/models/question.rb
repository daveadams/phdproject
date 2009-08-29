class Question < ActiveRecord::Base
  has_many :answers, :order => "sequence"
end
