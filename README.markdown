Yet Anoter IF this then that
============================

Description
-----------

Sorry, I copied [ifttt](http://www.ifttt.com).

The target of yaif is to connect services in the internet, let them work together and automatically.

Basically, a typical services will have some triggers and actions. For example, Twitter. The home line of Twitter is a trigger, you can get information from it and to do something depends on the content of a tweet. And to post a tweet is an action, which will update and change the status of your home line. Yaif's target is connect all different services. You can create some task, get information from a trigger of A Service, and do an action in B Service.

Usage
-----

1.  Clone the code and prepare the rails environment.
2.  Copy the ./service.template to ./service
3.  Update the service information in ./service, for example: oauth secret and key. The update information depends on service authentication type.
4.  Run command to import service to database:

        $ rake service:import

5.  Make a invite to your self:

        $ rails c
        irb > u = RegKey.new :email => "user@domain.com"
        irb > u.save
        irb > puts u.key
        db716e8d8          # this output is reg_key, remember it

6.  Start your rails server.
7.  Create a new user. Access your site: http://yoursite/signup?reg\_key=db716e8d8 . The reg\_key is the output of step 5.
8.  Access http://yoursite/crontab.text and add lines to your cron to trigger tasks interval.
9.  Enjoy.

TODO
----

1. Maybe need change the Service information from database to ruby code. Seems let user add new service is not a good idea. So saving them in database is nothing benefit.
2. More service………
3. Use icon in same size.
4. Make some css. (I'm lazy…)
