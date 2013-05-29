module ActsRateable
  class Rating < ActiveRecord::Base
    
    self.table_name = "ar_ratings"
    
    belongs_to :resource, polymorphic: true
    has_many :rates, through: :ratings, as: :resource
    
  	attr_accessible :resource_id, :resource_type, :total, :sum, :average, :estimate
  
    validates :resource, :total, :sum, :average, :estimate, presence: true
    validates_numericality_of :total, :sum, :average, :estimate

  	@@global_ratings = {} 

  	before_save :update_ratings

    def self.set_totals(resource)
     sql = "SELECT COUNT(*) total_ratings, SUM(value) rating_sum, AVG(value) rating_avg, "+
            "(SELECT COUNT(DISTINCT resource_id) FROM ar_rates WHERE resource_type = '#{resource.class.name}') rated_count, "+
            "((SELECT COUNT(*) from ar_rates WHERE resource_type = '#{resource.class.name}') / (SELECT COUNT(DISTINCT resource_id) FROM ar_rates WHERE resource_type = '#{resource.class.name}')) avg_num_ratings "+
            "FROM ar_rates WHERE resource_type = '#{resource.class.name}'"
            @@global_ratings[resource.class.name] = ActsRateable::Rate.connection.execute(sql).first
    end

  	#  RETURNS = { "total_ratings"=>"", "rating_sum"=>"", "rating_avg"=>"", "rated_count"=>"", "avg_num_ratings"=>"" }
    def self.get_totals(resource)
      @@global_ratings[resource.class.name] ||= set_totals(resource)
    end

    # RETURNS = {"total_ratings"=>"", "rating_sum"=>"", "rating_avg"=>""}
    def self.values_for(resource)    
      sql =   "SELECT COUNT(*) total_ratings, COALESCE(SUM(value),0) rating_sum, COALESCE(AVG(value),0) rating_avg "+
              "FROM ar_rates WHERE resource_type = '#{resource.class.name}' and resource_id = '#{resource.id}'"
              ActsRateable::Rate.connection.execute(sql).first
    end

    def self.data_for(resource)
      local     = values_for(resource)
      global    = get_totals(resource)
      estimate  = (local['total_ratings'].to_f / (local['total_ratings'].to_f+global['avg_num_ratings'].to_f)) * local['rating_avg'].to_f + (global['avg_num_ratings'].to_f / (local['total_ratings'].to_f+global['avg_num_ratings'].to_f)) *global['rating_avg'].to_f
      return    { 'global' => global, 'local' => local.merge!({ 'estimate' => estimate }) }
    end
    
    protected

    def update_ratings
      if !resource.rates.empty?
        result   = self.class.data_for(resource)
        self.total    = result['local']['total_ratings']
        self.average  = result['local']['rating_avg']
        self.sum      = result['local']['rating_sum']
        self.estimate = result['local']['estimate']
        self.class.set_totals(resource) # Reset global values
      end
    end
  end
end