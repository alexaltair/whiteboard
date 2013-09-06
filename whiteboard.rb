app_name = ARGV[0]
require "./#{app_name}.rb"

# `rm -rf Examply`
`rails new #{app_name} --skip-bundle` # Skipping bundle to test faster
Dir.chdir(app_name)
RailsModel.model_list.values.each do |model|
  model.to_file
  model.make_migration
  sleep 1.01
end