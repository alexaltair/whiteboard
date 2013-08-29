require 'rails'

require 'tempfile'
require 'fileutils'

def add_associations(model_name)
  path = "app/models/#{model_name}.rb"
  temp_file = Tempfile.new('absolutely_unique_filename')
  begin
    File.open(path, 'r') do |file|
      file.each_line do |line|
        addition = if line.include?('attr_access') then "\n  belongs_to " else '' end
        temp_file.puts line + addition
      end
    end
    temp_file.rewind
    FileUtils.mv(temp_file.path, path)
  ensure
    temp_file.close
    temp_file.unlink
  end
end

`rm -rf Examply` # --------Careful--------
app_name = 'Examply'
model_name = 'example'
`rails new #{app_name} --skip-bundle` # Skipping bundle to test faster
Dir.chdir(app_name)
`rails generate model #{model_name} name:string`
`rails generate model Comment body:text`
add_associations(model_name)