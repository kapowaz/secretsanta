Secret Santa
============

Randomly assigns every member of the participants list another person to buy a Secret Santa gift for.

  $ ./secretsanta.rb generate [list_of_participants.yml]
  
To send mail using sendmail locally on Mac OS X Mountain Lion, you'll need to run some commands as sudo to get postfix working again:

  sudo mkdir -p /Library/Server/Mail/Data/spool
  sudo /usr/sbin/postfix set-permissions
  sudo /usr/sbin/postfix start