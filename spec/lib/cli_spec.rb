require "spec_helper"

# to run specs with what"s remembered from vcr
#   $ rake
#
# to run specs with new fresh data from aws api calls
#   $ rake clean:vcr ; time rake
describe StatusPage::CLI do
  before(:all) do
    @args = "--from Sobhi"
    @cli = "exe/status-page"
    @db = "status-page-db"
    @path = ENV['HOME'] + '/Desktop'
    @server = "https://status.heroku.com/api/v3/current-status"
  end

  describe "status-page hello" do
    it "should hello world" do
      out = execute("#{@cli} hello world #{@args}")
      expect(out).to include("from: Sobhi\nHello world")
    end
  end

  describe "status-page pull" do
    it "should return server status" do
      out = execute("#{@cli} pull")
      expect(out).to include("Rubygems")
    end

    it "should save server status" do
      out = execute("#{@cli} pull")
      file = "#{@db}/Status.json"
      expect(File.exist?(file)).to be true
    end
  end

  describe "status-page history" do
    it "should pull all history" do
      out = execute("#{@cli} history")
      expect(out).to include("Rubygems")
    end
  end

  describe "status-page live" do
    it "should pull continus live" do
      out = execute("#{@cli} live --test")
      expect(out).to include("Rubygems")
      expect(out).to include("I am LIVE")
    end
  end

  describe "status-page Backup" do
    it "should backup saved status history to given path" do
      execute("#{@cli} backup #{@path}")
      file = File.exist?("#{@path}/Backup.json")
      expect(file).to be true
    end
  end

  describe "status-page restore" do
    it "should restore from backup history path" do
      file1 = File.open("#{@db}/Status.json", "r")
      file2 = File.open("#{@path}/Backup.json", "r")
      execute("#{@cli} restore #{@path}/Backup.json")
      expect(IO.read(file1)).to eq(IO.read(file2))
      file1.close
      file2.close
      File.delete("#{@path}/Backup.json")
    end
  end

  describe "status-page add" do
    it "should not add invalid servers to monitor" do
      execute("#{@cli} add abaas frnaas")
      file = File.open("#{@db}/Servers.json", "r")
      expect(IO.read(file)).not_to include("frnaas")
    end

    it "should add valid servers to monitor" do
      execute("#{@cli} add Heroku #{@server}")
      file = File.open("#{@db}/Servers.json", "r")
      expect(IO.read(file)).to include(@server)
    end
  end

  describe "status-page delete" do
    it "should not delete non-exsiting server" do
      execute("#{@cli} delete Heroku")
      file = File.open("#{@db}/Servers.json", "r")
      expect(IO.read(file)).not_to include("Heroku")
    end

    it "should delete exsiting server" do
      execute("#{@cli} add Heroku #{@server}")
      execute("#{@cli} delete Heroku")
      file = File.open("#{@db}/Servers.json", "r")
      expect(IO.read(file)).not_to include("Heroku")
    end
  end


end
