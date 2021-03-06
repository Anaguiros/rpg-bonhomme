This project provides the following features:
- locally load & save your character from JSON files.
- only require a web browser (and an Internet connection to use the remote storage feature).
- optionnaly you can save your character on a remote server,
which will let you to share it with others simply by providing a unique URL.
- add character sheets from any game.

# Examples

- [Lythes](https://chezsoi.org/lucas/rpg-bonhomme/character-sheet.html?layout=Dedale&name=lythes), an android from the French RPG [Dédale](http://lab00.free.fr/sommaire/home.htm).
- [Kathelyn Terblanche](https://chezsoi.org/lucas/rpg-bonhomme/character-sheet.html?layout=Absence&name=kathelyn_terblanche) & [Raphaelle Lepercq](https://chezsoi.org/lucas/rpg-bonhomme/character-sheet.html?layout=Absence&name=raphaelle_lepercq_se_fait_appeler_lila_), two characters from a 'one-shot' RPG called 'Absence'.
- [Atharès](https://chezsoi.org/lucas/rpg-bonhomme/character-sheet.html?layout=InCognito1&name=athares), a character from the second campaign of my RPG game 'In Cognito'.
- [Ted Sand](https://chezsoi.org/lucas/rpg-bonhomme/character-sheet.html?layout=Allegoria&name=ted_sand) & [Jacob Valens](https://chezsoi.org/lucas/rpg-bonhomme/character-sheet.html?layout=Allegoria&name=jacob_valens) from my RPG campaign 'Allegoria'.

# Usage

All the interactions are made using the 4 top right buttons and the 'name' input field.

To remote load an existing character, simply go to https://chezsoi.org/lucas/rpg-bonhomme/character-sheet.html?layout= and type a layout name at the end of URL, then enter your character name and press 'Load from remote server'. Alternatively you can directly enter an URL formatted like this: '?layout=<layout-name>&name=<character-id>'.

To edit and remote save a new character, simply go to https://chezsoi.org/lucas/rpg-bonhomme/character-sheet.html?layout= and type a layout name at the end of the URL, then enter your character name and press the 'Save to remote server' button.

The currently available layouts matches the list of file in the **css/** & **img/** directories of this repository. Note that at the time of writing, some layouts are still 'in-progress' and currently empty.

# Internals & asumptions

- a ?layout= URL parameter must always be provided to _character-sheet.html_.
- this _layout_ must match the name of a .css file in **css/**, and a .png character sheet image in **img/**.
- input (or textarea) fields are defined once and only once by rules starting with 'input#<name>' in the layout.css,
and they must be the only selectors starting that way in the file.
Non-textual fields must be specified as 'input[type=.+]#<name>'
- the _layout.css_ MUST define a text input with id 'name'.
- (up)loading a new character currently only replace inputs defined in the provided file,
non-redefined caracteristics will keep their old value.

# jsonp-db

This is a simple key-value store using a SQLite DB, developped to allow simple GET/PUT through JSONP.

In case of a lookup error, the return value will be 'undefined', else it will returns 'value' or throw an error
(calling Javascript 'alert' if using JSONP, else displaying an HTML error page).

There are some key/value length limitations currently hardcoded at the top of the Python file.
There is also a client & server limitation on the request URI (between 2KB & 8KB usually), that can trigger a 414 error.

Finally, a word of warning: **trusting a 3rd party JSONP API is a big confidence commitment / security risk**.
More details [here](http://security.stackexchange.com/a/23439).

That being said, this WSGI app won't do anything nasty.

## Setup

Deployed with Apache [`mod_wsgi`](https://modwsgi.readthedocs.org) :

    WSGIScriptAlias /path/to/jsonp-db /path/to/jsonp-db.wsgi

    sqlite3 jsonp-db.db 'CREATE TABLE KVStore(Key TEXT PRIMARY KEY, Value TEXT);'
    chmod ugo+rw jsonp-db.db
    sudo ln -s $PWD/jsonp-db-backup.sh /etc/cron.daily/jsonp-db-backup.sh

## Testing

    curl https://chezsoi.org/lucas/rpg-bonhomme/jsonp-db/x?42
    curl https://chezsoi.org/lucas/rpg-bonhomme/jsonp-db/x
    curl -X POST -d '{name:"John Doe"}' https://chezsoi.org/lucas/rpg-bonhomme/jsonp-db/john_doe
    curl https://chezsoi.org/lucas/rpg-bonhomme/jsonp-db/john_doe
    curl https://chezsoi.org/lucas/rpg-bonhomme/jsonp-db/john_doe?%7Bname%3A%22John%20Doe%22%7D
    curl https://chezsoi.org/lucas/rpg-bonhomme/jsonp-db/john_doe&callback=foo
    curl https://chezsoi.org/lucas/rpg-bonhomme/jsonp-db/x?%7Ba%3A%7Bb%3Atrue%7D%7D
    curl -X POST --data-urlencode @tmp.json https://chezsoi.org/lucas/rpg-bonhomme/jsonp-db/x

Error handling:

    curl https://chezsoi.org/lucas/rpg-bonhomme/jsonp-db # raises a 404
    curl https://chezsoi.org/lucas/rpg-bonhomme/jsonp-db/a/ # raises a 404
    curl https://chezsoi.org/lucas/rpg-bonhomme/jsonp-db/unset_key # returns {}
    key=$(strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 101 | tr -d '\n')
    curl -X PUT -d 0=1 https://chezsoi.org/lucas/rpg-bonhomme/jsonp-db/$key # raises a ValueError 404

# Resources

Zero dependencies, all coded in vanilla Javascript.
All icons are from Google Material Design icons set (CC BY 4.0) : https://github.com/google/material-design-icons

# Notes

- why this project name ? It's a reference to the line "T'as tué mon bonhomme !" from the video "Tom et ses chums! Farador D&D" : http://youtu.be/T9FMURHhgzc?t=4m40s
- in case you want to add a character sheet in PDF format, you can use `pdftoppm` then ImageMagick `convert` to get a PNG image file.

