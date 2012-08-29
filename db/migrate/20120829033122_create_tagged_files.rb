class CreateTaggedFiles < ActiveRecord::Migration
  def change
    create_table :tagged_files do |t|
      t.string :file_name
      t.string :tag

      t.timestamps
    end
  end
end
