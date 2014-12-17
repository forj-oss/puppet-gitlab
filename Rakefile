require 'rake'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

#
# puppet lint
#
PuppetLint.configuration.log_format = '%{path}:%{linenumber} (%{check}) - %{KIND}: %{message}'
PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.send('disable_80chars')
# Forsake support for Puppet 2.6.2
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.send('disable_class_parameter_defaults')

ignore_paths = %w(vendor/**/*.pp spec/**/*.pp pkg/**/*.pp)
PuppetLint.configuration.ignore_paths = ignore_paths
PuppetSyntax.exclude_paths = ignore_paths

task :default => [:test]

desc 'Run lint, syntax, and spec tests.'
task :test => [
         :lint,
         :syntax,
         :spec,
     ]