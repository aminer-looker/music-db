This repository contains code to scrape the [Classical Music Database](http://www.classicalmusicdb.com) and dump the
contents into a local MySQL database named "music".

### Setup ###

1. Clone the repository
2. Set up a local MySQL instance with a "root" user having no password (the default)
3. Install [Node.js](http://nodejs.org) (if you haven't already).
4. Run `npm install` to download dependencies
5. Install CoffeeScript: `npm install -g coffee-script` (if you haven't already)
6. Run `grunt rebuild-db` to create the "music" database and all its tables, etc.
7. Run the scraper: `coffee src/index.coffee`
8. Set up your local Looker instance with a connection to your local "music" database.
9. Set up your local Looker with a project which pulls from this repository for it's LookML.
