class Surveys
  attr_reader :user_surveys, :available_surveys
  
  def initialize(base, user, master)
    @base = base
    @user = user
    @master = master
    @admin = "administrator"
    
    load_surveys
  end
  
  def load_surveys
    load_user_surveys
    load_available_surveys
  end

  def load_user_surveys
    @user_surveys = []
    if (@user != @admin)
      Dir.new(@base+"/"+@user).each do |survey|
        if survey =~ /^\w+/
          @user_surveys.push survey
        end
      end
    end
  end

  def load_available_surveys
    @available_surveys = []
    Dir.new(@master+"/"+@admin).each do |survey|
      if survey =~ /^\w+/
        @available_surveys.push survey
      end
    end
    @available_surveys -= @user_surveys
  end
end