class ActsRateableMigration < ActiveRecord::Migration

  def self.up
    create_table :bayesian_ratings do |t|
      t.references :resource, :polymorphic => true, :null => false
      t.references :author, :polymorphic => true, :null => false
      t.integer :value, :default => 0
      t.timestamps
    end
    add_index :bayesian_ratings, [:resource_id, :resource_type]
    add_index :bayesian_ratings, [:author_id, :author_type]
    
    create_table :bayesian_estimates do |t|
      t.references :resource, :polymorphic => true, :null => false
      t.decimal :estimate, :default => 0
      t.timestamps
    end
    add_index :bayesian_estimates, [:resource_id, :resource_type]
  end

  def self.down
    drop_table :bayesian_ratings
    drop_table :bayesian_estimates
  end
end