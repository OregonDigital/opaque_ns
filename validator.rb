#!/usr/bin/env ruby
require 'linkeddata'
require 'docopt'

doc = <<DOCOPT
Quick RDF Validator

Checks whether a given file parses as valid RDF.

Usage:
  #{__FILE__} FILE
  #{__FILE__} -h | --version

Options: 
  -h --help      Show this help screen.
  -v --version   Show current version.

DOCOPT

def parse_rdf(file)
  RDF::Graph.load(file)
end

begin
  opts = Docopt::docopt(doc, version: 'version.rb 0.0.1')
  JSON.parse(File.open(opts['FILE']).read) if opts['FILE'].end_with? ".jsonld"
  graph = parse_rdf(opts['FILE'])
  if graph.empty?
    puts "Parsed invalid or with an empty graph."
  else
    puts "Parsed valid with #{graph.count} statements."
  end
rescue Exception => e
  puts "Failed to parse with error:\n#{e.message}"
end
