require 'ometa/runtime'
require 'ometa/bootstrap'
require 'ometa/bootstrapper'

class OMeta
  GRAMMAR_FILES = %w(null_opt andor_opt ometa_opt bsruby_parser
    bsruby_translator ometa_parser ometa_translator)

  GRAMMAR_FILES.collect! do |name|
    File.expand_path(File.dirname(__FILE__) + "/../ometa/#{name}.ometa")
  end
end
