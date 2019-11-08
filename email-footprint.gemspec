# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'email-footprint'
  spec.version       = '1.0.1'
  spec.authors       = ['Subvertical LLC']
  spec.email         = ['developers@verticalchange.com']

  spec.summary       = 'Send and track emails with AWS.'
  spec.description   = 'Sending and tracking emails using Amazon SES, SNS, SQS, Lambda and DynamoDB.'
  spec.homepage      = 'https://github.com/subvertical/email-footprint'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '~> 4.2'
  spec.add_dependency 'aws-sdk',       '~> 3.0'
  spec.add_dependency 'thor',          '~> 0.19.1'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake',    '~> 10.0'
  spec.add_development_dependency 'rspec',   '~> 3.0'
end
