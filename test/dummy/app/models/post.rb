class Post < ActiveRecord::Base
  
  acts_rateable
  attr_accessible :name, :value
end
