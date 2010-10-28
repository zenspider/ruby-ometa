require 'ometa/runtime'
require 'ometa/bootstrap'
require 'ometa/bootstrapper'
require 'ometa/leterize'
class OMeta
  GRAMMAR_FILES = %w(ometa null_opt andor_opt ometa_opt bsruby_parser
    bsruby_translator ometa_parser ometa_translator)

  GRAMMAR_FILES.collect! do |name|
    File.expand_path(File.dirname(__FILE__) + "/../ometa/#{name}.ometa")
  end
end
