class MoviesController < ApplicationController
  before_filter :authenticate_user!, :except => :upload
  skip_before_filter :verify_authenticity_token, :only => :upload

  def upload
    @movie = Movie.find(params[:movieid])
    logger.info "Processing the upload request..." + @movie.title
    @movie.build_moviefile(:file => params[:Filedata])
    #logger.debug "New post: #{@post.attributes.inspect}"
    if (@movie.save)
      render :json => { 'status' => 'success'  }
    else
      render :json => { 'status' => 'error'  }
    end
  end 

  # GET /movies
  # GET /movies.xml
  def index
    @movies = Movie.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @movies }
    end
  end

  # GET /movies/1
  # GET /movies/1.xml
  def show
    @movie = Movie.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @movie }
    end
  end

  # GET /movies/new
  # GET /movies/new.xml
  def new
    @movie = Movie.new(:date => Date.today, :parent => -1, :status => "In queue")

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @movie }
    end
  end

  # GET /movies/1/edit
  def edit
    @movie = Movie.find(params[:id])
  end

  # POST /movies
  # POST /movies.xml
  def create
    @params = params[:movie]
    if (@params["movie_series"] != "") 
      @series = MovieSeries.find(@params["movie_series"])
    end
    @params.delete("movie_series")
    if (@series)
      @movie = @series.movies.create!(@params)
    else
      @movie = Movie.new(@params)
    end

    respond_to do |format|
      if @movie.save
        format.html { redirect_to(@movie, :notice => 'Movie was successfully created.') }
        format.xml  { render :xml => @movie, :status => :created, :location => @movie }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @movie.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /movies/1
  # PUT /movies/1.xml
  def update
    @params = params[:movie]
    if (@params["movie_series"] != "") 
      @series = MovieSeries.find(@params["movie_series"])
    end
    @params.delete("movie_series")
    @movie = Movie.find(params[:id])
    if (@series)
      @movie.movie_series = @series
    end

    respond_to do |format|
      if @movie.update_attributes(@params)
        format.html { redirect_to(@movie, :notice => 'Movie was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @movie.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1
  # DELETE /movies/1.xml
  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy

    respond_to do |format|
      format.html { redirect_to(movies_url) }
      format.xml  { head :ok }
    end
  end
end
