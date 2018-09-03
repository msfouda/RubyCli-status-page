$:.unshift(File.expand_path("../", __FILE__))
require "status_page/version"

module StatusPage
  autoload :Help, "status_page/help"
  autoload :Command, "status_page/command"
  autoload :CLI, "status_page/cli"
end
