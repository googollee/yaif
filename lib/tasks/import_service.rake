require 'yaml'
require 'pp'

namespace :service do
  desc "Import service information into database"
  services = FileList["service/*.yaml"]
  task :import => :environment do
    services.each do |s|
      puts "Loading #{s}..."
      y = YAML::load_file(s.to_s)
      y.symbolize_keys!

      y[:service].symbolize_keys!
      puts "\tImport Service: #{y[:service][:name]}..."
      y[:service][:auth_data].symbolize_keys!
      service = Service.create! y[:service]

      y[:trigger].each do |t|
        t.symbolize_keys!
        puts "\tImport Trigger: #{t[:name]}..."
        normalize_array t, :in_keys
        normalize_array t, :out_keys
        t[:service] = service
        Trigger.create! t
      end

      y[:action].each do |a|
        a.symbolize_keys!
        puts "\tImport Action: #{a[:name]}..."
        normalize_array a, :in_keys
        a[:service] = service
        Action.create! a
      end
    end
  end
end

def normalize_array(h, sym)
  h[sym] ||= []
  h[sym].map! { |i| i.to_sym }
end
