require 'yaml'

desc "Import participants from config/participants.yml"
task :import do
  participants = YAML.load(File.new('config/participants.yml'))
  participants.each do |yaml|
    if SecretSanta::Participant.all(email: yaml[:email]).any?
      puts "Skipping existing participant with email address <#{yaml[:email].bold}>…"
    else
      participant = SecretSanta::Participant.create_from_yaml(yaml)
      puts "Created participant: #{participant.name.green} with email address <#{participant.email}>"
    end
  end
end # task :import

desc "Assign all existing participants a random assignment"
task :assign, :reset do |t, args|
  if SecretSanta::Participant.all.all? {|p| p.assignee == nil } || args[:reset] == 'reset'
    SecretSanta::Participant.assign_all
  else
    puts "At least one participant has already been assigned, so I’m bailing out rather than losing existing assignments".red
  end
end # task :assign

desc "List all participants, plus their assigned code"
task :report do
  puts "All participants:"
  SecretSanta::Participant.all.each do |participant|
    puts "#{participant.code}: #{participant.name.green} <#{participant.email}>"
  end
end

desc "Send out all assignment emails"
task :mailall do
  puts "Sending assignment emails to all participants…"
  SecretSanta::Participant.all.each do |participant|
    participant.notify
    puts "Sending assignment email to #{participant.name} at <#{participant.email.green}>!"
  end
end

desc "Send out an assignment email to a single participant, using their unique code"
task :mail, :code do |t, args|
  participant = SecretSanta::Participant.first(code: args[:code])

  if participant
    participant.notify
    puts "Sending assignment email for #{participant.name.bold} to <#{participant.email.green}>!"
  else
    puts "No participant with code ‘#{args[:code]}’ could be found".red
  end
end # task :mail

desc "Reveal who a given participant has been secretly assigned (omg spoilers!)"
task :reveal, :code do |t, args|
  participant = SecretSanta::Participant.first(code: args[:code])
  if participant
    puts "#{participant.name} <#{participant.email}> has the secret assignment #{participant.assignee.name.green}"
  else
    puts "No participant with code ‘#{args[:code]}’ could be found".red
  end
end # task :report
