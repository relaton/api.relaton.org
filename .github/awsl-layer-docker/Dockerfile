FROM lambci/lambda:20210129-build-ruby2.7 as builder

ADD Gemfile .
RUN yum install -y libyaml-devel
RUN bundle config set path "/lambda"
RUN bundle install --without=development --jobs 4 --retry 3

FROM lambci/yumda:2 as yumda

COPY --from=builder "/lambda/ruby" "/lambda/opt/ruby/gems"

