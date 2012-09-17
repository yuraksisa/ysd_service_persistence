Gem::Specification.new do |s|
  s.name    = "ysd-persistence"
  s.version = "0.2.0"
  s.authors = ["Yurak Sisa Dream"]
  s.date    = "2011-12-27"
  s.email   = ["yurak.sisa.dream@gmail.com"]
  s.files   = Dir['lib/**/*.rb']
  s.description = "Persistence system"
  s.summary = "Persistence system"
  s.homepage = "http://github.com/yuraksisa/ysd_service_persistence"
  
  s.add_runtime_dependency "mongo"
  
  s.add_runtime_dependency "ysd_md_comparison"  # To build the conditions
  s.add_runtime_dependency "ysd_md_system"      # To count the execution elapsed time
  
end