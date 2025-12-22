FROM ruby:3.2-slim

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      git \
      nodejs \
      npm \
      libsqlite3-dev \
      default-libmysqlclient-dev \
      tzdata && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install gem dependencies first to leverage Docker layer caching
COPY Gemfile gdpr_rails.gemspec Appraisals ./
COPY gemfiles ./gemfiles
# gemspec needs version file at bundle time for dependency resolution
COPY lib/policy_manager/version.rb ./lib/policy_manager/version.rb
RUN bundle install --jobs 4 --retry 3

# Copy the rest of the source
COPY . .

# Install appraisal-specific gemfiles (rails-6.1)
RUN bundle exec appraisal install

# Ensure Logger is loaded for Rails/ActiveSupport bootstrap
ENV RUBYOPT="-rlogger"

# Default command runs migrations then the Rails 6.1 appraisal specs
CMD ["sh", "-c", "BUNDLE_GEMFILE=/app/gemfiles/rails_6.1.gemfile bundle exec rake app:db:migrate RAILS_ENV=test && BUNDLE_GEMFILE=/app/gemfiles/rails_6.1.gemfile bundle exec rake app:db:test:prepare RAILS_ENV=test && BUNDLE_GEMFILE=/app/gemfiles/rails_6.1.gemfile bundle exec rspec"]
