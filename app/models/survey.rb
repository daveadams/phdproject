class Survey < ActiveRecord::Base
  has_many :pages, :class_name => "SurveyPage", :order => "sequence"
end
