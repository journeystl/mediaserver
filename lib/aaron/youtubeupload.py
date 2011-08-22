#!/usr/bin/python

import os.path
import atom.data
import gdata.client
import gdata.youtube
import gdata.media
import gdata.media.data
import gdata.service
import gdata.geo
import gdata.youtube.client
import gdata.youtube.data
import sys
import os

moviefile = sys.argv[1]
title = sys.argv[2]
description = sys.argv[3]
keywords = sys.argv[4]


CHUNK_SIZE = 10485760

client = gdata.youtube.client.YouTubeClient(source='yourCompany-yourAppName-v1')
client.ClientLogin('video@journeyon.net', 'J0urneyCre8ive', client.source);

f = open(moviefile)
file_size = os.path.getsize(f.name)

uploader = gdata.client.ResumableUploader(
    client, f, 'video/mpeg', file_size, chunk_size=CHUNK_SIZE, desired_class=gdata.youtube.data.VideoEntryBase)

# Set metadata for our upload.
#thumbnail = gdata.media.Thumbnail(url = "http://s3.amazonaws.com/movie_pics/thumbpics/4e15da2713a4db51bc00000b/original.jpg?1310055167")
media_group = gdata.media.Group(
            title=gdata.media.Title(text=title),
            description=gdata.media.Description(description_type='plain', text=description),
            keywords=gdata.media.Keywords(text=keywords),
            #thumbnail = thumbnail,
            category=gdata.media.Category(
                text="Nonprofit",
                label="Nonprofit"),
                #scheme=self.CATEGORIES_SCHEME),
            private=None,
            player=None)

entry = gdata.youtube.YouTubeVideoEntry(media=media_group, geo=None)
new_entry = uploader.UploadFile('http://uploads.gdata.youtube.com/resumable/feeds/api/users/default/uploads?key=AI39si79wLNca_6b8OkbxuSCQWUrfFPi27ipfe70oXWUzZGYrdsdE5rpD1WL4CcXhbm2iP6gpbSADty013w2AomFO87UvRiREA', entry=entry, headers={'Slug': os.path.basename(moviefile)})
print 'Document uploaded: ' + new_entry.title.text

