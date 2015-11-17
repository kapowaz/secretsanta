class SecretSanta
  class Participant
    include DataMapper::Resource

    property :id,    Serial
    property :code,  String, required: true
    property :name,  String, required: true
    property :email, String, required: true

    belongs_to :assignee, Participant, required: false

    def self.generate_code
      new_code = nil

      while new_code.nil? || SecretSanta::Participant.all(code: new_code).any?
        new_code = MemorableCodes.generate
      end

      new_code
    end

    def self.create_from_yaml(yaml)
      Participant.create(
        code:  SecretSanta::Participant.generate_code,
        name:  yaml[:name],
        email: yaml[:email]
      )
    end

    def self.assign_all
      if Participant.all.length > 1
        participant_ids = Participant.all.map {|p| p.id } # => [1, 2, 3, 4, 5, 6, 7, 8, 9]
        paired_to       = participant_ids
        rng             = Random.new Time.now.to_i

        while paired_to.any? {|i| paired_to[i-1] == i }
          paired_to.shuffle!(random: rng)
        end

        Participant.each_with_index do |participant, i|
          assignee = Participant.first id: paired_to[i]
          print "[#{participant.code.bold}] Pairing participant #{participant.name.green} to #{'[REDACTED]'.bold}\n"
          participant.update assignee_id: assignee.id
        end
      else
        print "Need more than one unassigned participant in order to make assignments\n"
      end
    end

    def notify
      SecretSanta::MailHelpers.mail_with_template(
        :assignment,
        self.email,
        "[#{self.code}] You have a Secret Santa assignment!",
        participant: self
      )
    end

  end
end
