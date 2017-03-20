class CreatePings < ActiveRecord::Migration[5.0]
  def change
    create_table :pings do |t|
      t.references :host, foreign_key: true
      t.integer :status
      t.float :response

      t.timestamps
    end
  end
end
