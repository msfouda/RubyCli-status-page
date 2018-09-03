require "json"
require "httparty"

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
    begin
      f = File.open("Servers.json","r+")
      stat = JSON.parse(f.read)
      hash = {}

      stat.each_key { |key|
        response = HTTParty.get(stat[key])
        begin
          hash[key] = response["status"]["description"] || response["status"]["Production"] || response["status"]["Development"]
        rescue
          hash[key] = response.first["body"]
        end
      }

      puts "="*50
      printf "%-20s %s\n", "Service", "Status"
      puts "="*50
      hash.each { |key, val|
            printf "%-20s %s\n", key, val
            puts "-"*50
        }

        File.open("Status.json","w") do |f|
          f.write(hash.to_json)
        end

      rescue
        puts "="*50
        puts "There is no valid server input yet"
        puts "Please Enter new servers input using addServ"
        puts "="*50
      end
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
      fi.delete(key)
      puts fi
        if fi.empty?
          File.delete("Servers.json")
          puts "="*50
          puts "There is no Remaining Servers to monitor"
          puts "="*50
        else
          f = File.open("Servers.json","w")
          f.write(fi.to_json)
          f.close
      end
    end
  end
end
