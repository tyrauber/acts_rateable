class ActsRateableMigration < ActiveRecord::Migration

  def self.up
    create_table :ar_rates do |t|
      t.references :resource, :polymorphic => true, :null => false
      t.references :author, :polymorphic => true, :null => false
      t.integer :value, :default => 0
      t.timestamps
    end
    add_index :ar_rates, [:resource_id, :resource_type]
    add_index :ar_rates, [:author_id, :author_type]
    
    create_table :ar_ratings do |t|
      t.references :resource, :polymorphic => true, :null => false
      t.integer :total, :default => 0
      t.integer :sum, :default => 0
      t.decimal :average, :default => 0
      t.decimal :estimate, :default => 0
      t.timestamps
    end
    add_index :ar_ratings, [:resource_id, :resource_type]
  end

  def self.down
    drop_table :ar_rates
    drop_table :ar_ratings
  end
end