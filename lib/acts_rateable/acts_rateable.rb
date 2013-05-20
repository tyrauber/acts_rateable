module ActsRateable
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
    
    def acts_rateable(options = {})
      
      has_many :rates, class_name: ActsRateable::Rate, as: :resource, dependent: :destroy
      has_many :rated, class_name: ActsRateable::Rate, as: :author, dependent: :destroy
      has_one :ratings, class_name: ActsRateable::Rating, as: :resource, dependent: :destroy
      
      # Resource.order_by(column, direction)
      # => column: total, average, sum, estimate
      # => direction: DESC, ASC
      
      scope :order_by, lambda { | column='estimate', direction="DESC" | includes(:ratings).order("ar_ratings.#{column.downcase} #{direction.upcase}") }
      
      before_save do
         ActsRateable::Rating.create(self) if !rates.empty?
      end
      
      include LocalInstanceMethods
      
    end
  end

  module LocalInstanceMethods
    
    #   Returns the resource rating
    #   column: total, sum, average and estimate
    def rating(column='estimate')
      ActsRateable::Rating.data_for(self)[column]
    end
    
    def variation(author)
      (rated_by?(author).value/ActsRateable::Rating.data_for(self)['estimate'])
    end
    
    # Checks wheter a resource has been rated by a user. Returns the rating if true, otherwise returns false.
    def rated_by?( author )
      ActsRateable::Rate.rated?(self, author)
    end
    
    # Checks wheter a user rated a resource. Returns the rating if true, otherwise returns false.
    def has_rated?( resource )
      ActsRateable::Rate.rated?(resource, self)
    end
    
  	# Rates a resource by an author with a given value.
		def rate( resource, value )
      ActsRateable::Rate.create(self, resource, value)
		end

  end
end
ActiveRecord::Base.send :include, ActsRateable