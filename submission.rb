require "set"
require 'fileutils'

class Option
  attr_reader :description, :comments
  
  def initialize(description)
    @comments = Set.new
    @description = description
  end

  def add_comment(comment)
    @comments.add(comment)
  end

  def to_s
    result = @description.to_s + "\n"
    @comments.each do |comment|
      result += "  " + comment.to_s + "\n"
    end
    result
  end
  
  def eql?(o)
    @description.eql? o.description
  end
  
  def hash
    @description.hash
  end
end

class Submission
  attr_reader :options, :user, :survey
  
  def initialize(base, user, survey, master)
    @base = base
    @user = user
    @survey = survey
    @master = master
    @admin = "administrator"
    @options = []
  end
  
  def file_name
    @base+"/"+@user+"/"+@survey
  end
  
  def original_file
    @master+"/"+@admin+"/"+@survey
  end
  
  def reset!
    FileUtils.cp original_file, file_name
  end
  
  def update_survey text
    load_survey_from text.lines
    write
  end

  def load_survey
    load_survey_from File.open(choose_source)
    self
  end
  
  def load_survey_from source
    option = nil
    source.each do |line|
      if line =~ /^\S/
        option = Option.new(line.strip)
        @options.push option
      else
        if line !~ /^\s*$/
          if option
            option.add_comment line.strip
          end
        end
      end
    end
  end

  def choose_source
    if !File.exist?(file_name)
      return original_file
    else
      return file_name
    end
  end
  
  def write()
    File.open(file_name, "w") do |out|
      out.puts self
    end
  end

  def to_s()
    result = ""
    @options.each do |option|
      result += option.to_s
    end
    result
  end
end