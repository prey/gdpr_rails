FROM ruby:3.1-slim

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      git \
      nodejs \
      npm \
      libsqlite3-dev \
      default-libmysqlclient-dev \
      libyaml-dev \
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

# Install appraisal-specific gemfiles
RUN bundle exec appraisal install

# Set environment variables for testing
ENV RAILS_ENV=test
ENV SECRET_KEY_BASE=test_secret_key_base_for_docker_tests

# Default command runs the appraisal matrix (6.1, 7.0, 7.1) sequentially
CMD ["sh", "-c", "for target in rails-6.1 rails-7.0 rails-7.1; do echo \"== Running $target ==\"; bundle exec appraisal $target rake spec || exit 1; done"]
