# WingenderTFClass
This gem allows to retrieve information for a transcription factor from Wingender's TFClass ontology. Necessary data come with gem but can be updated using the rake task in `rake/WingenderClassification.rake`.
While current version works quite nice, API is going to be changed. Current version is quite preliminary. So please lock used in your app version of a gem via Gemfile.
## Posibly sometimes these changes will be made (ToDo):
* Use third-party *.obo (ontology format) reader.
* Support alt_id and other tags
* More convenient data structure for an ontology.
* Less duplication in classes for obtaining family by UniprotID/UniprotAC/motif/somewhat else
* Method rename
* List monad for multiple TF classes of multiple TF motifs (just as an experiment)
* Make usage of rake task to update data more simple in use

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'WingenderTFClass'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install WingenderTFClass

## Usage

```ruby
require 'WingenderTFClass'
class_recognizer = WingenderTFClass::ProteinFamilyRecognizers::HumanAtLevel[2]
family_recognizer = WingenderTFClass::ProteinFamilyRecognizers::HumanAtLevel[3]
class_recognizer.subfamilies_by_uniprot_id('RXRA_HUMAN')
# => [Nuclear receptors with C4 zinc fingers{2.1}]
family_recognizer.subfamilies_by_uniprot_id('RXRA_HUMAN')
# => [RXR-related receptors (NR2){2.1.3}]

subfamily_mouse_recognizer = WingenderTFClass::ProteinFamilyRecognizers::MouseAtLevel[4]
subfamily_mouse_recognizer.subfamilies_by_uniprot_id('RXRA_MOUSE')
# => [Retinoid X receptors (NR2B){2.1.3.1}]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/VorontsovIE/WingenderTFClass.

