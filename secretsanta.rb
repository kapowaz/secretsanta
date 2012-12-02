#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'bundler'
require 'yaml'
require './lib/memorable_codes'

Bundler.require

class SecretSanta
  include DataMapper::Resource
  
  property :code,               String, :key => true
  property :participants_yaml,  Text
  property :paired_to_yaml,     String
  property :mailed,             Boolean, :default => false
  
  def self.generate(listfile)
    participants_list = listfile || "participants.yml"
    default_listfile  = listfile.nil?
      
    if File.exists?(participants_list)
      participants = YAML.load(File.new(participants_list))
      if participants
        paired_to = Array.new
        
        0.upto( participants.size - 1 ) do |i|
          paired_to << i
        end

        # ensure that you can't accidentally get paired with yourself
        while paired_to.any? {|i| paired_to[i] == i }
          paired_to.shuffle!
        end

        pp = SecretSanta.create(
          :code              => MemorableCodes.generate,
          :participants_yaml => YAML.dump(participants),
          :paired_to_yaml     => YAML.dump(paired_to)
        )
        
        pp
      end
    else
      if default_listfile
        puts "No participant list supplied and default list not found".red
      else
        puts "Couldn't find that participant list".red        
      end
    end
  end
  
  def self.report(code)
    if pp = SecretSanta.get(code)
      puts "Pairings with code #{code}:\n\n"
      
      pp.pairings.each do |pairing|
        from = "#{pairing[:from].yellow} (#{pairing[:email]})"
        puts "#{from.ljust(65)} → #{pairing[:to].green}"
      end
      
      if pp.mailed?
        puts "\nThis list has been mailed out to the recipients".green
      else
        puts "\nThis list has not yet been mailed out to the recipients".red
      end
      
      true
    else
      puts "Couldn't find a list with the code ‘#{code}’".red
    end
  end
  
  def pairings
    pairings = []
    self.participants.each_with_index do |participant, i|
      paired_with = self.paired_to[i]
      pairings << {
        :from   => participant.keys.first,
        :email  => participant.values.first,
        :to     => self.participants[paired_with].keys.first
      }
    end
    pairings
  end
  
  def participants
    YAML.load(self.participants_yaml)
  end
  
  def paired_to
    YAML.load(self.paired_to_yaml)
  end
    
  def mail!
    print "Emailing all participants for list with code ‘#{self.code}’ ".green
    STDOUT.flush
    
    self.pairings.each do |pairing|
      Pony.mail({
        :to           => "#{pairing[:from]} <#{pairing[:email]}>", 
        :from         => "Secret Santa <secret@san.ta>",
        :subject      => "[#{self.code}] Secret Santa", 
        :html_body    => "<h1>Secret Santa!</h1><p>Festive greetings, #{pairing[:from]}!</p><p>This email is to let you know that in the random draw, you have been selected to buy a Secret Santa gift for #{pairing[:to]}!</p><p>Season's greetings,<br>Santa</p><p><small>P.S. Please keep hold of this email just in case. The code in the subject line can be used to help re-send the list if need be.</small></p>",
        :via          => :smtp,
        :via_options  => YAML.load(File.new('./smtp.yml'))
      })
      print "•".green
      STDOUT.flush
    end
    puts " done!".green
    self.update(:mailed => true)
  end
end

DataMapper.setup :default, "sqlite3:./participant_pairings.db"
DataMapper.finalize
DataMapper.auto_upgrade!
  
# ./secretsanta.rb generate <participants>
# ./secretsanta.rb report <code>
# ./secretsanta.rb mail <code>

unless ARGV.length == 0
  case ARGV[0]
    when "generate"
      list = SecretSanta.generate ARGV[1]
      puts "Generated list with code #{list.code}".green
    when "report"
      if ARGV[1]
        SecretSanta.report ARGV[1]
      else
        puts "Usage: secretsanta.rb report <code>"
      end
    when "mail"
      if ARGV[1]
        list = SecretSanta.get(ARGV[1])
        if list.nil?
          puts "Couldn't find a list with the code ‘#{ARGV[1]}’".red
        else
          list.mail!
        end
      else
        puts "Usage: secretsanta.rb mail <code>"
      end
  end
else
  puts "Usage: secretsanta.rb [generate <participants>|report <code>|mail <code>]"
end