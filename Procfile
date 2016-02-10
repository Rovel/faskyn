<<<<<<< HEAD
web: bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-development}
worker: bundle exec sidekiq -c 5 -v
=======
web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -c 5 -q default -q mailers
>>>>>>> faskyn/master
