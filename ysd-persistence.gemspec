Gem::Specification.new do |s|
  s.name    = "ysd-persistence"
  s.version = "0.1"
  s.authors = ["Yurak Sisa Dream"]
  s.date    = "2011-12-27"
  s.email   = ["yurak.sisa.dream@gmail.com"]
  s.files   = Dir['lib/**/*.rb']
  s.description = "Persistence system"
  s.summary = "Persistence system"
  
  s.add_runtime_dependency "mongo"
  
  s.add_runtime_dependency "ysd_md_comparison"
end