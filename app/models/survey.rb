class Survey < ActiveRecord::Base
  has_many :pages, :class_name => "SurveyPages", :order => "sequence"
end
