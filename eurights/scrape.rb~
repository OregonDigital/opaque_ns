require 'linkeddata'

repository = RDF::Repository.new

license_names = [
                 'by',
                 'by-nc',
                 'by-sa',
                 'by-nd',
                 'by-nc-sa',
                 'by-nc-nd'
                ]
license_versions = [
                    '1.0',
                    '2.0',
                    '3.0',
                    '4.0'
                   ]

public_domain = [
                 'http://creativecommons.org/publicdomain/mark/1.0/',
                 'http://creativecommons.org/publicdomain/zero/1.0/'
                 ]

license_names.each do |type|
  license_versions.each do |version|
    graph = RDF::Graph.new(:data => repository, :context => "http://creativecommons.org/licenses/#{type}/#{version}/")
    graph.load("http://creativecommons.org/licenses/#{type}/#{version}/")
  end
end

public_domain.each do |url|
    graph = RDF::Graph.new(:data => repository, :context => "url")
    graph.load(url)
end

RDF::Writer.open('cclicenses.nt') { |writer| writer << repository }
