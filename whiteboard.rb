app_name = ARGV[0]
command = ARGV[1]
require "./#{app_name}.rb"

`rm -rf Examply`
`rails new #{app_name} --skip-bundle` # Skipping bundle to test faster
Dir.chdir(app_name)
RailsModel.model_list.values.each do |model|
  model.make_model
  model.make_migration
  sleep 1.01 # This is so that the timestamped version number are different.
end

if command == 'migrate'
  `rake db:migrate`
elsif command == 'server'
  `rake db:migrate`
  `rails s`
end