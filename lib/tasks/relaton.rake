namespace :relaton do
  desc "Remove expired standard documents"
  task :cleanup => :environment do
    Standard.expired_in(1.hours.ago).select(:id).in_batches do |standards|
      standards.destroy_all
    end
  end
end
