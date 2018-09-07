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

    desc "PULL", "Pull Servers Status"
    long_desc Help.text(:pull)
    def pull

      hashArray = []
      hash = {}

      begin
        f = File.open("status-page-db/Servers.json","r+")
        stat = JSON.parse(f.read)
        f.close
      rescue
        baseServers = {
          "Rubygems":"https://pclby00q90vc.statuspage.io/api/v2/status.json",
          "Github Messages":"https://status.github.com/api/messages.json",
          "Bitbucket":"https://bqlf8qjztdtr.statuspage.io/api/v2/status.json",
          "Cloudflare":"https://yh6f0r4529hb.statuspage.io/api/v2/status.json"
        }
        if !Dir.exist?('status-page-db')
          Dir.mkdir("status-page-db")
        end

        File.open("status-page-db/Servers.json", "w+") do |f|
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
            begin
              hash[key] = {
                "Status":response.first["body"],
                "Time": Time.now
              }
            rescue
              hash[key] = {
                "Status":"Down",
                "Time": Time.now
              }
            end
          end
        }

        puts "="*80
        printf "%-20s %-32s %s\n", "Service", "Status", "Time"
        puts "="*80
        display(hash)

        begin
          f = File.open("status-page-db/Status.json", "r")
            hashArray = JSON.parse(f.read)
            hashArray << hash
            f = File.open("status-page-db/Status.json", "w")
            f.write(hashArray.to_json)
            f.close
        rescue
            File.open("status-page-db/Status.json","w") do |f|
              hashArray << hash
              f.write(hashArray.to_json)
              f.close
            end
        end
      end

      desc "LIVE", "Get LIVE Servers status"
      long_desc Help.text(:live)
      option :test, desc: "test live method"
      def live
        while true
          puts "="*80
          puts "I am LIVE: #{Time.now} "
          pull
          puts "\n"*5
          break if options[:test]
          sleep 5
        end
      end

      desc "HISTORY", "Server log HISTORY"
      long_desc Help.text(:history)
      def history
        f = File.open("status-page-db/Status.json", "r+")
        hashArray = JSON.parse(f.read)
        puts "="*80
        printf "%-20s %-32s %s\n", "Service", "Status", "Time"
        puts "="*80
        hashArray.each { |hash|
          display(hash)
        }
      end

      desc "Backup", "Server log backup"
      long_desc Help.text(:backup)
      def backup(path)
        File.open("#{path}/Backup.json","w") do |f|
          status = File.open("status-page-db/Status.json", "r")
          fi = JSON.parse(status.read)
          status.close
          f.write(fi.to_json)
          f.close
        end
      end

      desc "Restore", "Server log Restore"
      long_desc Help.text(:restore)
      def restore(path)
        File.open("status-page-db/Status.json","w") do |f|
          status = File.open("#{path}", "r")
          fi = JSON.parse(status.read)
          status.close
          f.write(fi.to_json)
          f.close
        end
      end

      desc "Display ", "Display HASH"
      long_desc Help.text(:display)
      def display(hash)
        hash.each { |key, val|
            printf "%-20s %-32s %s\n", key, val[:Status] || val["Status"], val[:Time] || val["Time"]
            puts "-"*80
          }
      end

      desc "ADD", "Add Server to monitor"
      long_desc Help.text(:add)
      def add(key, val)
        begin
          f = File.open("status-page-db/Servers.json","r+")
          fi = JSON.parse(f.read)
          fi[key] = val
          f = File.open("status-page-db/Servers.json","w")
          f.write(fi.to_json)
          f.close
        rescue
          Dir.mkdir("status-page-db")
          f = File.open("status-page-db/Servers.json","w")
          fi = {}
          fi[key] = val
          f.write(fi.to_json)
          f.close
        end

        begin
          pull
        rescue
          delete(key)
          puts "="*80
        puts "Invalid Server API < #{val} >"
        puts "Kindly Check Your New Server Then Try Again"
        puts "="*80
      end

    end

    desc "DELETE", "Delete and stop monitor server"
    long_desc Help.text(:delete)
    def delete(key)
      begin
        f = File.open("status-page-db/Servers.json","r+")
        fi = JSON.parse(f.read)
        if fi.empty?
          puts "="*80
          puts "There is no Remaining Servers to monitor"
          puts "="*80
        elsif !fi.key?(key)
            puts "="*80
            puts "There is no Server named < #{key} > to be deleted"
            puts "Kindly check mentored servers and try again"
            pull
        else
          fi.delete(key)
          puts "="*80
          puts "Server < #{key} > have been deleted"
          puts "="*80
        end
          f = File.open("status-page-db/Servers.json","w")
          f.write(fi.to_json)
          f.close
      rescue
        puts "="*80
        puts "There is no Servers add yet"
        puts "="*80
      end
    end

  end
end
