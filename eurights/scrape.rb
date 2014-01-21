require 'linkeddata'

repository = RDF::Repository.new

license_names = [
                 'unknown',
                 'rr-f',
                 'rr-p',
                 'rr-r'
                ]


license_names.each do |type|
  graph = RDF::Graph.new(:data => repository, :context => "http://www.europeana.eu/rights/#{type}/")
  graph.load("http://www.europeana.eu/rights/#{type}/")
end

RDF::Writer.open('rightsstatements.nt') { |writer| writer << repository }
