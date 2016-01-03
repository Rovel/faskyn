require "refile/s3"

if Rails.env.production?
  aws = {
    access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
    bucket: ENV['AWS_BUCKET_NAME']
  }
  Refile.cache = Refile::S3.new(max_size: 5.megabytes, prefix: "cache", **aws)
  Refile.store = Refile::S3.new(prefix: "store", **aws)
else
  Refile.store = :file
end
