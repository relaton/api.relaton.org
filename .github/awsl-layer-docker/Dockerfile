FROM public.ecr.aws/lambda/ruby:4.0 as builder

COPY Gemfile Gemfile.lock ./
RUN bundle config set path "/lambda"
RUN bundle install --without=development --jobs 4 --retry 3

FROM public.ecr.aws/lambda/ruby:4.0
COPY --from=builder "/lambda/ruby" "/lambda/opt/ruby/gems"

