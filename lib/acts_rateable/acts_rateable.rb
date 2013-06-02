module ActsRateable
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
    
    def acts_rateable(options = {})
      
      has_many :rates, class_name: ActsRateable::Rate, as: :resource, dependent: :destroy
      has_many :rated, class_name: ActsRateable::Rate, as: :author, dependent: :destroy
      has_one :rating, class_name: ActsRateable::Rating, as: :resource, dependent: :destroy
      has_one :count, class_name: ActsRateable::Count, as: :resource, dependent: :destroy

      scope :order_by_rating, lambda { | column='estimate', direction="DESC" |
        includes(:rating).group('ar_ratings.id').order("ar_ratings.#{column.downcase} #{direction.upcase}")
      }
      
      scope :order_by_count, lambda { | column='estimate', direction="DESC" |
        includes(:count).group('ar_ratings.id').order("ar_ratings.#{column.downcase} #{direction.upcase}")
      }

      after_save do
         ActsRateable::Rating.where({resource_id: self.id, resource_type: self.class.name}).first_or_initialize.save #if !rates.empty?
         ActsRateable::Count.where({resource_id: self.id, resource_type: self.class.name}).first_or_initialize.save #if !rates.empty?
      end
      
      include LocalInstanceMethods
      
    end
  end

  module LocalInstanceMethods
    

    def variation( author )
      rated_by?(author) ? (rated_by?(author).value/self.rating['estimate']) : nil
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