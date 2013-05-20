class User < ActiveRecord::Base
  acts_rateable
  attr_accessible :name, :value
end
