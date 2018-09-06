require "spec_helper"

# to run specs with what"s remembered from vcr
#   $ rake
#
# to run specs with new fresh data from aws api calls
#   $ rake clean:vcr ; time rake
describe StatusPage::CLI do
  before(:all) do
    @args = "--from Sobhi"
  end

  describe "status-page hello" do
    it "should hello world" do
      out = execute("exe/status-page hello world #{@args}")
      expect(out).to include("from: Sobhi\nHello world")
    end
  end

  describe "status-page pull" do
    it "should return server status" do
      out = execute("exe/status-page pull")
      expect(out).to include("Rubygems")
    end

    it "should save server status" do
      out = execute("exe/status-page pull")
      file = "status-page-db/Status.json"
      expect(File.exist?(file)).to be true
    end
  end

  describe "status-page history" do
    it "should pull all history" do
      out = execute("exe/status-page history")
      expect(out).to include("Rubygems")
    end
  end

  describe "status-page live" do
    it "should pull continus live" do
      out = execute("exe/status-page live --test")
      expect(out).to include("Rubygems")
      expect(out).to include("I am LIVE")
    end
  end

end
