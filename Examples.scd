// EXAMPLES
// --------

// ```SuperCollider
Server.local.boot;

// Oauth2 Authentication
// Note: This method gets uncompressed files, so it is needed for SC use.
// If you use 'token' method, then you can only download mp3 - which is not
// useful for scsynth.
// https://www.freesound.org/docs/api/authentication.html#oauth2-authentication
// Slightly more involved, here's the recommended procedure:
// 1. Obtain the API key (note that old APIv1 keys will not work)
// 2. Get the authorization URL:

Freesound.clientId="<your_client_id>";
Freesound.clientSecret = "<your_client_secret>";
Freesound.getAuthorizationPage

// 3. Open the URL that shows in the post window in a web browser
// 4. Within the nex 10 minutes, request your first token:
Freesound.getToken("<the_code_that_appeared_in_the_web_page>")
// This will save the token in a file besides the Freesound class file (you can change this path if you need to manage multiple tokens). This token will last 24h. From then on you can renew it e.g. each time you start a session:

(
Freesound.clientId = "<your_client_id>";
Freesound.clientSecret = "<your_client_secret>";
Freesound.refreshToken;
)


// Get sound by id
// https://www.freesound.org/docs/api/resources_apiv2.html#sound-instance

FSSound.getSound(31362, {|f|
    ~snd = f;
    ~snd["name"].postln;
});

//Get pack by id example
(
FSSound.retrievePackSounds(packid:"19889", action: { |p|
	p.do({|snd, i|
		snd.retrieve("/tmp/",{
			// ~buf = Buffer.read(s, "/tmp/" ++ snd.name);
			// ("/tmp/" ++ ~snd.name).postln;
			if(i == (p.results.size()-1)){
				"DONE!".postln;
			}
		});
	});
});
)

// example of downloading a sound

// download sound
(
~snd.retrieve(Freesound.downloadDir, {
    ~buf = Buffer.read(s, Freesound.downloadDir ++ ~snd.name);
	(Freesound.downloadDir ++ ~snd.name).postln;
    "done!".postln;
});
)


// Metadata about the sound is loaded from the JSON response into a dictionary, and also accessible using object syntax
~snd.dict.keys;
~snd.name;
~snd["name"];
~snd.tags;
~snd.duration;
~snd.url;
// preview url keys have dashes, only work as dict keys
~snd.previews["preview-hq-ogg"];

// download preview (Buffer.read requires recent libsndfile)
~preview = ~snd.retrievePreview("/tmp/", {
        ~buf = Buffer.read(s, "/tmp/" ++ ~snd.previewFilename);
        "done!".postln;
});

"/tmp/" ++ ~snd.previewFilename.postln;
~buf.play;


// Similar sounds
// https://www.freesound.org/docs/api/resources_apiv2.html#similar-sounds

~snd.getSimilar( action:{|p| ~snd = p[1] ;})
~snd["name"].postln;


// Analysis
// https://www.freesound.org/docs/api/resources_apiv2.html#sound-analysis
// https://www.freesound.org/docs/api/analysis_index.html

~snd.getAnalysis( "lowlevel.pitch", {|val|
            val.lowlevel.pitch.mean.postln;
}, true)



// Text search
// https://www.freesound.org/docs/api/resources_apiv2.html#text-search

FSSound.textSearch( query: "glitch", filter: "type:wav",params:('page':2), action:{|p|
    ~snd = p[0]; // first result
    ~snd.name.postln;
});



// Download (if you did oauth2 authentication!)

~snd.retrieve("/tmp/", {
    ~buf = Buffer.read(s, "/tmp/" ++ ~snd.name);
	("/tmp/" ++ ~snd.name).postln;
    "done!".postln;
});

~buf.play;



// Content-based search:
// https://www.freesound.org/docs/api/resources_apiv2.html#content-search

FSSound.contentSearch(
	target: '.lowlevel.pitch.mean:600',
	filter: '.lowlevel.pitch_instantaneous_confidence.mean:[0.8 TO 1]',
	params: ('page':2), action: {|pager|
		    ~snd = pager[0];
		    ~snd.name.postln;
    }
);


// Combined (text and content) search:
// https://www.freesound.org/docs/api/resources_apiv2.html#combined-search

FSSound.combinedSearch(query: "glitch", filter: "type:wav",
    descriptorsFilter: ".lowlevel.pitch_instantaneous_confidence.mean:[0.8 TO 1]",
    params:('page': 4), action:{|pager|
        ~snd = pager[0];
        ~snd.name.postln;
    }
);
