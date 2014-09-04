require 'linkeddata'

def parse_rdf(file)
  RDF::Graph.load(file)
end

exit_code = 0
Dir.glob("**/*.jsonld").each do |file|
  begin
    puts "Parsing #{file}"
    parse_rdf(file)
  rescue StandardError => e
    puts "Failed to parse #{file} with error:\n#{e.message}"
    exit_code = 1
  end
end
exit exit_code
