Secret Santa
============

Randomly assigns every member of the participants list another person to buy a Secret Santa gift for.

The list of participants is defined in `config/participants.yml`. Check the example to see the format needed.

You will also need to supply some valid SMTP server credentials for sending email, which go in `config/smtp.yml`. To send mail using sendmail locally on Mac OS X, you'll need to run some commands as sudo to get postfix working again:

    sudo mkdir -p /Library/Server/Mail/Data/spool
    sudo /usr/sbin/postfix set-permissions
    sudo /usr/sbin/postfix start

Usage
-----

1. `bundle install`
2. `bundle exec rake import` to import all participants
3. `bundle exec rake assign` to assign all participants a Secret Santa
4. `bundle exec rake mailall` to send an email to all participants with information about who their assignment is

You can also use a few other rake tasks as needed.

    bundle exec rake assign[reset]

This lets you re-assign all participants, but without changing the assignment codes.

    bundle exec rake mail[<code>]

You can resend an email for a particular participant with this task, using their unique code.

    bundle exec rake report

This command lists all participants, their codes and email addresses (but not their assignments)

    bundle exec rake reveal[<code>]

This command reveals the assignment for a given participant, just in case you need to for any reason.
