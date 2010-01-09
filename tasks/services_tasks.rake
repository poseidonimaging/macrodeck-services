desc "Migrates to using Wall instead of Comments"
task :migrate_to_walls => :environment do
	DataObject.update_all("type = 'Wall'", "type = 'Comments'")
end
