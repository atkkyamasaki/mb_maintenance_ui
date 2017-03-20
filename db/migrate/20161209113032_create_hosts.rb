class CreateHosts < ActiveRecord::Migration[5.0]
  def change
    create_table :hosts do |t|
      t.string :hostname
      t.string :ip

      t.timestamps
    end
  end
end
