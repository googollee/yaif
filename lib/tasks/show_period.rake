namespace :service do
  desc "Show all tasks period"
  task :show_period => :environment do
    Task.all.each do |t|
      puts t.trigger.period
    end
  end
end
