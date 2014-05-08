require 'rdf'
require 'nokogiri'
require 'open-uri'
require 'pry'

graph = RDF::Graph.new

class EthnographicThesaurus < RDF::Vocabulary('http://opaquenamespace.org/et/'); end

def slug(str)
  str.downcase.split.each_with_index.map { |v,i|  i == 0 ? v : v.capitalize }.join.gsub(/[^a-zA-Z]/, '').to_sym
end

ethnographic = Nokogiri::HTML(open('http://www.openfolklore.org/et/all-terms.htm'))

term_list = ethnographic.css('li[class="et-term"]')

terms = {}

term_list.each do |term|
  pref = term.css('span[class="et-preferred-term"]').css('a')[0].text
  graph << RDF::Statement(EthnographicThesaurus[slug(pref)], RDF::SKOS.prefLabel, pref)
  graph << RDF::Statement(EthnographicThesaurus[slug(pref)], RDF.type, RDF::SKOS.Concept)
  nonpref = term.css('span[class="et-non-preferred"]')
  unless nonpref.empty?
    graph << RDF::Statement(EthnographicThesaurus[slug(pref)], RDF::SKOS.altLabel, pref)
  end
end

RDF::Writer.open('ethnographic.nt') { |writer| writer << graph }
