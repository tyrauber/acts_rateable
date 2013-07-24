module ActsRateable
  class Rate < ActiveRecord::Base

    self.table_name = "ar_rates"

    belongs_to :resource, polymorphic: true
    belongs_to :author, polymorphic: true
  
    validates :author, :resource, :value, presence: true
  
    validates_numericality_of :value, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 100
  	validates_uniqueness_of :author_id, :scope => [:author_type, :resource_id, :resource_type]
	
  	attr_accessible :resource_id, :resource_type, :author_type, :author_id, :value
  
    after_save :generate_estimate
  
    def self.rated?(resource, author)
      rate = where({
        author_type: author.class.base_class.name, author_id: author.id,
        resource_type: resource.class.base_class.name, resource_id: resource.id
      })
      return rate if rate
      return false
    end
    
    def self.create(author, resource, value)
      return unless author && resource && value
			atts = { 
			  resource_type: resource.class.base_class.name, resource_id: resource.id,
			  author_type: author.class.base_class.name, author_id: author.id,
			  value: value
			}
			rate = where(atts.except(:value)).first_or_initialize(atts)
			rate.value = value
      rate.save
      return rate
    end

    private
  
    def generate_estimate
      ActsRateable::Rating.where({resource_id: self.resource_id, resource_type: self.resource_type}).first_or_initialize.save #if !rates.empty?
      ActsRateable::Count.where({resource_id: self.author_id, resource_type: self.author_type}).first_or_initialize.save #if !rates.empty?
    end
  end
end