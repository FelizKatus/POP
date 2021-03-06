# POP (Perl shOP)

Made with:

* Love
* Perl5
* Dancer2
* SQLite3
* Bootstrap5

in The Kingdom of Spain.

## Home

## Shop

* Session-based autorization
* Blog
* SPAM-protected contact form

## Admin

* Add blog posts

## Dependencies:

* Dancer2
* Template Toolkit
* File::Slurper
* DBD::SQLite
* Dancer2::Plugin::Database

Installing for Debian/Ubuntu/WSL:

*apt install libdancer2-perl*

*apt install libtemplate-perl*

*apt install libfile-slurper-perl*

*apt install libdbd-sqlite3-perl*

*apt install libdancer2-plugin-database-perl*

## Application launching:

Starting your mail server, for example:

*sudo service postfix start*

Starting the app:

*plackup -p 5000 bin/app.psgi*

For development:

*plackup -p 5000 -R lib bin/app.psgi*

Logging:

*logs/development.log*

Enjoy!

http://localhost:5000

**admin/password**

## Shop screenshots

![Home](screenshots/home.png "Home")

![Blog](screenshots/blog.png "Blog")

![Contact](screenshots/contact.png "Contact")

![Login](screenshots/login.png "Login")

## Admin screenshots

![Dashboard](screenshots/dashboard.png "Dashboard")

![Posts](screenshots/posts.png "Posts")

![New post](screenshots/new_post.png "New post")
