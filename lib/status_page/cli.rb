require 'json'
require 'httparty'

module StatusPage
  class CLI < Command
    class_option :verbose, type: :boolean
    class_option :noop, type: :boolean

    desc "hello NAME", "say hello to NAME"
    long_desc Help.text(:hello)
    option :from, desc: "from person"
    def hello(name="you")
      puts "from: #{options[:from]}" if options[:from]
      puts "Hello #{name}"
    end

    desc "version", "prints version"
    def version
      puts StatusPage::VERSION
    end

    desc "Write JSON", "Create and Write to JSON"
    long_desc Help.text(:jsonFile)
    option :read, desc: "Read from"
    option :write, desc: "Write input"
    def sta
      if options[:write]
      newArray = []
      newHashy = {
        "key_a" => "val_a",
        "key_b" => "val_b"
      }
      newArray << newHashy
      File.open("temp.json","w") do |f|
        f.write(newArray.to_json)
      end
      puts "done write"
    elsif options[:read]
      f = File.open("temp.json","r")
        readHashy = JSON.parse(f.read)
      puts readHashy
      f.close
      puts "done Read"
    end
  end

  desc "Add to JSON", "Write to JSON"
  long_desc Help.text(:jsonFile)
  def pull

    hashArray = []
    hash = {}

    begin
      f = File.open("Servers.json","r+")
      stat = JSON.parse(f.read)
      f.close
    rescue
      baseServers = {
        "Rubygems":"https://pclby00q90vc.statuspage.io/api/v2/status.json",
        "Github Messages":"https://status.github.com/api/messages.json",
        "Bitbucket":"https://bqlf8qjztdtr.statuspage.io/api/v2/status.json",
        "Cloudflare":"https://yh6f0r4529hb.statuspage.io/api/v2/status.json"
      }
      File.open("Servers.json", "w+") do |f|
        f.write(baseServers.to_json)
      end
      stat = baseServers
    end

      stat.each_key { |key|
        response = HTTParty.get(stat[key])
        begin
          hash[key] = {
            "Status":response["status"]["description"] || response["status"]["Production"] || response["status"]["Development"],
            "Time": Time.now
          }
        rescue
          hash[key] = {
            "Status":response.first["body"],
            "Time": Time.now
          }
        end
      }

      puts "="*80
      printf "%-20s %-32s %s\n", "Service", "Status", "Time"
      puts "="*80
      display(hash)

        begin
          f = File.open("Status.json", "r")
            hashArray = JSON.parse(f.read)
            hashArray << hash
          f = File.open("Status.json", "w")
          f.write(hashArray.to_json)
          f.close
        rescue
          File.open("Status.json","w") do |f|
            hashArray << hash
            f.write(hashArray.to_json)
            f.close
          end
        end
  end

  desc "LIVE", "LIVE Quary"
  long_desc Help.text(:jsonFile)
  def live
    while true
      puts "="*80
      puts "I am LIVE: #{Time.now} "
      pull
      puts "\n"*5
      sleep 5
    end
  end

  desc "HISTORY", " Server log HISTORY"
  long_desc Help.text(:jsonFile)
  def history
    f = File.open("Status.json", "r+")
      hashArray = JSON.parse(f.read)
      puts "="*80
      printf "%-20s %-32s %s\n", "Service", "Status", "Time"
      puts "="*80
      hashArray.each { |hash|
        display(hash)
      }
  end

  desc "Backup", " Server log backup"
  long_desc Help.text(:jsonFile)
  def backup(path)
    File.open("#{path}/Backup.json","w") do |f|
      status = File.open("Status.json", "r")
      fi = JSON.parse(status.read)
      status.close
      f.write(fi.to_json)
      f.close
    end
  end

  desc "Restore", " Server log Restore"
  long_desc Help.text(:jsonFile)
  def restore(path)
    File.open("Status.json","w") do |f|
      status = File.open("#{path}", "r")
      fi = JSON.parse(status.read)
      status.close
      f.write(fi.to_json)
      f.close
    end
  end

  desc "Display ", " Display HASH"
  long_desc Help.text(:jsonFile)
  def display(hash)
    hash.each { |key, val|
          printf "%-20s %-32s %s\n", key, val[:Status] || val["Status"], val[:Time] || val["Time"]
          puts "-"*80
      }
  end

  desc "Add to JSON", "Write to JSON"
  long_desc Help.text(:jsonFile)
  def add(key, val)
    begin
      f = File.open("Servers.json","r+")
      fi = JSON.parse(f.read)
      fi[key] = val
      puts fi
      f = File.open("Servers.json","w")
      f.write(fi.to_json)
      f.close
    rescue
      f = File.open("Servers.json","w")
      fi = {}
      fi[key] = val
      puts fi
      f.write(fi.to_json)
      f.close
    end
  end

  desc "delete fromo JSON", "Write to JSON"
  long_desc Help.text(:jsonFile)
  def delete(key)
      f = File.open("Servers.json","r+")
      fi = JSON.parse(f.read)
      # puts fi
        if fi.empty?
          # File.delete("Servers.json")
          puts "="*50
          puts "There is no Remaining Servers to monitor"
          puts "="*50
        else
          fi.delete(key)
          f = File.open("Servers.json","w")
          f.write(fi.to_json)
          f.close
      end
    end
  end
end
