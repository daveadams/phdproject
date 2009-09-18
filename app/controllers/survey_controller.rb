class SurveyController < ApplicationController
  before_filter :check_phase

  def index
    survey_page = @participant.next_survey_page
    if survey_page
      @intro_text = survey_page.intro_text
      @questions = survey_page.questions
      @answers = {}
      @questions.each do |q|
        @answers[q.id] = @participant.answers.find_by_question_id(q.id)
      end

      if request.post?
        answered_questions = Question.find(params.keys.find_all { |k|
                                             k =~ /^q[0-9]+$/
                                           }.collect { |k|
                                             k.gsub(/^q/,'').to_i
                                           })
        unanswered_questions = @questions - (answered_questions || [])
        unanswered_questions.each do |uaq|
          flash[:survey_errors] ||= {}
          flash[:survey_errors][uaq.id] = "Please answer every question."
        end

        answered_questions.each do |q|
          begin
            answer = params["q#{q.id}"]
            if q.fill_in_the_blank
              if (q.minimum and answer.to_i < q.minimum) or
                  (q.maximum and answer.to_i > q.maximum) or
                  ((q.minimum or q.maximum) and answer.to_i.to_s != answer)
                flash[:survey_errors] ||= {}
                flash[:survey_errors][q.id] = "Your answer must be between #{q.minimum} and #{q.maximum}."
              else
                @participant.answers << Answer.find_or_create_by_question_id_and_answer(q.id, params["q#{q.id}"])
              end
            else
              @participant.answers << Answer.find(answer)
            end
          rescue
            flash[:survey_errors] ||= {}
            flash[:survey_errors][q.id] = "An error occurred. Please try answering this question again."
          end
        end
        redirect_to(:action => :index)
      end
    else
      redirect_to(:action => :complete)
    end
  end

  def complete
    if @participant.next_survey_page.nil?
      @participant.survey_complete = true
      @participant.save
      redirect_to(:controller => :complete)
    else
      redirect_to(:action => :index)
    end
  end

 private
  def check_phase
    if @participant.survey_complete
      redirect_to(:controller => :complete)
    elsif not @participant.tutorial_complete
      redirect_to(:controller => :tutorial)
    elsif not @participant.experiment_complete
      redirect_to(:controller => :experiment)
    end
  end
end
