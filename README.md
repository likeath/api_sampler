# ApiSampler [![Build Status](https://travis-ci.org/likeath/api_sampler.svg?branch=master)](https://travis-ci.org/likeath/api_sampler) [![Code Climate](https://codeclimate.com/github/likeath/api_sampler.png)](https://codeclimate.com/github/likeath/api_sampler)

Collect samples for API

## TODO List
* Frequency check (is it really needed or sample rate would be sufficient?)
* Rails integration:
  * Persistent store (fetch data from redis, save to DB)
  * `ApiSampler::Store::Model` (save samples directly to DB)
  * Samples' presentation
  * Generators

## Installation

Add this line to your application's Gemfile:

    gem 'api_sampler'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install api_sampler

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( http://github.com/<my-github-username>/api_sampler/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
