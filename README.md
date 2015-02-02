# ShowSongMetadata

ShowSongMetadata is an iOS Jailbreak (needs MobileSubstrate) tweak that can display song metadata inside a popup in the default Music app.

When this tweak is loaded, an info button is added to all relevant UITableViewCells in the Music app's UITableViews
that launches a detailed popup when pressed.

You can find the current version ```1.1.0-1``` hosted on the
[BigBoss Repo](http://cydia.saurik.com/package/com.kyewei.showsongmetadata/) in Cydia.

It is built and tested with an iPod Touch on iOS 8.1.2 and should work with iPhones as well on iOS 8. This tweak may or may not work iOS 7, since I don't own such a device and cannot inspect the Music app.

###Screenshots
![Screenshot1](Assets/ArtistView1.PNG?raw=true)
![Screenshot2](Assets/ArtistView2.PNG?raw=true)


![Screenshot3](Assets/NowPlaying1.PNG?raw=true)
![Screenshot4](Assets/NowPlaying2.PNG?raw=true)


###Implementation

(Why? Documentation is nice.)

I used [cycript](http://iphonedevwiki.net/index.php/Cycript) to first explore the structure of the Music app at runtime. To do this, I hooked using ```cycript -p Music```. I found instances of ```MusicCollectionTrackTableViewCell``` and ```MusicSongListTableViewCell```, and explored up and down the view structure until I reached a ```NSArray``` of ```MPConcreteMediaItem``` referenced in the parent view ```MusicTableView```'s view controller ```MusicAlbumsDetailViewController``` and ```MusicSongsViewController``` respectively. To determine which index of the ```NSArray``` to pick, I found the row and section of the cell in its parent tableView through getting a cell's ```NSIndexPath```, and used it to lookup in the ```NSArray```. Knowing that the data was stored in these media-related objects, I added an info button using a cell's ```setAccessoryType``` method to each relevant cell that, when pressed, would fetch and display the data in a ```UIAlertView```.

For searches, elements ```MusicSearchTableViewCell```'s are presented in a ```MusicSearchTableView```. It similarly has an associated ```MusicSearchViewController```. However, this view controller houses a private variable ```_nonEmptySearchDataSources``` which is an ```NSArray``` of ```MPUSearchDataSource```. Since these objects represent search queries, they have a property ```MPMediaQuery``` that contains the query itself, and within these, ```NSArray```'s of ```MPConcreteMediaItem``` which is what I want. The query itself also has a property ```groupingType``` that distinguishes between queries against specific parts of the music library, of which the enum ```MPMediaGroupingTitle=0```, represents song title queries, and will have relevant data. So I similarly carefully fetch the ```MPConcreteMediaItem``` inside these and display the data inside.

A button is also added in the Now Playing view. A ```MusicNowPlayingViewController``` was hooked, and its ```UINavigationBar```'s ```titleView``` was replaced with a ```UIView``` with subviews ```UILabel``` and ```UIButton```, relative position preserved in the process. Similarly, when the button was pressed, the ```MPConcreteMediaItem``` ```mediaItem``` inside the ```MPAVItem``` property ```_item``` in the view controller was used to extract metadata.

TL;DR, looking through private Apple things at runtime is cool. Locating what you want to find, though, is very time-consuming.

###Todo
* Settings preference pane
* (Maybe? if possible...) modifying metadata/MP3 tags on device.
