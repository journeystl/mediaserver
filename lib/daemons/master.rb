#!/usr/bin/env ruby

ENV["RAILS_ENV"] ||= "production"

require File.dirname(__FILE__) + "/../../config/application"
Rails.application.require_environment!

$running = true
Signal.trap("TERM") do 
  $running = false
end

@s3bucket = "sermonmediafiles/"
@cloudfrontForIphone = "http://d2496apgsyij57.cloudfront.net/"
@iphoneprocess = "/home/ayl/rails/mediaManager/lib/aaron/splines.sh"

@oritagdir = "/home/media/toProcess/Pipeline/tagged/"
@switches = ["process_venue", "process_mobile", "process_website", "process_mp3", "process_proof", "process_youtube"]
@encodingSettings = {"process_venue" => {:pre => "ffmpeg -i ", :post => "-threads 0 -acodec libfaac -ab 128k -vcodec libx264 -vpre medium -crf 25  ", :ext => "mp4", :s3 => true},
                     "archive" => {:pre => "ffmpeg -i ", :post => "-threads 0 -acodec libfaac -ab 128k -vcodec libx264 -vpre medium -crf 20  ", :ext => "mp4", :s3 => false},
                     "process_mobile" => true,
                     "process_youtube" => true,
                     "process_website" => {:pre => "ffmpeg -i ", :post => "-threads 0 -acodec libfaac -ab 128k -vcodec libx264 -s 640x360 -vpre medium -crf 25  ", :ext => "mp4", :s3 => true},
                     "process_mp3" => {:pre => "ffmpeg -i ", :post => "-threads 0 -acodec libmp3lame -ar 48000 -ab 64k -f mp3 -y  ", :ext => "mp3", :s3 => true},
                     "process_proof" => {:pre => "ffmpeg -i ", :post => "-threads 0 -acodec libfaac -ab 128k -vcodec libx264 -s 320x180 -vpre fast -crf 25  ", :ext => "mp4", :s3 => true}}


# Master encoding function
def master_encode(movieref, switch, switchname)
  movieref.status = "Processing switch: " + switch
  movieref.save
  # TODO: check to see if moviefile exists. if not use loc_archived
  if switchname == "youtube"
    if movieref.loc_archived != nil
      movieref.status = "Sending to Youtube"
      movieref.save
      output = `google youtube post --category Nonprofit --title "#{movieref.title.gsub("\"", "\\\"")}" --summary "#{movieref.summary.gsub("\"", "\\\"")}" #{movieref.loc_archived} 2>&1`
      if output =~ /Video uploaded: (.*)$/
        movieref.url_youtube = $1
      else
        if movieref.url_website != nil
          movieref.status = "Sending to lower quality to Youtube"
          movieref.save
          output = `google youtube post --category Nonprofit --title "#{movieref.title.gsub("\"", "\\\"")}" --summary "#{movieref.summary.gsub("\"", "\\\"")}" #{movieref.moviefile}-website.mp4 2>&1`
          if output =~ /Video uploaded: (.*)$/
            movieref.url_youtube = $1
          end
        end
      end
      Rails.logger.info "daemon - #{Time.now}: Youtube: #{output}\n"
      movieref.save
    end
    return
  end

  if switchname == "mobile"
    if movieref.loc_archived != nil
      movieref.status = "Reticulating splines for Apple"
      movieref.save
      # make directory
      @newdir = File.dirname(movieref.loc_archived) + "/iphone5"
      FileUtils.mkdir(@newdir)
      # anticipate directory on cloudfront and s3
      @dir = "iphone5/" + Time.now.strftime("%Y-%m-%d-%H-%M-%S") + "/"
      # convert!
      output = `cd #{@newdir} ; #{@iphoneprocess} #{movieref.loc_archived} #{@cloudfrontForIphone}#{@dir}`
      #Rails.logger.info "daemon - #{Time.now}: mobile: #{output}\n"
      # send directory to s3
      movieref.status = "Sending video TS shards to S3"
      movieref.save
      output = `s3cmd put --acl-public #{@newdir}/* s3://#{@s3bucket}#{@dir}`
      Rails.logger.info "daemon - #{Time.now}: mobile: #{output}\n"
      # save url to movie data structure
      movieref.url_mobile = @cloudfrontForIphone + @dir + "varpl.m3u8"
      movieref.save
    end
    return
  end

  # all other switches can be processed through ffmpeg -> S3? pipeline
  @outname = movieref.moviefile + "-" + switchname + "." + @encodingSettings[switch][:ext]
  @cmd = "#{@encodingSettings[switch][:pre]} #{movieref.moviefile} #{@encodingSettings[switch][:post]} #{@outname}"
  Rails.logger.info "daemon - #{Time.now}: #{@cmd}\n"
  output = `#{@cmd} 2>&1`
  if @encodingSettings[switch][:ext] == "mp4"
    `MP4Box -inter 500 #{@outname}`
  end
  if @encodingSettings[switch][:s3]
    movieref.status = "Sending to S3: " + switch
    movieref.save
    Rails.logger.info "daemon - #{Time.now}: Sending to S3\n"
    @dir = @s3bucket + switchname + "/" + Time.now.strftime("%Y-%m-%d-%H-%M-%S") + "/" +  File.basename(@outname)
    output = `s3cmd put --acl-public --guess-mime-type #{@outname} s3://#{@dir} 2>&1`
    Rails.logger.info "daemon - #{Time.now}: #{output}\n"
    movieref["url_" + switchname] = "http://s3.amazonaws.com/" + @dir
    movieref.save
  end

  # grab duration after generating archive version
  if switch == "archive"
    if output =~ /Duration: (.*?), start: /
      movieref.duration = $1
    end
    movieref.loc_archived = @outname
    movieref.save
  end
end

while($running) do
  # Make sure that all untagged files have stopped changing .
  @allmovies = Movie.where(:status => "In queue").entries.sort{ |a,b| a.created_at <=> b.created_at}
  for @movie in @allmovies do
    if File.exists?(@movie.moviefile)
      if @movie.filesize == nil
        @movie.filesize = File.size(@movie.moviefile)
        @movie.notchanged = false
        @movie.archived = false
        Rails.logger.info "daemon - #{Time.now}: #{@movie.moviefile} set filesize!\n"
        @movie.save
      elsif @movie.notchanged == false
        if (@movie.filesize == File.size(@movie.moviefile)) 
          Rails.logger.info "daemon - #{Time.now}: #{@movie.moviefile} moved to tagged area\n"
          @movie.notchanged = true
          # move file to tagged area.
          @tagdir = @oritagdir + Time.now.strftime("%Y-%m-%d-%H-%M-%S-") + Time.now.usec.to_s + "/"
          FileUtils.mkdir(@tagdir)
          newmoviefile = @tagdir + File.basename(@movie.moviefile).gsub(" ", "_")
          FileUtils.mv(@movie.moviefile, newmoviefile)
          @movie.moviefile = newmoviefile
          @movie.status = "Moved to tagged area"
          @movie.save
        else
          @movie.filesize = File.size(@movie.moviefile)
          @movie.save
        end
      end
    end
  end

  # iterate through all movies prioritizing the lastest created ones, doing a
  # sanity check to see if processing switches matches url.
  @allmovies = Movie.not_in(:status => ["In queue", "Trash"]).entries.sort{ |a,b| a.created_at <=> b.created_at}
  for @movie in @allmovies do
    if @movie.archived == false or @movie.archived == nil
      master_encode(@movie, "archive", "archive")
      @movie.archived = true
      @movie.save
    end

    for @switch in @switches do
      @switchname = @switch.split("_")[1]
      if @encodingSettings[@switch] != nil and @movie[@switch] and @movie["url_" + @switchname] == nil
        master_encode(@movie, @switch, @switchname)
      end
    end
    @movie.status = "Done!"
    @movie.save
  end

  Rails.logger.auto_flushing = true
  Rails.logger.info "This daemon is still running at #{Time.now}.\n"
  sleep 20
end
