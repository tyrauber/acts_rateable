module ActsRateable
  class Count < ActsRateable::ArRating

    belongs_to :resource, polymorphic: true

    validates :resource, :total, :sum, :average, :estimate, presence: true
    validates_numericality_of :total, :sum, :average, :estimate

    unless (Rails::VERSION::STRING.to_f >= 4)
      attr_accessible :resource_id, :resource_type, :total, :sum, :average, :estimate, :type
    end

  	before_save :update_ratings

    def self.get_totals(author)
      sql = "SELECT COUNT(*) total_ratings, SUM(value) rating_sum, AVG(value) rating_avg, "+
            "(SELECT COUNT(DISTINCT author_id) FROM ar_rates WHERE author_type = '#{author.class.base_class.name}') rated_count, "+
            "((SELECT COUNT(*) from ar_rates WHERE author_type = '#{author.class.base_class.name}') / (SELECT COUNT(DISTINCT author_id) FROM ar_rates WHERE author_type = '#{author.class.base_class.name}')) avg_num_ratings "+
            "FROM ar_rates WHERE author_type = '#{author.class.base_class.name}'"
      #  RETURNS = { "total_ratings"=>"", "rating_sum"=>"", "rating_avg"=>"", "rated_count"=>"", "avg_num_ratings"=>"" }
      ActsRateable::Rate.connection.execute(sql).first
    end

    def self.values_for(author)    
      sql =   "SELECT COUNT(*) total_ratings, COALESCE(SUM(value),0) rating_sum, COALESCE(AVG(value),0) rating_avg "+
              "FROM ar_rates WHERE author_type = '#{author.class.base_class.name}' and author_id = '#{author.id}'"
      # RETURNS = {"total_ratings"=>"", "rating_sum"=>"", "rating_avg"=>""}
      ActsRateable::Rate.connection.execute(sql).first
    end

    def self.data_for(author)
      local     = values_for(author)
      global    = get_totals(author)
      estimate  = (local['total_ratings'].to_f / (local['total_ratings'].to_f+global['avg_num_ratings'].to_f)) * local['rating_avg'].to_f + (global['avg_num_ratings'].to_f / (local['total_ratings'].to_f+global['avg_num_ratings'].to_f)) *global['rating_avg'].to_f
      return    { 'global' => global, 'local' => local.merge!({ 'estimate' => estimate }) }
    end

    protected

    def update_ratings
      if resource && !resource.rated.empty?
        result   = self.class.data_for(resource)
        self.total    = result['local']['total_ratings']
        self.average  = result['local']['rating_avg']
        self.sum      = result['local']['rating_sum']
        self.estimate = result['local']['estimate']
      end
    end
  end
end