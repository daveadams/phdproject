#!/usr/bin/env ruby
#
# testbot.rb
#   Test the PhD Project
#
# Created 2009-09-03 daveadams@gmail.com
#

require 'rubygems'
require 'mechanize'
require 'pp'
require 'yaml'

PROJECT_URL = "http://da1.edtech.vt.edu:3000"
CORRECTIONS = YAML::load_file(File.join("../test/fixtures/corrections.yml"))

if ARGV.length < 1
  STDERR.puts "Usage: #{$0} <participant-id> [<compliance-pattern>]"
  STDERR.puts "  <participant-id>      eg \"SS5106\" or \"AQ9989\""
  STDERR.puts "  <compliance-pattern>  One of \"comply\", \"nocomply\", or \"random\""
  STDERR.puts "                        Default value is \"random\""
  exit 1
end

participant_id = ARGV[0]
compliance = ARGV[1] || "random"

if not %w( comply nocomply random).include? compliance
  STDERR.puts "ERROR: compliance pattern must be \"comply\" \"nocomply\" or \"random\""
  exit 1
end

def corrections(round)
  CORRECTIONS.keys.find_all { |ck|
    CORRECTIONS[ck]["source_text_id"] == round
  }.collect { |ck| CORRECTIONS[ck] }
end

def log(s)
  puts "#{Time.now.strftime('%H:%M:%S')} #{s}"
end

def die(s)
  log "ERROR: #{s}"
  exit 1
end

def short_wait
  # 1-5 seconds
  #sleep rand(5) + 1
  sleep 1
end

def long_wait
  log "Long wait..."
  # 10-20 seconds
  #sleep rand(11) + 10
  sleep 2
end

bot = WWW::Mechanize.new

log "Getting login page..."
login_page = bot.get(PROJECT_URL)

short_wait

log "Logging in as '#{participant_id}'..."
page = login_page.form_with(:action => "/login/login") do |f|
  f.participant_number = participant_id
end.click_button

if page.title == "Log In"
  die "Login failed!"
elsif page.title != "Tutorial: Introduction"
  die "Unknown page: '#{page.title}'"
end

short_wait

log "Proceeding to tutorial overview... "
page = page.form_with(:action => "/tutorial/overview").click_button

if page.title != "Tutorial: Overview"
  die "Unknown page: '#{page.title}'"
end

short_wait

log "Proceeding to tutorial earnings intro... "
page = page.form_with(:action => "/tutorial/earnings_intro").click_button

if page.title != "Tutorial: Earnings Task and Earnings Report"
  die "Unknown page: '#{page.title}'"
end

short_wait

log "Proceeding to tutorial earnings task... "
page = page.form_with(:action => "/tutorial/earnings_task").click_button

if page.title != "Tutorial: Earnings Task Example"
  die "Unknown page: '#{page.title}'"
end

long_wait

tutorial_corrections = corrections(99)
work_count = rand(tutorial_corrections.length + 1)

log "About to correct #{work_count}/#{tutorial_corrections.length} errors..."
work_form = page.form_with(:action => "/tutorial/check_work")
working_text = work_form.working_text
0.upto(work_count - 1) do |i|
  working_text.gsub!(tutorial_corrections[i]["error_context"],
                     tutorial_corrections[i]["correction_context"])
end
work_form.working_text = working_text
page = work_form.click_button

if page.title != "Tutorial: Earnings Report Example"
  die "Unknown page: '#{page.title}'"
end

table_cells = page.root.css("td")
if table_cells[1].content.strip.to_i != work_count
  die "Corrections were not properly counted"
end

correct_earnings = sprintf("$%.2f", work_count * 0.35)
if table_cells[5].content.strip != correct_earnings
  die "Earnings were not properly figured"
end

log "Earned #{correct_earnings}!"

short_wait

log "Proceeding to tax/disclosure intro..."
nav_form = (page.form_with(:action => "/tutorial/disclosure_intro") ||
            page.form_with(:action => "/tutorial/tax_intro"))
page = nav_form.click_button

if page.title != "Tutorial: Earnings Disclosure" and
    page.title != "Tutorial: Income Tax Return"
  die "Unknown page: '#{page.title}'"
end

short_wait

log "Proceeding to tax/disclosure example..."
nav_form = (page.form_with(:action => "/tutorial/tax_return") ||
            page.form_with(:action => "/tutorial/disclosure_report"))
page = nav_form.click_button

if page.title != "Tutorial: Income Tax Return Example" and
    page.title != "Tutorial: Disclosure Report Example"
  die "Unknown page: '#{page.title}'"
end

short_wait

log "Proceeding to audit/doublecheck intro..."
nav_form = (page.form_with(:action => "/tutorial/audit_intro") ||
            page.form_with(:action => "/tutorial/doublecheck_intro"))
page = nav_form.click_button

if page.title != "Tutorial: Tax Audits" and
    page.title != "Tutorial: Double-checking of amounts disclosed"
  die "Unknown page: '#{page.title}'"
end

short_wait

log "Proceeding to notification example..."
nav_form = (page.form_with(:action => "/tutorial/audit_notify") ||
            page.form_with(:action => "/tutorial/doublecheck_notify"))
page = nav_form.click_button

if page.title != "Tutorial: Audit Notification Example" and
    page.title != "Tutorial: Notification Example"
  die "Unknown page: '#{page.title}'"
end

short_wait

log "Proceeding to OK example..."
nav_form = (page.form_with(:action => "/tutorial/audit_ok") ||
            page.form_with(:action => "/tutorial/doublecheck_ok"))
page = nav_form.click_button

if page.title != "Tutorial: First Audit Report Example" and
    page.title != "Tutorial: First Results Report Example"
  die "Unknown page: '#{page.title}'"
end

short_wait

log "Proceeding to error example..."
nav_form = (page.form_with(:action => "/tutorial/audit_error") ||
            page.form_with(:action => "/tutorial/doublecheck_error"))
page = nav_form.click_button

if page.title != "Tutorial: Second Audit Report Example" and
    page.title != "Tutorial: Second Results Report Example"
  die "Unknown page: '#{page.title}'"
end

short_wait

log "Proceeding to completion summary..."
page = page.form_with(:action => "/tutorial/completing").click_button

if page.title != "Tutorial: Completing the Experiment"
  die "Unknown page: '#{page.title}'"
end

short_wait

log "Proceeding to tutorial end..."
page = page.form_with(:action => "/tutorial/complete").click_button

if page.title != "Tutorial: Complete"
  die "Unknown page: '#{page.title}'"
end

short_wait

log "Beginning experiment..."
page = page.form_with(:action => "/tutorial/complete").click_button

if page.title != "Please Wait..." and page.title !~ /^Experiment: Begin Round /
  die "Unknown page: '#{page.title}'"
end

until page.title == "Experiment: Work Complete"
  until page.title =~ /^Experiment: Begin Round (\d+)$/
    log "Waiting..."
    sleep 5
    page = bot.get(PROJECT_URL + "/experiment/wait")
    if page.title != "Please Wait..." and page.title !~ /^Experiment: Begin Round /
      die "Unknown page: '#{page.title}'"
    end
  end

  short_wait
  this_round = $1.to_i
  log "Beginning round #{this_round}..."

  page = page.form_with(:action => "/experiment/work").click_button

  if page.title != "Experiment: Earnings Task"
    die "Unknown page: '#{page.title}'"
  end

  long_wait

  these_corrections = corrections(this_round)
  work_count = rand(these_corrections.length + 1)

  log "About to correct #{work_count}/#{these_corrections.length} errors..."
  work_form = page.form_with(:action => "/experiment/check_work")
  working_text = work_form.working_text
  0.upto(work_count - 1) do |i|
    working_text.gsub!(these_corrections[i]["error_context"],
                       these_corrections[i]["correction_context"])
  end
  work_form.working_text = working_text
  page = work_form.click_button

  if page.title != "Experiment: Earnings Report"
    die "Unknown page: '#{page.title}'"
  end

  table_cells = page.root.css("td")
  if table_cells[1].content.strip.to_i != work_count
    die "Corrections were not properly counted"
  end

  correct_earnings = sprintf("$%.2f", work_count * 0.35)
  if table_cells[5].content.strip != correct_earnings
    die "Earnings were not properly figured"
  end

  log "Earned #{correct_earnings}!"

  short_wait

  log "Proceeding on from earnings report..."
  page = page.form_with(:action => "/experiment/message").click_button

  if page.title == "Experiment: Message"
    log "Got an experimental message..."
    short_wait
    log "Moving on..."
    page = page.form_with(:action => "/experiment/report").click_button
  end

  if page.title != "Experiment: Individual Income Tax Return" and
      page.title != "Experiment: Disclosure Report"
    die "Unknown page: '#{page.title}'"
  end

  short_wait

  real_earnings = correct_earnings.gsub('$','').to_f
  if compliance == "comply" or (compliance == "random" && (rand(1) == 0))
    earnings_to_report = real_earnings
  else
    earnings_to_report = real_earnings - (rand * real_earnings)
  end
  earnings_to_report = sprintf("%.2f", earnings_to_report)

  log "Reporting earnings of $#{earnings_to_report}..."

  page = page.form_with(:action => "/experiment/submit_report") do |f|
    f.reported_earnings = earnings_to_report
  end.click_button

  if page.title != "Please Wait..." and
      page.title !~ /^Experiment: Begin Round / and
      page.title != "Experiment: Work Complete"
    if page.title != "Experiment: Notice"
      die "Unknown page: '#{page.title}'"
    end

    log "AUDITED!!"

    short_wait

    log "Okay, proceeding to results..."
    page = page.form_with(:action => "/experiment/perform_check").click_button

    if page.title != "Experiment: Audit Report" and
        page.title != "Experiment: Results Report"
      die "Unknown page: '#{page.title}'"
    end

    if page.root.css("td")[14].nil?
      log "PASSED!"
    else
      log "FAILED! Payed #{page.root.css('td')[14].strip} in penalties."
    end

    short_wait

    log "Finishing round..."
    page = page.form_with(:action => "/experiment/end_round").click_button

    if page.title != "Please Wait..." and
        page.title !~ /^Experiment: Begin Round / and
        page.title != "Experiment: Work Complete"
      die "Unknown page: '#{page.title}'"
    end
  end
end

