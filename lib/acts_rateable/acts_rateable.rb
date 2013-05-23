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
      
      scope :order_by, lambda { | column='estimate', direction="DESC" |
         joins("LEFT OUTER JOIN ar_ratings ON ar_ratings.resource_id = #{self.table_name}.id AND ar_ratings.resource_type = '#{self.name}'").
         select("#{self.table_name}.*, COALESCE(ar_ratings.total, 0) as total, COALESCE(ar_ratings.average, 0) as average, COALESCE(ar_ratings.sum, 0) as sum, COALESCE(ar_ratings.estimate, 0) as estimate").
         order("#{column.downcase} #{direction.upcase}")
      }
      
      after_save do
         ActsRateable::Rating.create(self) if !rates.empty?
      end
      
      include LocalInstanceMethods
      
    end
  end

  module LocalInstanceMethods
    
    #   Returns the resource rating
    #   column: total, sum, average and estimate
    def rating(column='estimate')
      ratings.nil? ? nil : ratings[column]
    end

    def variation( author )
      rated_by?(author) ? (rated_by?(author).value/self.rating) : nil
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