load "./submission.rb"
require 'fileutils'

class Survey
  def initialize(base, survey, master)
    @base = base
    @survey = survey
    @master = master
    @admin = "administrator"
    @submissions = []
    @synthesis = []
  end
  
  def consolidate
    load_submissions
    merge_submissions
    self
  end
  
  def distribute!
    Dir.new(@base).each do |user|
      if user =~ /^\w+/
        if File.exist?(@base+"/"+user+"/"+@survey)
          FileUtils.cp original_file, @base+"/"+user+"/"+@survey
        end
      end
    end
  end
  
  def original_file
    @master+"/"+@admin+"/"+@survey
  end
  
  def seed
    FileUtils.touch original_file
  end
  
  def load_submissions
    Dir.new(@base).each do |user|
      if user =~ /^\w+/
        if File.exist?(@base+"/"+user+"/"+@survey)
          @submissions.push Submission.new @base, user, @survey, @master
        end
      end
    end
    
    @submissions.each do |submission|
      submission.load_survey
    end
  end
  
  def merge_submissions
    result = []
    winners = Set.new
    tally = tally_options
    ranks = count_by_ranks
    front_rank = Hash.new(0)
    ranks.each do |current_rank|
      merge_ranks? front_rank, current_rank
      winner = rank_winners front_rank, tally, winners
      if winner[0]
        result.push winner
        winner.each do |option|
          winners.add(option)
        end
      end
    end
    result.flatten!
    @synthesis = result
  end
  
  def rank_winners(rank, tally, winners)
    size = 0
    option = [nil]
    outright = true
    rank.each do |key, value|
      if !winners.include?(key)
        if value > size
          size = value
          option = [key]
          outright = true
        elsif value == size
          option.push key
          outright = false if (tally[option] > size || tally[key] > size)
        end
      end
    end
    if outright == true
      return option
    else
      return [nil]
    end
  end
  
  def merge_ranks?(result, source)
    source.each do |key, value|
      result[key] += value
    end
  end
  
  def count_by_ranks
    ranks = []
    @submissions.each do |submission|
      submission.options.each_with_index do |option, index|
        ranks[index] = Hash.new(0) if ranks[index] == nil
        ranks[index][option] += 1
      end
    end
    ranks
  end
  
  def tally_options
    options = Hash.new(0)
    @submissions.each do |submission|
      submission.options.each do |option|
        options[option] += 1
      end
    end
    options
  end
  
  def export_synthesis 
    result = Submission.new(@master, "administrator", @survey, @master)
    @synthesis.each do |option|
      new_option = Option.new(option.description)
      result.options.push new_option
      @submissions.each do |submission|
        submission.options.each do |option|
          if new_option.eql? option
            option.comments.each do |comment|
              new_option.add_comment comment
            end
          end
        end
      end
    end
    result
  end
  
  def to_s
    result = ""
    @submissions.each do |submission|
      result += submission.to_s + "\n"
    end
    result += "\n\n\n"
    result += @synthesis.to_s
    result
  end
end