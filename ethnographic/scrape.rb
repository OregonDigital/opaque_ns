require 'rdf'
require 'nokogiri'
require 'open-uri'
require 'ruby-progressbar'
require 'pry'

graph = RDF::Graph.new

class EthnographicThesaurus < RDF::Vocabulary('http://opaquenamespace.org/et/'); end

def slug(str)
  str.downcase.split.each_with_index.map { |v,i|  i == 0 ? v : v.capitalize }.join.gsub(/[^a-zA-Z]/, '').to_sym
end

def relationships(uri, label)
  term_g = RDF::Graph.new

  begin
    term = Nokogiri::HTML(open("http://openfolklore.org/et/term.htm?id=#{URI.encode(label)}"))
  rescue Exception => e
    puts "#{e} for term: #{label}"
    return term_g
  end
  date_labels = term.css('span[class="term-field-label"]')
  date_values = term.css('span[class="term-field-value"]')

  narrower_terms = term.css('div[class="et-narrower-term"]')
  broader_terms = term.css('div[class="et-broader-term"]')
  related_terms = term.css('div[class="et-related-term"]')

  narrower_terms.each do |t|
    next if t.nil?
    term_g << RDF::Statement(uri, RDF::SKOS.narrower, EthnographicThesaurus[slug(t.css('a').text)])
  end

  broader_terms.each do |t|
    next if t.nil?
    term_g << RDF::Statement(uri, RDF::SKOS.broader, EthnographicThesaurus[slug(t.css('a').text)])
  end

  related_terms.each do |t|
    next if t.nil?
    term_g << RDF::Statement(uri, RDF::SKOS.related, EthnographicThesaurus[slug(t.css('a').text)])
  end

  term_g
end

ethnographic = Nokogiri::HTML(open('http://www.openfolklore.org/et/all-terms.htm'))

term_list = ethnographic.css('li[class="et-term"]')
pbar = ProgressBar.create(:title => "Terms", :total => term_list.count)

terms = {}
count = 0
term_list.each do |term|
  pref = term.css('span[class="et-preferred-term"]').css('a')[0].text
  graph << RDF::Statement(EthnographicThesaurus[slug(pref)], RDF::SKOS.prefLabel, pref)
  graph << RDF::Statement(EthnographicThesaurus[slug(pref)], RDF.type, RDF::SKOS.Concept)
  graph << relationships(EthnographicThesaurus[slug(pref)], pref)
  nonpref = term.css('span[class="et-non-preferred"]')
  unless nonpref.empty?
    graph << RDF::Statement(EthnographicThesaurus[slug(pref)], RDF::SKOS.altLabel, nonpref.css('a')[0].text)
  end
  count += 1
  sleep 5 if (count % 100) == 0
  sleep 60 if (count % 1501) == 0
  pbar.increment
end

binding.pry

RDF::Writer.for(:ntriples).open('ethnographic.nt') { |writer| writer << graph }

pbar.finish
