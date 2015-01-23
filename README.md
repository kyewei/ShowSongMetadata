# ShowSongMetadata

ShowSongMetadata is an iOS Jailbreak (needs MobileSubstrate) tweak that can display song metadata inside a popup in the default Music app.

When this tweak is loaded, an info button is added to all relevant UITableViewCells in the Music app's UITableViews
that launches a detailed popup when pressed.

You can find version ```1.0-1``` hosted on the
[BigBoss Repo](http://cydia.saurik.com/package/com.kyewei.showsongmetadata/) in Cydia.

It is built and tested with an iPod Touch on iOS 8.1.2 and should work with iPhones as well on iOS 8. This tweak may or may not work iOS 7, since I don't own such a device and cannot inspect the Music app.

###Screenshots
![Screenshot1](Assets/ArtistView.PNG?raw=true)
![Screenshot2](Assets/PopupView.PNG?raw=true)


###Implementation

(Why? Documentation is nice.)

I used [cycript](http://iphonedevwiki.net/index.php/Cycript) to first explore the structure of the Music app at runtime. To do this, I hooked using ```cycript -p Music```. I found instances of ```MusicCollectionTrackTableViewCell``` and ```MusicSongListTableViewCell```, and explored up and down the view structure until I reached a ```NSArray``` of ```MPConcreteMediaItem``` referenced in the parent view ```MusicTableView```'s view controller ```MusicAlbumsDetailViewController``` and ```MusicSongsViewController``` respectively. Knowing that the data was stored in these media-related objects, I added an info button to each relevant cell that, when pressed, would fetch and display the data in a ```UIAlertView```.


###Todo
* Settings preference pane
* (Maybe? if possible...) modifying metadata/MP3 tags on device.
