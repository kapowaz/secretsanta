Secret Santa
============

Randomly assigns every member of the participants list another person to buy a Secret Santa gift for.

    $ ./secretsanta.rb generate [list_of_participants.yml]
    
By default it won't email out the list immediately. You can do this with a separate command, using the code given to you once you've generated a list:

    $ ./secretsanta.rb mail [code]
    
The way the script works by default keeps the details of exactly who has who in the list relatively secret, but if you *need* to check it for any reason, you can run a report:

    $ ./secretsanta.rb report [code]
    
This will also tell you if the participant list has been emailed out yet. If you need to send the emails a second time, you can just run the original mail script again and it'll send off another batch of emails.
  
To send mail using sendmail locally on Mac OS X Mountain Lion, you'll need to run some commands as sudo to get postfix working again:

    sudo mkdir -p /Library/Server/Mail/Data/spool
    sudo /usr/sbin/postfix set-permissions
    sudo /usr/sbin/postfix start